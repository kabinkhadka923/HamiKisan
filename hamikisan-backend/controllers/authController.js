const bcrypt = require('bcryptjs');
const db = require('../config/db');
const { signToken } = require('../utils/jwt');

const ROLES = new Set(['farmer', 'doctor', 'admin']);

const sanitizeUser = (user) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  role: user.role,
  createdAt: user.created_at,
});

const register = async (req, res) => {
  const { name, email, password, role = 'farmer' } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'name, email and password are required.' });
  }

  if (password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters.' });
  }

  if (!ROLES.has(role)) {
    return res.status(400).json({ error: 'Invalid role.' });
  }

  const existing = await db.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
  if (existing.rowCount > 0) {
    return res.status(409).json({ error: 'Email already registered.' });
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const result = await db.query(
    `INSERT INTO users (name, email, password_hash, role)
     VALUES ($1, $2, $3, $4)
     RETURNING id, name, email, role, created_at`,
    [name.trim(), email.toLowerCase(), passwordHash, role],
  );

  const user = result.rows[0];
  const token = signToken(user);
  return res.status(201).json({ user: sanitizeUser(user), token });
};

const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'email and password are required.' });
  }

  const result = await db.query(
    'SELECT id, name, email, role, password_hash, created_at FROM users WHERE email = $1',
    [email.toLowerCase()],
  );

  if (result.rowCount === 0) {
    return res.status(401).json({ error: 'Invalid credentials.' });
  }

  const user = result.rows[0];
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    return res.status(401).json({ error: 'Invalid credentials.' });
  }

  const token = signToken(user);
  return res.json({ user: sanitizeUser(user), token });
};

module.exports = {
  register,
  login,
};
