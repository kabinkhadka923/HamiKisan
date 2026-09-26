const db = require('../config/db');

const getConnection = async (userA, userB) => {
  const result = await db.query(
    `SELECT id, requester_id, receiver_id, status, created_at, updated_at
     FROM connections
     WHERE (requester_id = $1 AND receiver_id = $2)
        OR (requester_id = $2 AND receiver_id = $1)
     LIMIT 1`,
    [userA, userB],
  );
  return result.rows[0] || null;
};

const hasAcceptedConnection = async (userA, userB) => {
  const connection = await getConnection(userA, userB);
  return connection?.status === 'accepted';
};

const requireAcceptedConnection = async (res, userA, userB) => {
  if (await hasAcceptedConnection(userA, userB)) return true;
  res.status(403).json({
    error: 'An accepted connection is required before chatting or calling.',
    code: 'CONNECTION_REQUIRED',
  });
  return false;
};

module.exports = {
  getConnection,
  hasAcceptedConnection,
  requireAcceptedConnection,
};