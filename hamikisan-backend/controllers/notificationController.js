const db = require('../config/db');

const listNotifications = async (req, res) => {
    const userId = req.user.id;
    const limit = Math.min(Number(req.query.limit) || 20, 100);

    const result = await db.query(
        `SELECT id, title, message, type, is_read, created_at
     FROM notifications
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
        [userId, limit]
    );

    return res.json({ notifications: result.rows });
};

const markAsRead = async (req, res) => {
    const userId = req.user.id;
    const notificationId = Number(req.params.id);

    const result = await db.query(
        `UPDATE notifications
     SET is_read = TRUE
     WHERE id = $1 AND user_id = $2
     RETURNING id, title, message, type, is_read, created_at`,
        [notificationId, userId]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Notification not found' });
    }

    return res.json({ notification: result.rows[0] });
};

const markAllAsRead = async (req, res) => {
    const userId = req.user.id;

    await db.query(
        `UPDATE notifications
     SET is_read = TRUE
     WHERE user_id = $1 AND is_read = FALSE`,
        [userId]
    );

    return res.json({ success: true, message: 'All notifications marked as read' });
};

module.exports = {
    listNotifications,
    markAsRead,
    markAllAsRead,
};
