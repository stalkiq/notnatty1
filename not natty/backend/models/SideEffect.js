const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const SideEffect = sequelize.define('SideEffect', {
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
    symptoms: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      allowNull: false
    },
    severity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    },
    bloodPressureSystolic: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 70,
        max: 200
      }
    },
    bloodPressureDiastolic: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 40,
        max: 130
      }
    },
    moodRating: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 10
      }
    },
    libidoRating: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 10
      }
    },
    acneSeverity: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 10
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    recordedAt: {
      type: DataTypes.DATE,
      allowNull: false
    }
  }, {
    tableName: 'side_effects',
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
        fields: ['recordedAt']
      },
      {
        fields: ['severity']
      }
    ]
  });

  return SideEffect;
}; 