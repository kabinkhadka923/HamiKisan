const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');

const db = require('../config/db');
const { getTokenFromHeader } = require('../middleware/authMiddleware');
const { getRedisClient } = require('../config/redis');
const { buildRoomId } = require('../utils/chat');

const registerSocketHandlers = (httpServer) => {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
  });

  io.use((socket, next) => {
    try {
      const authToken = socket.handshake.auth?.token || socket.handshake.headers.authorization;
      const token = getTokenFromHeader(authToken);
      if (!token) {
        return next(new Error('Authentication error: token missing'));
      }

      const payload = jwt.verify(token, process.env.JWT_SECRET);
      socket.user = payload;
      return next();
    } catch (_error) {
      return next(new Error('Authentication error: invalid token'));
    }
  });

  io.on('connection', async (socket) => {
    const userId = socket.user.id;
    const redisClient = getRedisClient();

    socket.join(`user_${userId}`);

    if (redisClient) {
      try {
        await redisClient.set(`presence:user:${userId}`, 'online', {
          EX: 60,
        });
      } catch (_error) {
        // Presence cache failure should not break socket flow.
      }
    }

    socket.on('join_room', ({ roomId, peerUserId }) => {
      const finalRoomId = roomId || buildRoomId(userId, peerUserId);
      socket.join(finalRoomId);
      socket.emit('joined_room', { roomId: finalRoomId });
    });

    socket.on('leave_room', ({ roomId }) => {
      if (roomId) {
        socket.leave(roomId);
      }
    });

    // ---- Call signaling (instant, per-user rooms) ----
    socket.on('call_invite', ({ toUserId, callType, callerName, callId }) => {
      if (!toUserId) return;
      io.to(`user_${toUserId}`).emit('call_incoming', {
        callId: callId,
        from: userId,
        fromName: callerName || null,
        callType: callType || 'video',
      });
    });

    socket.on('call_accept', ({ callId, toUserId }) => {
      if (!toUserId) return;
      io.to(`user_${toUserId}`).emit('call_accepted', {
        callId: callId,
        from: userId,
      });
    });

    socket.on('call_decline', ({ callId, toUserId }) => {
      if (!toUserId) return;
      io.to(`user_${toUserId}`).emit('call_declined', {
        callId: callId,
        from: userId,
      });
    });

    socket.on('call_end', ({ callId, toUserId }) => {
      if (!toUserId) return;
      io.to(`user_${toUserId}`).emit('call_ended', {
        callId: callId,
        from: userId,
      });
    });

    socket.on('call_sdp', ({ callId, toUserId, sdp, sdpType }) => {
      if (!toUserId || !sdp) return;
      io.to(`user_${toUserId}`).emit('call_sdp', {
        callId: callId,
        from: userId,
        sdp,
        sdpType: sdpType,
      });
    });

    socket.on('call_ice', ({ callId, toUserId, candidate }) => {
      if (!toUserId || !candidate) return;
      io.to(`user_${toUserId}`).emit('call_ice', {
        callId: callId,
        from: userId,
        candidate,
      });
    });

    socket.on('typing', ({ roomId, isTyping }) => {
      if (!roomId) return;
      socket.to(roomId).emit('typing', { roomId, userId, isTyping: Boolean(isTyping) });
    });

    socket.on('send_message', async (payload) => {
      try {
        const { roomId, receiverId, message } = payload || {};
        if (!receiverId || !message) return;

        const finalRoomId = roomId || buildRoomId(userId, receiverId);
        const result = await db.query(
          `INSERT INTO chat_messages (room_id, sender_id, receiver_id, message)
           VALUES ($1, $2, $3, $4)
           RETURNING id, room_id, sender_id, receiver_id, message, sent_at, is_read`,
          [finalRoomId, userId, receiverId, message],
        );

        const data = result.rows[0];
        io.to(finalRoomId).emit('receive_message', data);
        io.to(`user_${receiverId}`).emit('receive_message', data);
      } catch (_error) {
        socket.emit('socket_error', { message: 'Failed to send message.' });
      }
    });

    socket.on('disconnect', async () => {
      if (redisClient) {
        try {
          await redisClient.del(`presence:user:${userId}`);
        } catch (_error) {
          // Ignore cache errors during disconnect.
        }
      }
    });
  });

  return io;
};

module.exports = {
  registerSocketHandlers,
};
