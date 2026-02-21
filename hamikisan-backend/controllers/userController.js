const db = require('../config/db');

const getProfile = async (req, res) => {
  const result = await db.query(
    `SELECT id, name, email, role, created_at
     FROM users
     WHERE id = $1`,
    [req.user.id],
  );

  if (result.rowCount === 0) {
    return res.status(404).json({ error: 'User not found.' });
  }

  return res.json({ user: result.rows[0] });
};

const listDoctors = async (_req, res) => {
  const result = await db.query(
    `SELECT id, name, email, role, created_at
     FROM users
     WHERE role = 'doctor'
     ORDER BY created_at DESC`,
  );
  return res.json({ doctors: result.rows });
};

module.exports = {
  getProfile,
  listDoctors,
};
