const notFoundHandler = (req, res, _next) => {
  res.status(404).json({
    error: `Route not found: ${req.method} ${req.originalUrl}`,
  });
};

const errorHandler = (error, _req, res, _next) => {
  // eslint-disable-next-line no-console
  console.error(error);

  if (error.code === '23505') {
    return res.status(409).json({ error: 'Duplicate value violates unique constraint.' });
  }

  if (error.code === '22P02') {
    return res.status(400).json({ error: 'Invalid request format.' });
  }

  const status = error.status || 500;
  return res.status(status).json({
    error: error.message || 'Internal server error.',
  });
};

module.exports = {
  notFoundHandler,
  errorHandler,
};
