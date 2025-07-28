const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Injection = sequelize.define('Injection', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    cycleId: {
      type: DataTypes.UUID,
      allowNull: true,
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
    injectionSite: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    injectedAt: {
      type: DataTypes.DATE,
      allowNull: false
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'injections',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: false,
    indexes: [
      {
        fields: ['userId']
      },
      {
        fields: ['cycleId']
      },
      {
        fields: ['compoundId']
      },
      {
        fields: ['injectedAt']
      }
    ]
  });

  return Injection;
}; 