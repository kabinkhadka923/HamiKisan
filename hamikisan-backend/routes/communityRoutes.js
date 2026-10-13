const express = require('express');
const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const {
  getDistricts,
  updateMembership,
} = require('../controllers/communityController');

const router = express.Router();

router.get('/districts', authMiddleware, asyncHandler(getDistricts));
router.post(
  '/districts/:districtId/membership',
  authMiddleware,
  asyncHandler(updateMembership),
);
router.delete(
  '/districts/:districtId/membership',
  authMiddleware,
  asyncHandler(updateMembership),
);

module.exports = router;
