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

const updateProfile = async (req, res) => {
  const { name, phone, location, specialty } = req.body;
  const userId = req.user.id;

  const result = await db.query(
    `UPDATE users 
     SET 
       name = COALESCE($1, name),
       phone = COALESCE($2, phone),
       location = COALESCE($3, location),
       specialty = COALESCE($4, specialty)
     WHERE id = $5
     RETURNING id, name, email, role, phone, location, specialty, created_at`,
    [name, phone, location, specialty, userId],
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
  updateProfile,
  listDoctors,
};
