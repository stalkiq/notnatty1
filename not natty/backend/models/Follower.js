const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Follower = sequelize.define('Follower', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    followerId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    followingId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    }
  }, {
    tableName: 'followers',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: false,
    indexes: [
      {
        unique: true,
        fields: ['followerId', 'followingId']
      },
      {
        fields: ['followerId']
      },
      {
        fields: ['followingId']
      }
    ]
  });

  return Follower;
}; 