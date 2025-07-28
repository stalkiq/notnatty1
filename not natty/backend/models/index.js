const { Sequelize } = require('sequelize');
require('dotenv').config();

// Database configuration
const sequelize = new Sequelize(process.env.DATABASE_URL || {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'not_natty_db',
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  dialect: 'postgres',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

// Import models
const User = require('./User')(sequelize);
const Post = require('./Post')(sequelize);
const Comment = require('./Comment')(sequelize);
const Like = require('./Like')(sequelize);
const Cycle = require('./Cycle')(sequelize);
const Compound = require('./Compound')(sequelize);
const CycleCompound = require('./CycleCompound')(sequelize);
const Injection = require('./Injection')(sequelize);
const SideEffect = require('./SideEffect')(sequelize);
const Follower = require('./Follower')(sequelize);
const Notification = require('./Notification')(sequelize);

// Define associations
User.hasMany(Post, { foreignKey: 'userId', as: 'posts' });
Post.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Comment, { foreignKey: 'userId', as: 'comments' });
Comment.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Post.hasMany(Comment, { foreignKey: 'postId', as: 'comments' });
Comment.belongsTo(Post, { foreignKey: 'postId', as: 'post' });

User.hasMany(Like, { foreignKey: 'userId', as: 'likes' });
Like.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Post.hasMany(Like, { foreignKey: 'postId', as: 'likes' });
Like.belongsTo(Post, { foreignKey: 'postId', as: 'post' });

User.hasMany(Cycle, { foreignKey: 'userId', as: 'cycles' });
Cycle.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Cycle.belongsToMany(Compound, { through: CycleCompound, foreignKey: 'cycleId', as: 'compounds' });
Compound.belongsToMany(Cycle, { through: CycleCompound, foreignKey: 'compoundId', as: 'cycles' });

User.hasMany(Injection, { foreignKey: 'userId', as: 'injections' });
Injection.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Cycle.hasMany(Injection, { foreignKey: 'cycleId', as: 'injections' });
Injection.belongsTo(Cycle, { foreignKey: 'cycleId', as: 'cycle' });

Compound.hasMany(Injection, { foreignKey: 'compoundId', as: 'injections' });
Injection.belongsTo(Compound, { foreignKey: 'compoundId', as: 'compound' });

User.hasMany(SideEffect, { foreignKey: 'userId', as: 'sideEffects' });
SideEffect.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Cycle.hasMany(SideEffect, { foreignKey: 'cycleId', as: 'sideEffects' });
SideEffect.belongsTo(Cycle, { foreignKey: 'cycleId', as: 'cycle' });

// Followers relationship
User.belongsToMany(User, { 
  through: Follower, 
  as: 'followers', 
  foreignKey: 'followingId',
  otherKey: 'followerId'
});
User.belongsToMany(User, { 
  through: Follower, 
  as: 'following', 
  foreignKey: 'followerId',
  otherKey: 'followingId'
});

User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Test database connection
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully.');
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
  }
};

// Sync database (create tables)
const syncDatabase = async (force = false) => {
  try {
    await sequelize.sync({ force });
    console.log('✅ Database synchronized successfully.');
  } catch (error) {
    console.error('❌ Error synchronizing database:', error);
  }
};

module.exports = {
  sequelize,
  User,
  Post,
  Comment,
  Like,
  Cycle,
  Compound,
  CycleCompound,
  Injection,
  SideEffect,
  Follower,
  Notification,
  testConnection,
  syncDatabase
}; 