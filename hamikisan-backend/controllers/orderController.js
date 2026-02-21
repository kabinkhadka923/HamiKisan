const { pool } = require('../config/db');

const ORDER_STATUSES = new Set([
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
]);

const mapOrderItem = (row) => ({
  productId: row.product_id.toString(),
  productName: row.product_name,
  quantity: Number(row.quantity),
  unitPrice: parseFloat(row.unit_price),
  totalPrice: parseFloat(row.total_price),
});

const mapOrder = (orderRow, itemRows) => ({
  id: orderRow.id.toString(),
  buyerId: orderRow.buyer_id.toString(),
  sellerId: orderRow.seller_id.toString(),
  items: itemRows.map(mapOrderItem),
  totalAmount: parseFloat(orderRow.total_amount),
  status: orderRow.status,
  createdAt: new Date(orderRow.created_at).getTime(),
  completedAt: orderRow.completed_at ? new Date(orderRow.completed_at).getTime() : null,
  deliveryAddress: orderRow.delivery_address,
  notes: orderRow.notes,
});

const loadItemsByOrderIds = async (orderIds) => {
  if (orderIds.length === 0) {
    return new Map();
  }

  const itemsResult = await pool.query(
    `SELECT order_id, product_id, product_name, quantity, unit_price, total_price
     FROM order_items
     WHERE order_id = ANY($1::bigint[])
     ORDER BY id ASC`,
    [orderIds],
  );

  const grouped = new Map();
  for (const row of itemsResult.rows) {
    const key = Number(row.order_id);
    if (!grouped.has(key)) {
      grouped.set(key, []);
    }
    grouped.get(key).push(row);
  }
  return grouped;
};

const createOrder = async (req, res, next) => {
  const client = await pool.connect();
  try {
    const buyerId = Number(req.user.id);
    const { items, deliveryAddress, notes } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'items must be a non-empty array.' });
    }
    if (!deliveryAddress || String(deliveryAddress).trim().length < 5) {
      return res.status(400).json({ error: 'deliveryAddress is required.' });
    }

    const normalizedItems = items.map((item) => ({
      productId: Number(item.productId),
      quantity: Number(item.quantity || 1),
    }));

    if (normalizedItems.some((item) => !Number.isInteger(item.productId) || item.productId <= 0)) {
      return res.status(400).json({ error: 'All item productId values must be valid integers.' });
    }
    if (normalizedItems.some((item) => !Number.isInteger(item.quantity) || item.quantity <= 0)) {
      return res.status(400).json({ error: 'All item quantity values must be positive integers.' });
    }

    const productIds = [...new Set(normalizedItems.map((item) => item.productId))];
    const productsResult = await client.query(
      `SELECT id, seller_id, title, price, status
       FROM products
       WHERE id = ANY($1::bigint[])`,
      [productIds],
    );

    if (productsResult.rowCount !== productIds.length) {
      return res.status(404).json({ error: 'One or more products were not found.' });
    }

    const productsById = new Map(productsResult.rows.map((row) => [Number(row.id), row]));
    const blockedProduct = productsResult.rows.find((row) => row.status !== 'approved');
    if (blockedProduct) {
      return res.status(400).json({ error: 'Only approved products can be ordered.' });
    }

    const sellerIds = new Set(productsResult.rows.map((row) => Number(row.seller_id)));
    if (sellerIds.size !== 1) {
      return res.status(400).json({ error: 'All items must belong to the same seller.' });
    }

    const sellerId = [...sellerIds][0];
    if (sellerId === buyerId) {
      return res.status(400).json({ error: 'You cannot place an order for your own product.' });
    }

    let totalAmount = 0;
    const orderItemsToInsert = normalizedItems.map((item) => {
      const product = productsById.get(item.productId);
      const unitPrice = parseFloat(product.price);
      const totalPrice = unitPrice * item.quantity;
      totalAmount += totalPrice;

      return {
        productId: item.productId,
        productName: product.title,
        quantity: item.quantity,
        unitPrice,
        totalPrice,
      };
    });

    await client.query('BEGIN');

    const orderResult = await client.query(
      `INSERT INTO orders (buyer_id, seller_id, total_amount, delivery_address, notes)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [buyerId, sellerId, totalAmount, String(deliveryAddress).trim(), notes || null],
    );
    const order = orderResult.rows[0];

    for (const item of orderItemsToInsert) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, total_price)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [order.id, item.productId, item.productName, item.quantity, item.unitPrice, item.totalPrice],
      );
    }

    await client.query('COMMIT');
    return res.status(201).json(mapOrder(order, orderItemsToInsert.map((item) => ({
      product_id: item.productId,
      product_name: item.productName,
      quantity: item.quantity,
      unit_price: item.unitPrice,
      total_price: item.totalPrice,
    }))));
  } catch (err) {
    await client.query('ROLLBACK');
    return next(err);
  } finally {
    client.release();
  }
};

const listMyOrders = async (req, res, next) => {
  try {
    const userId = Number(req.user.id);
    const status = req.query.status ? String(req.query.status).toLowerCase() : null;

    if (status && !ORDER_STATUSES.has(status)) {
      return res.status(400).json({ error: 'Invalid status filter.' });
    }

    const where = [];
    const values = [];

    if (req.user.role === 'admin') {
      where.push('1=1');
    } else {
      values.push(userId);
      where.push(`(buyer_id = $${values.length} OR seller_id = $${values.length})`);
    }

    if (status) {
      values.push(status);
      where.push(`status = $${values.length}`);
    }

    const ordersResult = await pool.query(
      `SELECT *
       FROM orders
       WHERE ${where.join(' AND ')}
       ORDER BY created_at DESC`,
      values,
    );

    const orderIds = ordersResult.rows.map((row) => Number(row.id));
    const itemsByOrderId = await loadItemsByOrderIds(orderIds);

    const orders = ordersResult.rows.map((orderRow) =>
      mapOrder(orderRow, itemsByOrderId.get(Number(orderRow.id)) || []),
    );

    return res.json({ orders });
  } catch (err) {
    return next(err);
  }
};

const updateOrderStatus = async (req, res, next) => {
  try {
    const orderId = Number(req.params.id);
    const status = String(req.body.status || '').toLowerCase();

    if (!ORDER_STATUSES.has(status)) {
      return res.status(400).json({ error: 'Invalid order status.' });
    }

    const orderResult = await pool.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    if (orderResult.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found.' });
    }

    const order = orderResult.rows[0];
    const userId = Number(req.user.id);
    const isAdmin = req.user.role === 'admin';
    const isSeller = Number(order.seller_id) === userId;
    const isBuyer = Number(order.buyer_id) === userId;

    if (!isAdmin && !isSeller && !isBuyer) {
      return res.status(403).json({ error: 'Forbidden.' });
    }
    if (isBuyer && !isAdmin && !isSeller && status !== 'cancelled') {
      return res.status(403).json({ error: 'Buyers can only cancel orders.' });
    }

    const completedAt = status === 'delivered' ? new Date() : null;
    const updateResult = await pool.query(
      `UPDATE orders
       SET status = $1,
           updated_at = NOW(),
           completed_at = CASE WHEN $2::timestamptz IS NULL THEN completed_at ELSE $2::timestamptz END
       WHERE id = $3
       RETURNING *`,
      [status, completedAt, orderId],
    );

    const itemsByOrderId = await loadItemsByOrderIds([orderId]);
    return res.json({
      order: mapOrder(updateResult.rows[0], itemsByOrderId.get(orderId) || []),
    });
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  createOrder,
  listMyOrders,
  updateOrderStatus,
};
