const crypto = require('crypto');

const CALL_TTL_MS = 90 * 1000;

const calls = new Map();
const { requireAcceptedConnection } = require('../utils/connections');

const cleanupExpired = () => {
  const now = Date.now();
  for (const [id, call] of calls) {
    if (now - call.createdAt > CALL_TTL_MS) {
      calls.delete(id);
    }
  }
};

const invite = async (req, res) => {
  const { receiverId, callType = 'video', callerName } = req.body;
  const callerId = String(req.user.id);

  if (!receiverId) {
    return res.status(400).json({ error: 'receiverId is required.' });
  }
  if (String(receiverId) === callerId) {
    return res.status(400).json({ error: 'You cannot call yourself.' });
  }
  if (!await requireAcceptedConnection(res, callerId, receiverId)) return;

  cleanupExpired();

  for (const call of calls.values()) {
    if (
      call.status === 'ringing' &&
      ((call.from === callerId && call.to === String(receiverId)) ||
        (call.from === String(receiverId) && call.to === callerId))
    ) {
      return res.json({ callId: call.id, status: call.status, existing: true });
    }
  }

  const callId = crypto.randomUUID();
  const call = {
    id: callId,
    from: callerId,
    fromName: callerName || null,
    to: String(receiverId),
    callType,
    status: 'ringing',
    createdAt: Date.now(),
  };
  calls.set(callId, call);

  return res.status(201).json({ callId, status: call.status });
};

const incoming = async (req, res) => {
  cleanupExpired();
  const me = String(req.user.id);
  for (const call of calls.values()) {
    if (call.to === me && call.status === 'ringing') {
      return res.json({ call });
    }
  }
  return res.json({ call: null });
};

const answer = async (req, res) => {
  const { callId, accept = true } = req.body;
  const me = String(req.user.id);

  if (!callId) {
    return res.status(400).json({ error: 'callId is required.' });
  }

  const call = calls.get(String(callId));
  if (!call) {
    return res.status(404).json({ error: 'Call not found.' });
  }
  if (call.to !== me) {
    return res.status(403).json({ error: 'Forbidden.' });
  }
  if (call.status !== 'ringing') {
    return res.status(409).json({ error: 'Call is no longer ringing.' });
  }

  call.status = accept ? 'connected' : 'declined';
  call.answeredAt = Date.now();

  return res.json({ callId: call.id, status: call.status });
};

const end = async (req, res) => {
  const { callId } = req.body;
  const me = String(req.user.id);

  if (!callId) {
    return res.status(400).json({ error: 'callId is required.' });
  }

  const call = calls.get(String(callId));
  if (!call) {
    return res.status(404).json({ error: 'Call not found.' });
  }
  if (call.from !== me && call.to !== me) {
    return res.status(403).json({ error: 'Forbidden.' });
  }

  call.status = 'ended';
  call.endedAt = Date.now();
  setTimeout(() => calls.delete(String(callId)), 10 * 1000);

  return res.json({ callId: call.id, status: call.status });
};

const status = async (req, res) => {
  cleanupExpired();
  const call = calls.get(String(req.params.callId));
  if (!call) {
    return res.status(404).json({ error: 'Call not found.' });
  }
  if (call.from !== String(req.user.id) && call.to !== String(req.user.id)) {
    return res.status(403).json({ error: 'Forbidden.' });
  }
  return res.json({ callId: call.id, status: call.status, call });
};

module.exports = { invite, incoming, answer, end, status };
