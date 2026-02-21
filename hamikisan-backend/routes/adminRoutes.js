const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware, authorizeRoles } = require('../middleware/authMiddleware');
const { listAllUsers, deleteUser, getDashboardStats } = require('../controllers/adminController');

const router = express.Router();

router.use(authMiddleware);
router.use(authorizeRoles('admin'));

router.get('/users', asyncHandler(listAllUsers));
router.delete('/users/:id', asyncHandler(deleteUser));
router.get('/dashboard-stats', asyncHandler(getDashboardStats));

module.exports = router;
