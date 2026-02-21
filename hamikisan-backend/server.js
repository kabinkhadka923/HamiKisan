require('dotenv').config();

const http = require('http');
const express = require('express');
const cors = require('cors');

const { testDbConnection, closeDb } = require('./config/db');
const { connectRedis, closeRedis } = require('./config/redis');
const { registerSocketHandlers } = require('./socket/socketHandler');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const chatRoutes = require('./routes/chatRoutes');

const PORT = Number(process.env.PORT) || 5000;
const JWT_SECRET = process.env.JWT_SECRET;
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';

if (!JWT_SECRET) {
  throw new Error('Missing required environment variable: JWT_SECRET');
}

const app = express();
app.use(
  cors({
    origin: CORS_ORIGIN === '*' ? true : CORS_ORIGIN.split(',').map((v) => v.trim()),
    credentials: true,
  }),
);
app.use(express.json());

app.get('/', (_req, res) => {
  res.json({ message: 'HamiKisan Backend Running' });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/chat', chatRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

const server = http.createServer(app);
const io = registerSocketHandlers(server);
app.set('io', io);

const start = async () => {
  await testDbConnection();
  await connectRedis();

  server.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`Server running on port ${PORT}`);
  });
};

const shutdown = async () => {
  io.close();
  server.close(async () => {
    await closeRedis();
    await closeDb();
    process.exit(0);
  });
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

start().catch((error) => {
  // eslint-disable-next-line no-console
  console.error('Failed to start backend:', error);
  process.exit(1);
});
