const express = require('express');
const router = express.Router();

// Get notifications
router.get('/', (req, res) => {
  res.json({ message: 'Get notifications endpoint' });
});

module.exports = router; 