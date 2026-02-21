const express = require('express');
const { getPosts, createPost, deletePost, toggleLike } = require('../controllers/postController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.route('/')
    .get(getPosts)
    .post(protect, createPost);

router.route('/:id')
    .delete(protect, deletePost);

router.post('/:id/like', protect, toggleLike);

module.exports = router;
