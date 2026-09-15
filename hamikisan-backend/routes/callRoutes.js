const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const callController = require('../controllers/callController');

const router = express.Router();

router.use(authMiddleware);

router.post('/invite', asyncHandler(callController.invite));
router.get('/incoming', asyncHandler(callController.incoming));
router.post('/answer', asyncHandler(callController.answer));
router.post('/end', asyncHandler(callController.end));
router.get('/status/:callId', asyncHandler(callController.status));

module.exports = router;
