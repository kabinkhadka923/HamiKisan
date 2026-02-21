const db = require('../config/db');

const listAllUsers = async (req, res) => {
    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;

    const result = await db.query(
        `SELECT id, name, email, role, phone, location, specialty, created_at
     FROM users
     ORDER BY created_at DESC
     LIMIT $1 OFFSET $2`,
        [limit, offset],
    );

    const countResult = await db.query('SELECT COUNT(*) FROM users');
    const count = parseInt(countResult.rows[0].count, 10);

    return res.json({
        users: result.rows,
        pagination: {
            total: count,
            limit,
            offset,
        },
    });
};

const deleteUser = async (req, res) => {
    const userId = Number(req.params.id);

    if (userId === req.user.id) {
        return res.status(400).json({ error: 'Cannot delete your own admin account.' });
    }

    const result = await db.query(
        `DELETE FROM users
     WHERE id = $1
     RETURNING id, name`,
        [userId],
    );

    if (result.rowCount === 0) {
        return res.status(404).json({ error: 'User not found.' });
    }

    return res.json({ message: 'User deleted successfully.', deleted: result.rows[0] });
};

const getDashboardStats = async (req, res) => {
    const usersCount = await db.query('SELECT COUNT(*) FROM users');
    const apptsCount = await db.query('SELECT COUNT(*) FROM appointments');
    const chatCount = await db.query('SELECT COUNT(*) FROM chat_messages');
    const productsCount = await db.query('SELECT COUNT(*) FROM products');
    const pendingProducts = await db.query("SELECT COUNT(*) FROM products WHERE status = 'pending'");
    const ordersCount = await db.query('SELECT COUNT(*) FROM orders');

    const pendingAppts = await db.query("SELECT COUNT(*) FROM appointments WHERE status = 'pending'");

    return res.json({
        stats: {
            totalUsers: parseInt(usersCount.rows[0].count, 10),
            totalAppointments: parseInt(apptsCount.rows[0].count, 10),
            pendingAppointments: parseInt(pendingAppts.rows[0].count, 10),
            totalChatMessages: parseInt(chatCount.rows[0].count, 10),
            totalProducts: parseInt(productsCount.rows[0].count, 10),
            pendingProducts: parseInt(pendingProducts.rows[0].count, 10),
            totalOrders: parseInt(ordersCount.rows[0].count, 10),
        },
    });
};

module.exports = {
    listAllUsers,
    deleteUser,
    getDashboardStats,
};
