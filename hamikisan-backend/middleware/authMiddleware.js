const jwt = require('jsonwebtoken');

const getTokenFromHeader = (authorization = '') => {
  if (!authorization) return null;
  if (authorization.startsWith('Bearer ')) {
    return authorization.slice(7).trim();
  }
  return authorization.trim();
};

const authMiddleware = (req, res, next) => {
  const token = getTokenFromHeader(req.headers.authorization);
  if (!token) {
    return res.status(401).json({ error: 'Access denied. Token is missing.' });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    return next();
  } catch (_error) {
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }
};

const authorizeRoles = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ error: 'Forbidden.' });
  }
  return next();
};

// Backward-compatible alias used by some route files.
const protect = authMiddleware;

module.exports = {
  authMiddleware,
  protect,
  authorizeRoles,
  getTokenFromHeader,
};
