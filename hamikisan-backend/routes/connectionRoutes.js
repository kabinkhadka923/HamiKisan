const express = require('express');
const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const controller = require('../controllers/connectionController');

const router = express.Router();
router.use(authMiddleware);

router.get('/', asyncHandler(controller.listConnections));
router.post('/request', asyncHandler(controller.requestConnection));
router.post('/:id/:action', asyncHandler(controller.updateConnection));
router.post('/:id/report', asyncHandler(controller.reportConnection));

module.exports = router;