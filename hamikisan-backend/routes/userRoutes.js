const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const { getProfile, listDoctors } = require('../controllers/userController');

const router = express.Router();

router.get('/me', authMiddleware, asyncHandler(getProfile));
router.get('/doctors', authMiddleware, asyncHandler(listDoctors));

module.exports = router;
