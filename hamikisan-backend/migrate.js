require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('./config/db');

async function runSchema() {
    try {
        const schemaSql = fs.readFileSync(path.join(__dirname, 'database', 'schema.sql'), 'utf-8');
        console.log('Running schema logic...');
        await pool.query(schemaSql);
        console.log('Schema fully synced!');
    } catch (err) {
        console.error('Error syncing:', err);
    } finally {
        process.exit(0);
    }
}

runSchema();
