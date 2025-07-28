const express = require('express');
const { body, validationResult } = require('express-validator');
const { Post, User, Comment, Like } = require('../models');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all posts (with pagination)
router.get('/', authenticateToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const posts = await Post.findPublicPosts({
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
        },
        {
          model: Comment,
          as: 'comments',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'username', 'fullName', 'avatarUrl']
          }],
          limit: 5,
          order: [['createdAt', 'DESC']]
        }
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset
    });

    res.json(posts);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Create a new post
router.post('/', authenticateToken, [
  body('content').isLength({ min: 1, max: 2000 }).withMessage('Content must be between 1 and 2000 characters'),
  body('postType').isIn(['progress', 'cycle', 'motivation', 'question', 'achievement']),
  body('privacyLevel').optional().isIn(['public', 'followers', 'private']),
  body('compoundTags').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const postData = {
      userId: req.user.id,
      content: req.body.content,
      postType: req.body.postType,
      privacyLevel: req.body.privacyLevel || 'public',
      compoundTags: req.body.compoundTags || [],
      mediaUrls: req.body.mediaUrls || []
    };

    const post = await Post.create(postData);
    
    // Include user data in response
    const postWithUser = await Post.findByPk(post.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
      }]
    });

    res.status(201).json(postWithUser);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get a specific post
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
        },
        {
          model: Comment,
          as: 'comments',
          include: [{
            model: User,
            as: 'user',
            attributes: ['id', 'username', 'fullName', 'avatarUrl']
          }],
          order: [['createdAt', 'ASC']]
        }
      ]
    });

    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    res.json(post);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update a post
router.put('/:id', authenticateToken, [
  body('content').isLength({ min: 1, max: 2000 }).withMessage('Content must be between 1 and 2000 characters'),
  body('privacyLevel').optional().isIn(['public', 'followers', 'private'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const post = await Post.findByPk(req.params.id);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.userId !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to update this post' });
    }

    const updateData = {
      content: req.body.content,
      privacyLevel: req.body.privacyLevel || post.privacyLevel,
      compoundTags: req.body.compoundTags || post.compoundTags
    };

    await post.update(updateData);
    res.json(post);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a post
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    if (post.userId !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to delete this post' });
    }

    await post.destroy();
    res.json({ message: 'Post deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Like/unlike a post
router.post('/:id/like', authenticateToken, async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const existingLike = await Like.findOne({
      where: { postId: req.params.id, userId: req.user.id }
    });

    if (existingLike) {
      await existingLike.destroy();
      await post.decrementLikes();
      res.json({ liked: false, likesCount: post.likesCount - 1 });
    } else {
      await Like.create({
        postId: req.params.id,
        userId: req.user.id
      });
      await post.incrementLikes();
      res.json({ liked: true, likesCount: post.likesCount + 1 });
    }
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Add a comment to a post
router.post('/:id/comments', authenticateToken, [
  body('content').isLength({ min: 1, max: 500 }).withMessage('Comment must be between 1 and 500 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const post = await Post.findByPk(req.params.id);
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    const comment = await Comment.create({
      postId: req.params.id,
      userId: req.user.id,
      content: req.body.content
    });

    await post.incrementComments();

    // Include user data in response
    const commentWithUser = await Comment.findByPk(comment.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'username', 'fullName', 'avatarUrl']
      }]
    });

    res.status(201).json(commentWithUser);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router; 