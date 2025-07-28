const express = require('express');
const { body, validationResult } = require('express-validator');
const { Injection, Compound, Cycle } = require('../models');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all injections for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const injections = await Injection.findAll({
      where: { userId: req.user.id },
      include: [
        {
          model: Compound,
          as: 'compound',
          attributes: ['id', 'name', 'category', 'dosageUnit']
        },
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ],
      order: [['injectedAt', 'DESC']]
    });

    res.json(injections);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Create a new injection
router.post('/', authenticateToken, [
  body('compoundId').isUUID().withMessage('Valid compound ID is required'),
  body('dosage').isFloat({ min: 0.1 }).withMessage('Valid dosage is required'),
  body('injectionSite').isLength({ min: 1, max: 50 }).withMessage('Injection site is required'),
  body('injectedAt').isISO8601().withMessage('Valid injection date is required'),
  body('cycleId').optional().isUUID(),
  body('notes').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const injectionData = {
      userId: req.user.id,
      compoundId: req.body.compoundId,
      dosage: req.body.dosage,
      injectionSite: req.body.injectionSite,
      injectedAt: req.body.injectedAt,
      cycleId: req.body.cycleId || null,
      notes: req.body.notes
    };

    const injection = await Injection.create(injectionData);

    // Return injection with compound and cycle data
    const injectionWithDetails = await Injection.findByPk(injection.id, {
      include: [
        {
          model: Compound,
          as: 'compound',
          attributes: ['id', 'name', 'category', 'dosageUnit']
        },
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ]
    });

    res.status(201).json(injectionWithDetails);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get a specific injection
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const injection = await Injection.findOne({
      where: { id: req.params.id, userId: req.user.id },
      include: [
        {
          model: Compound,
          as: 'compound',
          attributes: ['id', 'name', 'category', 'dosageUnit', 'halfLifeHours']
        },
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status', 'startDate', 'endDate']
        }
      ]
    });

    if (!injection) {
      return res.status(404).json({ error: 'Injection not found' });
    }

    res.json(injection);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update an injection
router.put('/:id', authenticateToken, [
  body('dosage').optional().isFloat({ min: 0.1 }),
  body('injectionSite').optional().isLength({ min: 1, max: 50 }),
  body('injectedAt').optional().isISO8601(),
  body('notes').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const injection = await Injection.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!injection) {
      return res.status(404).json({ error: 'Injection not found' });
    }

    const allowedFields = ['dosage', 'injectionSite', 'injectedAt', 'notes'];
    const updateData = {};
    
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    await injection.update(updateData);

    // Return updated injection with details
    const updatedInjection = await Injection.findByPk(injection.id, {
      include: [
        {
          model: Compound,
          as: 'compound',
          attributes: ['id', 'name', 'category', 'dosageUnit']
        },
        {
          model: Cycle,
          as: 'cycle',
          attributes: ['id', 'name', 'status']
        }
      ]
    });

    res.json(updatedInjection);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete an injection
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const injection = await Injection.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!injection) {
      return res.status(404).json({ error: 'Injection not found' });
    }

    await injection.destroy();
    res.json({ message: 'Injection deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get injections by cycle
router.get('/cycle/:cycleId', authenticateToken, async (req, res) => {
  try {
    const injections = await Injection.findAll({
      where: { 
        userId: req.user.id,
        cycleId: req.params.cycleId
      },
      include: [
        {
          model: Compound,
          as: 'compound',
          attributes: ['id', 'name', 'category', 'dosageUnit']
        }
      ],
      order: [['injectedAt', 'DESC']]
    });

    res.json(injections);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get injection statistics
router.get('/stats/summary', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const whereClause = { userId: req.user.id };
    
    if (startDate && endDate) {
      whereClause.injectedAt = {
        [require('sequelize').Op.between]: [startDate, endDate]
      };
    }

    const totalInjections = await Injection.count({ where: whereClause });
    
    const injectionsByCompound = await Injection.findAll({
      where: whereClause,
      include: [{
        model: Compound,
        as: 'compound',
        attributes: ['name', 'category']
      }],
      attributes: [
        'compoundId',
        [require('sequelize').fn('COUNT', require('sequelize').col('id')), 'count']
      ],
      group: ['compoundId', 'compound.id'],
      order: [[require('sequelize').fn('COUNT', require('sequelize').col('id')), 'DESC']]
    });

    res.json({
      totalInjections,
      injectionsByCompound
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router; 