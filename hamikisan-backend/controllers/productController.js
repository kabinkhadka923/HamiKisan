const { pool } = require('../config/db');

const ALLOWED_STATUS = new Set(['pending', 'approved', 'rejected', 'all']);
const ALLOWED_UPDATE_STATUS = new Set(['pending', 'approved', 'rejected', 'sold']);

const mapProduct = (row) => ({
  id: row.id.toString(),
  sellerId: row.seller_id.toString(),
  sellerName: row.seller_name,
  title: row.title,
  description: row.description,
  category: row.category,
  subCategory: row.sub_category,
  price: parseFloat(row.price),
  unit: row.unit,
  quantity: row.quantity == null ? null : parseFloat(row.quantity),
  location: row.location,
  district: row.district,
  qualityGrade: row.quality_grade,
  isOrganic: row.is_organic,
  status: row.status,
  imageUrls: row.image_urls || [],
  createdAt: row.created_at,
  updatedAt: row.updated_at,
});

// Public product listing (approved by default).
const getProducts = async (req, res, next) => {
  try {
    const { category, search } = req.query;
    const requestedStatus = String(req.query.status || 'approved').toLowerCase();
    const status = ALLOWED_STATUS.has(requestedStatus) ? requestedStatus : 'approved';

    const whereClauses = [];
    const values = [];

    if (status !== 'all') {
      values.push(status);
      whereClauses.push(`status = $${values.length}`);
    }

    if (category && category !== 'All') {
      values.push(category);
      whereClauses.push(`category = $${values.length}`);
    }

    if (search && search.trim() !== '') {
      values.push(`%${search.trim()}%`);
      whereClauses.push(`title ILIKE $${values.length}`);
    }

    const query = `
      SELECT *
      FROM products
      ${whereClauses.length ? `WHERE ${whereClauses.join(' AND ')}` : ''}
      ORDER BY created_at DESC
    `;

    const result = await pool.query(query, values);
    res.json(result.rows.map(mapProduct));
  } catch (err) {
    next(err);
  }
};

const getMyProducts = async (req, res, next) => {
  try {
    const userId = Number(req.user.id);
    const result = await pool.query(
      `SELECT *
       FROM products
       WHERE seller_id = $1
       ORDER BY created_at DESC`,
      [userId],
    );

    res.json(result.rows.map(mapProduct));
  } catch (err) {
    next(err);
  }
};

const createProduct = async (req, res, next) => {
  try {
    const userId = Number(req.user.id);
    const {
      title,
      description,
      category,
      subCategory,
      price,
      unit,
      quantity,
      location,
      district,
      qualityGrade,
      isOrganic,
      imageUrls,
    } = req.body;

    if (!title || !description || price == null) {
      return res
        .status(400)
        .json({ error: 'title, description and price are required.' });
    }

    const parsedPrice = Number(price);
    const parsedQuantity = quantity == null ? null : Number(quantity);

    if (!Number.isFinite(parsedPrice) || parsedPrice <= 0) {
      return res.status(400).json({ error: 'price must be a positive number.' });
    }

    if (parsedQuantity != null && (!Number.isFinite(parsedQuantity) || parsedQuantity < 0)) {
      return res.status(400).json({ error: 'quantity must be zero or positive.' });
    }

    const userResult = await pool.query(
      `SELECT id, name, role
       FROM users
       WHERE id = $1`,
      [userId],
    );

    if (userResult.rowCount === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    const user = userResult.rows[0];
    if (!['farmer', 'admin'].includes(user.role)) {
      return res.status(403).json({ error: 'Only farmers and admins can create products.' });
    }

    const query = `
      INSERT INTO products (
        seller_id, seller_name, title, description, category, sub_category,
        price, unit, quantity, location, district, quality_grade, is_organic, image_urls, status
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, 'pending')
      RETURNING *
    `;

    const values = [
      user.id,
      user.name,
      title,
      description,
      category || null,
      subCategory || null,
      parsedPrice,
      unit || null,
      parsedQuantity,
      location || null,
      district || null,
      qualityGrade || null,
      Boolean(isOrganic),
      Array.isArray(imageUrls) ? imageUrls : [],
    ];

    const result = await pool.query(query, values);
    res.status(201).json(mapProduct(result.rows[0]));
  } catch (err) {
    next(err);
  }
};

const updateProductStatus = async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Only admins can update product status.' });
    }

    const productId = Number(req.params.id);
    const status = String(req.body.status || '').toLowerCase();

    if (!ALLOWED_UPDATE_STATUS.has(status)) {
      return res.status(400).json({ error: 'Invalid status.' });
    }

    const result = await pool.query(
      `UPDATE products
       SET status = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [status, productId],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Product not found.' });
    }

    res.json(mapProduct(result.rows[0]));
  } catch (err) {
    next(err);
  }
};

module.exports = { getProducts, getMyProducts, createProduct, updateProductStatus };
