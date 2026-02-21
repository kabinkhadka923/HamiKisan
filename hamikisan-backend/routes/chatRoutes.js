const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const { listMessages, sendMessage } = require('../controllers/chatController');

const router = express.Router();

router.use(authMiddleware);

router.get('/rooms/:roomId/messages', asyncHandler(listMessages));
router.post('/messages', asyncHandler(sendMessage));

module.exports = router;
