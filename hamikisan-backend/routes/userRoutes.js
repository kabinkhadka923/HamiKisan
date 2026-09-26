const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const { getProfile, updateProfile, updateAvailability, listDoctors, listFarmers } = require('../controllers/userController');

const router = express.Router();

router.get('/me', authMiddleware, asyncHandler(getProfile));
router.put('/me', authMiddleware, asyncHandler(updateProfile));
router.patch('/me/availability', authMiddleware, asyncHandler(updateAvailability));
router.get('/doctors', authMiddleware, asyncHandler(listDoctors));
router.get('/farmers', authMiddleware, asyncHandler(listFarmers));

module.exports = router;
