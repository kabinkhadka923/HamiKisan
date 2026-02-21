const { pool } = require('../config/db');

const mapPost = (row, isLiked = false) => ({
  id: row.id.toString(),
  authorName: row.author_name,
  authorRole: row.author_role,
  content: row.content,
  postType: row.post_type,
  district: row.district,
  imagePath: row.image_path,
  likes: row.likes,
  comments: row.comments,
  shares: row.shares,
  isLiked,
  timestamp: row.created_at,
});

const getPosts = async (req, res, next) => {
  try {
    const { district } = req.query;
    const values = [];
    const whereClauses = [];

    if (district && district.trim() !== '') {
      values.push(district.trim());
      whereClauses.push(`district = $${values.length}`);
    }

    const query = `
      SELECT *
      FROM posts
      ${whereClauses.length ? `WHERE ${whereClauses.join(' AND ')}` : ''}
      ORDER BY created_at DESC
    `;

    const result = await pool.query(query, values);
    res.json(result.rows.map((row) => mapPost(row)));
  } catch (err) {
    next(err);
  }
};

const createPost = async (req, res, next) => {
  try {
    const userId = Number(req.user.id);
    const { content, postType, district, imagePath } = req.body;

    if (!content || content.trim().length < 3) {
      return res.status(400).json({ error: 'content must be at least 3 characters.' });
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
    const query = `
      INSERT INTO posts (user_id, author_name, author_role, content, post_type, district, image_path)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    const values = [
      user.id,
      user.name,
      user.role,
      content.trim(),
      postType || 'General',
      district || null,
      imagePath || null,
    ];

    const result = await pool.query(query, values);
    res.status(201).json(mapPost(result.rows[0]));
  } catch (err) {
    next(err);
  }
};

const deletePost = async (req, res, next) => {
  try {
    const postId = Number(req.params.id);
    const userId = Number(req.user.id);
    const userRole = req.user.role;

    const postResult = await pool.query(
      `SELECT id, user_id
       FROM posts
       WHERE id = $1`,
      [postId],
    );

    if (postResult.rowCount === 0) {
      return res.status(404).json({ error: 'Post not found.' });
    }

    const post = postResult.rows[0];
    const isOwner = Number(post.user_id) === userId;
    const isAdmin = userRole === 'admin';

    if (!isOwner && !isAdmin) {
      return res.status(403).json({ error: 'Forbidden.' });
    }

    await pool.query('DELETE FROM posts WHERE id = $1', [postId]);
    res.json({ message: 'Post deleted.' });
  } catch (err) {
    next(err);
  }
};

const toggleLike = async (req, res, next) => {
  const client = await pool.connect();
  try {
    const postId = Number(req.params.id);
    const userId = Number(req.user.id);

    await client.query('BEGIN');

    const postResult = await client.query('SELECT id FROM posts WHERE id = $1 FOR UPDATE', [postId]);
    if (postResult.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Post not found.' });
    }

    const likeResult = await client.query(
      `SELECT 1
       FROM post_likes
       WHERE post_id = $1 AND user_id = $2`,
      [postId, userId],
    );

    let isLiked;
    if (likeResult.rowCount > 0) {
      await client.query(
        `DELETE FROM post_likes
         WHERE post_id = $1 AND user_id = $2`,
        [postId, userId],
      );
      isLiked = false;
    } else {
      await client.query(
        `INSERT INTO post_likes (post_id, user_id)
         VALUES ($1, $2)`,
        [postId, userId],
      );
      isLiked = true;
    }

    const countResult = await client.query(
      `SELECT COUNT(*)::int AS count
       FROM post_likes
       WHERE post_id = $1`,
      [postId],
    );
    const likes = countResult.rows[0].count;

    await client.query('UPDATE posts SET likes = $1 WHERE id = $2', [likes, postId]);
    await client.query('COMMIT');

    res.json({ likes, isLiked });
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
};

module.exports = { getPosts, createPost, deletePost, toggleLike };
