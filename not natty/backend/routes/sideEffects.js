const express = require('express');
const { body, validationResult } = require('express-validator');
const { SideEffect, Cycle } = require('../models');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all side effects for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const sideEffects = await SideEffect.findAll({
      where: { userId: req.user.id },
      include: [
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ],
      order: [['recordedAt', 'DESC']]
    });

    res.json(sideEffects);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Create a new side effect
router.post('/', authenticateToken, [
  body('symptoms').isArray({ min: 1 }).withMessage('At least one symptom is required'),
  body('severity').isInt({ min: 1, max: 10 }).withMessage('Severity must be between 1 and 10'),
  body('recordedAt').isISO8601().withMessage('Valid recording date is required'),
  body('cycleId').optional().isUUID(),
  body('bloodPressureSystolic').optional().isInt({ min: 70, max: 200 }),
  body('bloodPressureDiastolic').optional().isInt({ min: 40, max: 130 }),
  body('moodRating').optional().isInt({ min: 1, max: 10 }),
  body('libidoRating').optional().isInt({ min: 1, max: 10 }),
  body('acneSeverity').optional().isInt({ min: 1, max: 10 }),
  body('notes').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const sideEffectData = {
      userId: req.user.id,
      symptoms: req.body.symptoms,
      severity: req.body.severity,
      recordedAt: req.body.recordedAt,
      cycleId: req.body.cycleId || null,
      bloodPressureSystolic: req.body.bloodPressureSystolic,
      bloodPressureDiastolic: req.body.bloodPressureDiastolic,
      moodRating: req.body.moodRating,
      libidoRating: req.body.libidoRating,
      acneSeverity: req.body.acneSeverity,
      notes: req.body.notes
    };

    const sideEffect = await SideEffect.create(sideEffectData);

    // Return side effect with cycle data
    const sideEffectWithDetails = await SideEffect.findByPk(sideEffect.id, {
      include: [
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ]
    });

    res.status(201).json(sideEffectWithDetails);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get a specific side effect
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const sideEffect = await SideEffect.findOne({
      where: { id: req.params.id, userId: req.user.id },
      include: [
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status', 'startDate', 'endDate']
        }
      ]
    });

    if (!sideEffect) {
      return res.status(404).json({ error: 'Side effect not found' });
    }

    res.json(sideEffect);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update a side effect
router.put('/:id', authenticateToken, [
  body('symptoms').optional().isArray({ min: 1 }),
  body('severity').optional().isInt({ min: 1, max: 10 }),
  body('bloodPressureSystolic').optional().isInt({ min: 70, max: 200 }),
  body('bloodPressureDiastolic').optional().isInt({ min: 40, max: 130 }),
  body('moodRating').optional().isInt({ min: 1, max: 10 }),
  body('libidoRating').optional().isInt({ min: 1, max: 10 }),
  body('acneSeverity').optional().isInt({ min: 1, max: 10 }),
  body('notes').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const sideEffect = await SideEffect.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!sideEffect) {
      return res.status(404).json({ error: 'Side effect not found' });
    }

    const allowedFields = [
      'symptoms', 'severity', 'bloodPressureSystolic', 'bloodPressureDiastolic',
      'moodRating', 'libidoRating', 'acneSeverity', 'notes'
    ];
    const updateData = {};
    
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    await sideEffect.update(updateData);

    // Return updated side effect with details
    const updatedSideEffect = await SideEffect.findByPk(sideEffect.id, {
      include: [
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ]
    });

    res.json(updatedSideEffect);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a side effect
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const sideEffect = await SideEffect.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!sideEffect) {
      return res.status(404).json({ error: 'Side effect not found' });
    }

    await sideEffect.destroy();
    res.json({ message: 'Side effect deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get side effects by cycle
router.get('/cycle/:cycleId', authenticateToken, async (req, res) => {
  try {
    const sideEffects = await SideEffect.findAll({
      where: { 
        userId: req.user.id,
        cycleId: req.params.cycleId
      },
      order: [['recordedAt', 'DESC']]
    });

    res.json(sideEffects);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get side effect statistics
router.get('/stats/summary', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const whereClause = { userId: req.user.id };
    
    if (startDate && endDate) {
      whereClause.recordedAt = {
        [require('sequelize').Op.between]: [startDate, endDate]
      };
    }

    const totalSideEffects = await SideEffect.count({ where: whereClause });
    
    const averageSeverity = await SideEffect.findOne({
      where: whereClause,
      attributes: [
        [require('sequelize').fn('AVG', require('sequelize').col('severity')), 'avgSeverity']
      ]
    });

    const symptomsFrequency = await SideEffect.findAll({
      where: whereClause,
      attributes: [
        'symptoms',
        [require('sequelize').fn('COUNT', require('sequelize').col('id')), 'count']
      ],
      group: ['symptoms'],
      order: [[require('sequelize').fn('COUNT', require('sequelize').col('id')), 'DESC']]
    });

    res.json({
      totalSideEffects,
      averageSeverity: parseFloat(averageSeverity?.dataValues?.avgSeverity || 0),
      symptomsFrequency
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router; 