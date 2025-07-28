const express = require('express');
const { body, validationResult } = require('express-validator');
const { Cycle, Compound, CycleCompound } = require('../models');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all cycles for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const cycles = await Cycle.findAll({
      where: { userId: req.user.id },
      include: [
        {
          model: Compound,
          as: 'compounds',
          through: { attributes: ['dosage', 'frequency', 'startDate', 'endDate', 'notes'] }
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(cycles);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Create a new cycle
router.post('/', authenticateToken, [
  body('name').isLength({ min: 1, max: 255 }).withMessage('Cycle name is required'),
  body('startDate').isISO8601().withMessage('Valid start date is required'),
  body('endDate').optional().isISO8601(),
  body('goals').optional().isArray(),
  body('notes').optional().isLength({ max: 2000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const cycleData = {
      userId: req.user.id,
      name: req.body.name,
      description: req.body.description,
      startDate: req.body.startDate,
      endDate: req.body.endDate,
      goals: req.body.goals || [],
      notes: req.body.notes,
      status: 'active'
    };

    const cycle = await Cycle.create(cycleData);

    // Add compounds if provided
    if (req.body.compounds && Array.isArray(req.body.compounds)) {
      for (const compoundData of req.body.compounds) {
        await CycleCompound.create({
          cycleId: cycle.id,
          compoundId: compoundData.compoundId,
          dosage: compoundData.dosage,
          frequency: compoundData.frequency,
          startDate: compoundData.startDate,
          endDate: compoundData.endDate,
          notes: compoundData.notes
        });
      }
    }

    // Return cycle with compounds
    const cycleWithCompounds = await Cycle.findByPk(cycle.id, {
      include: [
        {
          model: Compound,
          as: 'compounds',
          through: { attributes: ['dosage', 'frequency', 'startDate', 'endDate', 'notes'] }
        }
      ]
    });

    res.status(201).json(cycleWithCompounds);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Get a specific cycle
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const cycle = await Cycle.findOne({
      where: { id: req.params.id, userId: req.user.id },
      include: [
        {
          model: Compound,
          as: 'compounds',
          through: { attributes: ['dosage', 'frequency', 'startDate', 'endDate', 'notes'] }
        }
      ]
    });

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    res.json(cycle);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Update a cycle
router.put('/:id', authenticateToken, [
  body('name').optional().isLength({ min: 1, max: 255 }),
  body('startDate').optional().isISO8601(),
  body('endDate').optional().isISO8601(),
  body('status').optional().isIn(['active', 'completed', 'paused'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const cycle = await Cycle.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const allowedFields = ['name', 'description', 'startDate', 'endDate', 'goals', 'notes', 'status'];
    const updateData = {};
    
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    await cycle.update(updateData);

    // Return updated cycle with compounds
    const updatedCycle = await Cycle.findByPk(cycle.id, {
      include: [
        {
          model: Compound,
          as: 'compounds',
          through: { attributes: ['dosage', 'frequency', 'startDate', 'endDate', 'notes'] }
        }
      ]
    });

    res.json(updatedCycle);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete a cycle
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const cycle = await Cycle.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    await cycle.destroy();
    res.json({ message: 'Cycle deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Add compound to cycle
router.post('/:id/compounds', authenticateToken, [
  body('compoundId').isUUID().withMessage('Valid compound ID is required'),
  body('dosage').isFloat({ min: 0.1 }).withMessage('Valid dosage is required'),
  body('frequency').isLength({ min: 1, max: 100 }).withMessage('Frequency is required'),
  body('startDate').isISO8601().withMessage('Valid start date is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const cycle = await Cycle.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const cycleCompound = await CycleCompound.create({
      cycleId: req.params.id,
      compoundId: req.body.compoundId,
      dosage: req.body.dosage,
      frequency: req.body.frequency,
      startDate: req.body.startDate,
      endDate: req.body.endDate,
      notes: req.body.notes
    });

    res.status(201).json(cycleCompound);
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Remove compound from cycle
router.delete('/:id/compounds/:compoundId', authenticateToken, async (req, res) => {
  try {
    const cycleCompound = await CycleCompound.findOne({
      where: { 
        cycleId: req.params.id, 
        compoundId: req.params.compoundId 
      },
      include: [{
        model: Cycle,
        where: { userId: req.user.id }
      }]
    });

    if (!cycleCompound) {
      return res.status(404).json({ error: 'Cycle compound not found' });
    }

    await cycleCompound.destroy();
    res.json({ message: 'Compound removed from cycle' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router; 