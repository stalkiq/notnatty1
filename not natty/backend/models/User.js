const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        len: [3, 50],
        is: /^[a-zA-Z0-9_]+$/
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    fullName: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    avatarUrl: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    heightCm: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: {
        min: 100,
        max: 250
      }
    },
    weightKg: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
      validate: {
        min: 30,
        max: 300
      }
    },
    dateOfBirth: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    verificationStatus: {
      type: DataTypes.ENUM('unverified', 'pending', 'verified'),
      defaultValue: 'unverified'
    },
    profileData: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    settings: {
      type: DataTypes.JSONB,
      defaultValue: {
        privacy: {
          profileVisibility: 'public',
          cycleVisibility: 'followers',
          postVisibility: 'public'
        },
        notifications: {
          newFollowers: true,
          likes: true,
          comments: true,
          cycleReminders: true
        },
        units: {
          weight: 'kg',
          dosage: 'mg',
          height: 'cm'
        }
      }
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    lastLoginAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    emailVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    emailVerificationToken: {
      type: DataTypes.STRING,
      allowNull: true
    },
    emailVerificationExpires: {
      type: DataTypes.DATE,
      allowNull: true
    },
    passwordResetToken: {
      type: DataTypes.STRING,
      allowNull: true
    },
    passwordResetExpires: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'users',
    timestamps: true,
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
    indexes: [
      {
        unique: true,
        fields: ['email']
      },
      {
        unique: true,
        fields: ['username']
      },
      {
        fields: ['verificationStatus']
      },
      {
        fields: ['isActive']
      }
    ]
  });

  // Instance methods
  User.prototype.toJSON = function() {
    const values = Object.assign({}, this.get());
    delete values.password;
    return values;
  };

  User.prototype.getPublicProfile = function() {
    const values = this.toJSON();
    // Remove sensitive information for public profiles
    delete values.email;
    delete values.settings;
    delete values.profileData;
    return values;
  };

  // Class methods
  User.findByEmail = function(email) {
    return this.findOne({ where: { email } });
  };

  User.findByUsername = function(username) {
    return this.findOne({ where: { username } });
  };

  User.findVerified = function() {
    return this.findAll({ 
      where: { verificationStatus: 'verified' },
      attributes: { exclude: ['password', 'email', 'settings'] }
    });
  };

  return User;
}; 