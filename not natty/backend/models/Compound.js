const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Compound = sequelize.define('Compound', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true
    },
    category: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    halfLifeHours: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    dosageUnit: {
      type: DataTypes.STRING(20),
      defaultValue: 'mg'
    }
  }, {
    tableName: 'compounds',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: false,
    indexes: [
      {
        unique: true,
        fields: ['name']
      },
      {
        fields: ['category']
      }
    ]
  });

  return Compound;
}; 