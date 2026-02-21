const bcrypt = require('bcryptjs');
const db = require('../config/db');
const { signToken } = require('../utils/jwt');

const DB_ROLES = new Set(['farmer', 'doctor', 'admin']);

const normalizeRole = (role) => {
  const normalized = String(role || 'farmer').trim().toLowerCase();
  if (normalized === 'farmer') return 'farmer';
  if (['doctor', 'kisandoctor', 'kisan_doctor'].includes(normalized)) return 'doctor';
  if (['admin', 'kisanadmin', 'kisan_admin', 'superadmin', 'super_admin'].includes(normalized)) {
    return 'admin';
  }
  return null;
};

const mapDbRoleToAppRole = (role) => {
  if (role === 'doctor') return 'kisanDoctor';
  if (role === 'admin') return 'kisanAdmin';
  return 'farmer';
};

const sanitizeUser = (user) => ({
  id: String(user.id),
  name: user.name,
  email: user.email,
  username: user.username || null,
  phoneNumber: user.phone || null,
  role: mapDbRoleToAppRole(user.role),
  status: user.status || 'approved',
  permissions: user.permissions || null,
  isVerified: user.is_verified !== false,
  hasSelectedLanguage: user.has_selected_language !== false,
  createdAt: new Date(user.created_at).getTime(),
  lastLoginAt: user.last_login_at ? new Date(user.last_login_at).getTime() : null,
});

const register = async (req, res) => {
  const {
    name,
    email,
    password,
    role = 'farmer',
    username,
    phoneNumber,
    phone_number: phoneNumberSnake,
  } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'name, email and password are required.' });
  }

  if (password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters.' });
  }

  const dbRole = normalizeRole(role);
  if (!dbRole || !DB_ROLES.has(dbRole)) {
    return res.status(400).json({ error: 'Invalid role.' });
  }

  const normalizedEmail = email.toLowerCase().trim();
  const normalizedUsername = username ? String(username).trim().toLowerCase() : null;
  const normalizedPhone = (phoneNumber || phoneNumberSnake || '').trim() || null;

  const existing = await db.query('SELECT id FROM users WHERE email = $1', [normalizedEmail]);
  if (existing.rowCount > 0) {
    return res.status(409).json({ error: 'Email already registered.' });
  }
  if (normalizedUsername) {
    const existingUsername = await db.query('SELECT id FROM users WHERE LOWER(username) = $1', [normalizedUsername]);
    if (existingUsername.rowCount > 0) {
      return res.status(409).json({ error: 'Username already registered.' });
    }
  }
  if (normalizedPhone) {
    const existingPhone = await db.query('SELECT id FROM users WHERE phone = $1', [normalizedPhone]);
    if (existingPhone.rowCount > 0) {
      return res.status(409).json({ error: 'Phone number already registered.' });
    }
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const permissions =
    dbRole === 'admin' ? ['manage_users', 'manage_content', 'manage_products', 'manage_orders'] : null;

  const result = await db.query(
    `INSERT INTO users (name, email, password_hash, role, username, phone, status, permissions)
     VALUES ($1, $2, $3, $4, $5, $6, 'approved', $7)
     RETURNING id, name, email, role, username, phone, status, permissions,
               is_verified, has_selected_language, last_login_at, created_at`,
    [name.trim(), normalizedEmail, passwordHash, dbRole, normalizedUsername, normalizedPhone, permissions],
  );

  const user = result.rows[0];
  const token = signToken(user);
  return res.status(201).json({ user: sanitizeUser(user), token });
};

const login = async (req, res) => {
  const { email, username, identifier, phoneNumber, phone_number: phoneNumberSnake, password } = req.body;
  const rawIdentifier = email || username || identifier || phoneNumber || phoneNumberSnake;

  if (!rawIdentifier || !password) {
    return res.status(400).json({ error: 'identifier and password are required.' });
  }

  const normalizedIdentifier = String(rawIdentifier).trim();
  const phoneCandidates = [normalizedIdentifier];
  if (!normalizedIdentifier.startsWith('+')) {
    phoneCandidates.push(`+977${normalizedIdentifier}`);
  }
  if (normalizedIdentifier.startsWith('+977')) {
    phoneCandidates.push(normalizedIdentifier.slice(4));
  }

  const result = await db.query(
    `SELECT id, name, email, role, username, phone, status, permissions,
            is_verified, has_selected_language, last_login_at, created_at, password_hash
     FROM users
     WHERE LOWER(email) = LOWER($1)
        OR LOWER(COALESCE(username, '')) = LOWER($1)
        OR phone = ANY($2::text[])
     LIMIT 1`,
    [normalizedIdentifier, phoneCandidates],
  );

  if (result.rowCount === 0) {
    return res.status(401).json({ error: 'Invalid credentials.' });
  }

  const user = result.rows[0];
  if (user.status === 'suspended') {
    return res.status(403).json({ error: 'Account is suspended.' });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    return res.status(401).json({ error: 'Invalid credentials.' });
  }

  await db.query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [user.id]);
  user.last_login_at = new Date();

  const token = signToken(user);
  return res.json({ user: sanitizeUser(user), token });
};

module.exports = {
  register,
  login,
};
