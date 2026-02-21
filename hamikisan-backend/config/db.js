const { Pool } = require('pg');

const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL }
    : {
        user: process.env.DB_USER || 'postgres',
        host: process.env.DB_HOST || 'localhost',
        database: process.env.DB_NAME || 'hamikisan_db',
        password: process.env.DB_PASSWORD || '',
        port: Number(process.env.DB_PORT) || 5432,
      },
);

pool.on('error', (error) => {
  // eslint-disable-next-line no-console
  console.error('Unexpected PostgreSQL error:', error);
});

const testDbConnection = async () => {
  await pool.query('SELECT 1');
  // eslint-disable-next-line no-console
  console.log('PostgreSQL connected');
};

const closeDb = async () => {
  await pool.end();
};

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  testDbConnection,
  closeDb,
};
