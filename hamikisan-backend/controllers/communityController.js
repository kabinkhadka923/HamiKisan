const db = require('../config/db');
const {
  districts,
  districtById,
  districtId,
} = require('../constants/nepalDistricts');

const ensureDistrictRows = async () => {
  const ids = districts.map(districtId);
  const names = districts.map((district) => `${district} District Community`);
  await db.query(
    `INSERT INTO community_districts (id, district, name)
     SELECT district_id, district_name, community_name
     FROM UNNEST($1::text[], $2::text[], $3::text[])
       AS rows(district_id, district_name, community_name)
     ON CONFLICT (id) DO NOTHING`,
    [ids, districts, names],
  );
};

const getDistricts = async (req, res) => {
  await ensureDistrictRows();

  const result = await db.query(
    `SELECT
       d.id,
       d.district,
       d.name,
       COUNT(m.user_id)::int AS member_count,
       COALESCE(BOOL_OR(m.user_id = $1), FALSE) AS is_member
     FROM community_districts d
     LEFT JOIN community_memberships m ON m.district_id = d.id
     GROUP BY d.id, d.district, d.name
     ORDER BY d.district`,
    [req.user.id],
  );
  return res.json({
    districts: result.rows.map((row) => ({
      id: row.id,
      name: row.name,
      district: row.district,
      type: 'district',
      location: row.district,
      member_count: row.member_count,
      is_member: row.is_member === true,
      is_active: true,
    })),
  });
};

const updateMembership = async (req, res) => {
  const { districtId: requestedId } = req.params;
  const district = districtById.get(requestedId);
  if (!district) {
    return res.status(404).json({ error: 'District community not found.' });
  }

  await db.query(
    `INSERT INTO community_districts (id, district, name)
     VALUES ($1, $2, $3)
     ON CONFLICT (id) DO NOTHING`,
    [requestedId, district, `${district} District Community`],
  );

  if (req.method === 'POST') {
    await db.query(
      `INSERT INTO community_memberships (district_id, user_id)
       VALUES ($1, $2)
       ON CONFLICT (district_id, user_id) DO NOTHING`,
      [requestedId, req.user.id],
    );
  } else {
    await db.query(
      `DELETE FROM community_memberships
       WHERE district_id = $1 AND user_id = $2`,
      [requestedId, req.user.id],
    );
  }

  return res.json({
    district,
    isMember: req.method === 'POST',
  });
};

module.exports = { getDistricts, updateMembership };
