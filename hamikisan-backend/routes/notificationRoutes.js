const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const { listNotifications, markAsRead, markAllAsRead } = require('../controllers/notificationController');

const router = express.Router();

router.use(authMiddleware);

router.get('/', asyncHandler(listNotifications));
router.put('/mark-all-read', asyncHandler(markAllAsRead));
router.put('/:id/read', asyncHandler(markAsRead));

module.exports = router;
