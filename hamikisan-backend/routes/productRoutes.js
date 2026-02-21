const express = require('express');
const {
    getProducts,
    getMyProducts,
    createProduct,
    updateProductStatus,
} = require('../controllers/productController');
const { protect, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

router.route('/')
    .get(getProducts)
    .post(protect, createProduct);

router.get('/mine', protect, getMyProducts);
router.patch('/:id/status', protect, authorizeRoles('admin'), updateProductStatus);

module.exports = router;
