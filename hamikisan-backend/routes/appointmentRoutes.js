const express = require('express');

const asyncHandler = require('../middleware/asyncHandler');
const { authMiddleware } = require('../middleware/authMiddleware');
const {
  createAppointment,
  listMyAppointments,
  updateAppointmentStatus,
} = require('../controllers/appointmentController');

const router = express.Router();

router.use(authMiddleware);

router.post('/', asyncHandler(createAppointment));
router.get('/mine', asyncHandler(listMyAppointments));
router.patch('/:id/status', asyncHandler(updateAppointmentStatus));

module.exports = router;
