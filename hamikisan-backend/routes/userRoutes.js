const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const { getProfile, updateProfile, listDoctors, listFarmers } = require('../controllers/userController');

const router = express.Router();

router.get('/me', authMiddleware, asyncHandler(getProfile));
router.put('/me', authMiddleware, asyncHandler(updateProfile));
router.get('/doctors', authMiddleware, asyncHandler(listDoctors));
router.get('/farmers', authMiddleware, asyncHandler(listFarmers));

module.exports = router;
