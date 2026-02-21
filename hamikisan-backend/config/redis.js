const { createClient } = require('redis');

let redisClient = null;

const connectRedis = async () => {
  const enabled = process.env.REDIS_ENABLED !== 'false';
  if (!enabled) {
    // eslint-disable-next-line no-console
    console.log('Redis disabled by REDIS_ENABLED=false');
    return null;
  }

  const url = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
  redisClient = createClient({ url });

  redisClient.on('error', (error) => {
    // eslint-disable-next-line no-console
    console.error('Redis error:', error.message);
  });

  try {
    await redisClient.connect();
    // eslint-disable-next-line no-console
    console.log('Redis connected');
    return redisClient;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.warn('Redis unavailable, continuing without cache:', error.message);
    redisClient = null;
    return null;
  }
};

const getRedisClient = () => redisClient;

const closeRedis = async () => {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
  }
};

module.exports = {
  connectRedis,
  getRedisClient,
  closeRedis,
};
