const db = require('../config/db');
const { requireAcceptedConnection } = require('../utils/connections');

const VALID_STATUS = new Set(['pending', 'confirmed', 'completed', 'cancelled']);

const createAppointment = async (req, res) => {
  const { doctorId, scheduledAt, notes = '' } = req.body;
  const farmerId = req.user.id;

  if (req.user.role !== 'farmer') {
    return res.status(403).json({ error: 'Only farmers can request appointments.' });
  }

  if (!doctorId || !scheduledAt) {
    return res.status(400).json({ error: 'doctorId and scheduledAt are required.' });
  }

  const doctor = await db.query('SELECT id FROM users WHERE id = $1 AND role = $2', [doctorId, 'doctor']);
  if (doctor.rowCount === 0) {
    return res.status(404).json({ error: 'Doctor not found.' });
  }
  if (!await requireAcceptedConnection(res, farmerId, doctorId)) return;

  const result = await db.query(
    `INSERT INTO appointments (farmer_id, doctor_id, scheduled_at, notes)
     VALUES ($1, $2, $3, $4)
     RETURNING id, farmer_id, doctor_id, scheduled_at, status, notes, created_at`,
    [farmerId, doctorId, scheduledAt, notes],
  );

  await db.query(
    `INSERT INTO notifications (user_id, title, message, type)
     VALUES ($1, $2, $3, $4)`,
    [doctorId, 'New appointment request', 'A connected farmer requested an appointment.', 'appointment'],
  );

  return res.status(201).json({ appointment: result.rows[0] });
};

const listMyAppointments = async (req, res) => {
  const { role, id } = req.user;

  if (role === 'admin') {
    const all = await db.query(
      `SELECT id, farmer_id, doctor_id, scheduled_at, status, notes, created_at
       FROM appointments
       ORDER BY scheduled_at DESC`,
    );
    return res.json({ appointments: all.rows });
  }

  const result =
    role === 'doctor'
      ? await db.query(
          `SELECT id, farmer_id, doctor_id, scheduled_at, status, notes, created_at
           FROM appointments
           WHERE doctor_id = $1
           ORDER BY scheduled_at DESC`,
          [id],
        )
      : await db.query(
          `SELECT id, farmer_id, doctor_id, scheduled_at, status, notes, created_at
           FROM appointments
           WHERE farmer_id = $1
           ORDER BY scheduled_at DESC`,
          [id],
        );
  return res.json({ appointments: result.rows });
};

const updateAppointmentStatus = async (req, res) => {
  const appointmentId = Number(req.params.id);
  const { status } = req.body;

  if (!VALID_STATUS.has(status)) {
    return res.status(400).json({ error: 'Invalid status.' });
  }

  const lookup = await db.query(
    `SELECT id, farmer_id, doctor_id, status
     FROM appointments
     WHERE id = $1`,
    [appointmentId],
  );

  if (lookup.rowCount === 0) {
    return res.status(404).json({ error: 'Appointment not found.' });
  }

  const appointment = lookup.rows[0];
  const isOwner = req.user.id === appointment.doctor_id || req.user.id === appointment.farmer_id;
  if (!isOwner && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden.' });
  }

  const result = await db.query(
    `UPDATE appointments
     SET status = $1
     WHERE id = $2
     RETURNING id, farmer_id, doctor_id, scheduled_at, status, notes, created_at`,
    [status, appointmentId],
  );

  return res.json({ appointment: result.rows[0] });
};

module.exports = {
  createAppointment,
  listMyAppointments,
  updateAppointmentStatus,
};
