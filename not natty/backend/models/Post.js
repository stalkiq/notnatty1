const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Post = sequelize.define('Post', {
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
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        len: [1, 5000]
      }
    },
    postType: {
      type: DataTypes.ENUM('progress', 'cycle', 'motivation', 'question', 'achievement'),
      allowNull: false,
      defaultValue: 'progress'
    },
    privacyLevel: {
      type: DataTypes.ENUM('public', 'followers', 'private'),
      defaultValue: 'public'
    },
    compoundTags: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: []
    },
    mediaUrls: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      defaultValue: []
    },
    likesCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    commentsCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    }
  }, {
    tableName: 'posts',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
    indexes: [
      {
        fields: ['userId']
      },
      {
        fields: ['createdAt']
      },
      {
        fields: ['postType']
      },
      {
        fields: ['privacyLevel']
      }
    ]
  });

  // Instance methods
  Post.prototype.incrementLikes = async function() {
    this.likesCount += 1;
    return await this.save();
  };

  Post.prototype.decrementLikes = async function() {
    this.likesCount = Math.max(0, this.likesCount - 1);
    return await this.save();
  };

  Post.prototype.incrementComments = async function() {
    this.commentsCount += 1;
    return await this.save();
  };

  Post.prototype.decrementComments = async function() {
    this.commentsCount = Math.max(0, this.commentsCount - 1);
    return await this.save();
  };

  // Class methods
  Post.findPublicPosts = function(limit = 20, offset = 0) {
    return this.findAll({
      where: { privacyLevel: 'public' },
      include: [
        {
          model: sequelize.models.User,
          as: 'user',
          attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
        }
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset
    });
  };

  Post.findByUser = function(userId, limit = 20, offset = 0) {
    return this.findAll({
      where: { userId },
      include: [
        {
          model: sequelize.models.User,
          as: 'user',
          attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
        }
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset
    });
  };

  Post.findByType = function(postType, limit = 20, offset = 0) {
    return this.findAll({
      where: { 
        postType,
        privacyLevel: 'public'
      },
      include: [
        {
          model: sequelize.models.User,
          as: 'user',
          attributes: ['id', 'username', 'fullName', 'avatarUrl', 'verificationStatus']
        }
      ],
      order: [['createdAt', 'DESC']],
      limit,
      offset
    });
  };

  return Post;
}; 