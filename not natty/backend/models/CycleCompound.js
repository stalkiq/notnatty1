const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const CycleCompound = sequelize.define('CycleCompound', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    cycleId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'cycles',
        key: 'id'
      }
    },
    compoundId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'compounds',
        key: 'id'
      }
    },
    dosage: {
      type: DataTypes.DECIMAL(8, 2),
      allowNull: false
    },
    frequency: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    startDate: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    endDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'cycle_compounds',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: false,
    indexes: [
      {
        unique: true,
        fields: ['cycleId', 'compoundId']
      },
      {
        fields: ['cycleId']
      },
      {
        fields: ['compoundId']
      }
    ]
  });

  return CycleCompound;
}; 