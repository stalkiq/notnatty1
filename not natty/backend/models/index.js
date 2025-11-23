const { Sequelize } = require('sequelize');
require('dotenv').config();

// Create Sequelize instance
const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

// Test the connection
sequelize.authenticate()
  .then(() => {
    console.log('✅ Database connection established successfully.');
  })
  .catch(err => {
    console.error('❌ Unable to connect to the database:', err);
  });

// Import models
const User = require('./User')(sequelize, Sequelize.DataTypes);

// Define associations here if needed
// User.hasMany(Post, { foreignKey: 'userId' });

// Sync models with database
sequelize.sync({ alter: true })
  .then(() => {
    console.log('✅ Database models synchronized.');
  })
  .catch(err => {
    console.error('❌ Error synchronizing database models:', err);
  });

module.exports = {
  sequelize,
  User
}; 