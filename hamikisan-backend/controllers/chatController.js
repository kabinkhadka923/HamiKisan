const db = require('../config/db');
const { buildRoomId } = require('../utils/chat');

const listMessages = async (req, res) => {
  const { roomId } = req.params;
  const limit = Math.min(Number(req.query.limit) || 50, 200);
  const userId = Number(req.user.id);

  if (roomId.startsWith('dm_')) {
    const [, a, b] = roomId.split('_');
    if (Number(a) !== userId && Number(b) !== userId) {
      return res.status(403).json({ error: 'Forbidden.' });
    }
  }

  const result = await db.query(
    `SELECT id, room_id, sender_id, receiver_id, message, sent_at, is_read
     FROM chat_messages
     WHERE room_id = $1
     ORDER BY sent_at DESC
     LIMIT $2`,
    [roomId, limit],
  );

  return res.json({ messages: result.rows.reverse() });
};

const sendMessage = async (req, res) => {
  const senderId = req.user.id;
  const { receiverId, message, roomId } = req.body;

  if (!receiverId || !message) {
    return res.status(400).json({ error: 'receiverId and message are required.' });
  }

  const receiver = await db.query('SELECT id FROM users WHERE id = $1', [receiverId]);
  if (receiver.rowCount === 0) {
    return res.status(404).json({ error: 'Receiver not found.' });
  }

  const finalRoomId = roomId || buildRoomId(senderId, receiverId);
  const result = await db.query(
    `INSERT INTO chat_messages (room_id, sender_id, receiver_id, message)
     VALUES ($1, $2, $3, $4)
     RETURNING id, room_id, sender_id, receiver_id, message, sent_at, is_read`,
    [finalRoomId, senderId, receiverId, message],
  );

  const payload = result.rows[0];
  const io = req.app.get('io');
  io.to(finalRoomId).emit('receive_message', payload);

  return res.status(201).json({ message: payload });
};

module.exports = {
  listMessages,
  sendMessage,
};
