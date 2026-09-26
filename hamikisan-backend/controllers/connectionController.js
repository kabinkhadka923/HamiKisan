const db = require('../config/db');
const { getConnection } = require('../utils/connections');

const getOtherUserId = (connection, userId) =>
  String(connection.requester_id) === String(userId)
    ? connection.receiver_id
    : connection.requester_id;

const requestConnection = async (req, res) => {
  const requesterId = String(req.user.id);
  const receiverId = String(req.body.receiverId || '');
  if (!receiverId || receiverId === requesterId) {
    return res.status(400).json({ error: 'A different receiverId is required.' });
  }

  const receiver = await db.query(
    `SELECT id FROM users WHERE id = $1 AND status = 'approved'`,
    [receiverId],
  );
  if (receiver.rowCount === 0) return res.status(404).json({ error: 'User not found.' });

  const pendingCount = await db.query(
    `SELECT COUNT(*)::int AS count
     FROM connections
     WHERE requester_id = $1 AND status = 'pending'
       AND created_at > NOW() - INTERVAL '24 hours'`,
    [requesterId],
  );
  if (pendingCount.rows[0].count >= 20) {
    return res.status(429).json({ error: 'Too many connection requests. Try again later.' });
  }

  const existing = await getConnection(requesterId, receiverId);
  if (existing) {
    if (existing.status === 'accepted') return res.json({ connection: existing });
    if (existing.status === 'blocked') return res.status(403).json({ error: 'Connection is blocked.' });
    return res.status(409).json({ error: 'A connection request already exists.', connection: existing });
  }

  const result = await db.query(
    `INSERT INTO connections (requester_id, receiver_id)
     VALUES ($1, $2)
     RETURNING id, requester_id, receiver_id, status, created_at, updated_at`,
    [requesterId, receiverId],
  );
  await db.query(
    `INSERT INTO notifications (user_id, title, message, type)
     VALUES ($1, $2, $3, $4)`,
    [receiverId, 'New connection request', 'Someone wants to connect with you.', 'connection'],
  );
  return res.status(201).json({ connection: result.rows[0] });
};

const listConnections = async (req, res) => {
  const userId = String(req.user.id);
  const result = await db.query(
    `SELECT c.id, c.requester_id, c.receiver_id, c.status, c.created_at, c.updated_at,
            u.id AS other_user_id, u.name AS other_user_name, u.role AS other_user_role
     FROM connections c
     JOIN users u ON u.id = CASE WHEN c.requester_id = $1 THEN c.receiver_id ELSE c.requester_id END
     WHERE c.requester_id = $1 OR c.receiver_id = $1
     ORDER BY c.updated_at DESC`,
    [userId],
  );
  return res.json({ connections: result.rows });
};

const updateConnection = async (req, res) => {
  const userId = String(req.user.id);
  const connectionId = req.params.id;
  const action = req.params.action;
  const connectionResult = await db.query('SELECT * FROM connections WHERE id = $1', [connectionId]);
  const connection = connectionResult.rows[0];
  if (!connection) return res.status(404).json({ error: 'Connection not found.' });

  if (action === 'accept' || action === 'reject') {
    if (String(connection.receiver_id) !== userId) return res.status(403).json({ error: 'Only the receiver can respond.' });
    if (connection.status !== 'pending') return res.status(409).json({ error: 'Request is no longer pending.' });
  } else if (action === 'block') {
    if (String(connection.receiver_id) !== userId && String(connection.requester_id) !== userId) {
      return res.status(403).json({ error: 'Forbidden.' });
    }
  } else {
    return res.status(400).json({ error: 'Unsupported connection action.' });
  }

  const status = action === 'accept' ? 'accepted' : action === 'reject' ? 'rejected' : 'blocked';
  const result = await db.query(
    `UPDATE connections SET status = $1, updated_at = NOW()
     WHERE id = $2
     RETURNING id, requester_id, receiver_id, status, created_at, updated_at`,
    [status, connectionId],
  );
  if (status === 'accepted') {
    await db.query(
      `INSERT INTO notifications (user_id, title, message, type)
       VALUES ($1, $2, $3, $4)`,
      [connection.requester_id, 'Connection accepted', 'Your connection request was accepted.', 'connection'],
    );
  }
  return res.json({ connection: result.rows[0] });
};

const reportConnection = async (req, res) => {
  const userId = String(req.user.id);
  const connectionId = req.params.id;
  const reason = String(req.body.reason || '').trim();
  if (!reason) return res.status(400).json({ error: 'A report reason is required.' });

  const connection = await db.query('SELECT * FROM connections WHERE id = $1', [connectionId]);
  if (connection.rowCount === 0) return res.status(404).json({ error: 'Connection not found.' });
  const row = connection.rows[0];
  if (String(row.requester_id) !== userId && String(row.receiver_id) !== userId) {
    return res.status(403).json({ error: 'Forbidden.' });
  }
  const reportedUserId = getOtherUserId(row, userId);
  await db.query(
    `INSERT INTO connection_reports (connection_id, reporter_id, reported_user_id, reason)
     VALUES ($1, $2, $3, $4)`,
    [connectionId, userId, reportedUserId, reason],
  );
  return res.status(201).json({ reported: true });
};

module.exports = {
  requestConnection,
  listConnections,
  updateConnection,
  reportConnection,
};