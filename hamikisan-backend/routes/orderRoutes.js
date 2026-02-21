const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { protect } = require('../middleware/authMiddleware');
const { createOrder, listMyOrders, updateOrderStatus } = require('../controllers/orderController');

const router = express.Router();

router.use(protect);
router.post('/', asyncHandler(createOrder));
router.get('/mine', asyncHandler(listMyOrders));
router.patch('/:id/status', asyncHandler(updateOrderStatus));

module.exports = router;
