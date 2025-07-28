# Not Natty Backend Setup Guide

## 🚀 Quick Start Options

### Option 1: Firebase (Easiest - 30 minutes)
Firebase provides a complete backend solution with minimal setup.

**Pros:**
- No server management
- Built-in authentication
- Real-time database
- File storage
- Push notifications
- Free tier available

**Setup Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project
3. Enable Authentication (Email/Password)
4. Create Firestore Database
5. Enable Storage
6. Get configuration and add to iOS app

### Option 2: Node.js/Express + PostgreSQL (Recommended - 2 hours)
Full control over your backend with professional features.

**Pros:**
- Complete control
- Scalable
- Professional features
- Cost-effective at scale

## 📋 Prerequisites

### For Node.js Backend:
- Node.js 18+ installed
- PostgreSQL 14+ installed
- Git
- Code editor (VS Code recommended)

### For Firebase:
- Google account
- Firebase CLI (optional)

## 🛠️ Node.js Backend Setup

### 1. Database Setup

**Install PostgreSQL:**
```bash
# macOS (using Homebrew)
brew install postgresql
brew services start postgresql

# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Create Database:**
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE not_natty_db;
CREATE USER not_natty_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE not_natty_db TO not_natty_user;
\q
```

**Run Schema:**
```bash
psql -U not_natty_user -d not_natty_db -f backend-schema.sql
```

### 2. Backend Setup

**Navigate to backend directory:**
```bash
cd backend
```

**Install dependencies:**
```bash
npm install
```

**Environment Configuration:**
```bash
# Copy environment template
cp env.example .env

# Edit .env with your values
nano .env
```

**Required .env values:**
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://not_natty_user:your_secure_password@localhost:5432/not_natty_db
JWT_SECRET=your_super_secret_jwt_key_here
```

### 3. Start Development Server

```bash
# Development mode with auto-restart
npm run dev

# Production mode
npm start
```

**Verify Setup:**
- Visit: `http://localhost:3000/health`
- Should return: `{"status":"OK","timestamp":"...","environment":"development"}`

## 🔧 iOS App Integration

### 1. Update iOS App Configuration

**Create API Service:**
```swift
// Add to your iOS project
class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000/api"
    
    func login(email: String, password: String) async throws -> AuthResponse {
        // Implementation
    }
    
    func register(email: String, username: String, password: String) async throws -> AuthResponse {
        // Implementation
    }
    
    // Add other API methods
}
```

**Update Managers:**
```swift
// Update AuthManager to use real API
class AuthManager: ObservableObject {
    func signIn(email: String, password: String) async {
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            // Handle successful login
        } catch {
            // Handle error
        }
    }
}
```

### 2. Environment Configuration

**Development:**
- Backend: `http://localhost:3000`
- Database: Local PostgreSQL

**Production:**
- Backend: Your hosted server (Heroku, AWS, etc.)
- Database: Cloud PostgreSQL (AWS RDS, etc.)

## 🌐 Deployment Options

### Option A: Heroku (Easy)
```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login to Heroku
heroku login

# Create app
heroku create not-natty-backend

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Deploy
git add .
git commit -m "Initial backend deployment"
git push heroku main
```

### Option B: Railway (Recommended)
1. Go to [Railway](https://railway.app/)
2. Connect GitHub repository
3. Add PostgreSQL service
4. Deploy automatically

### Option C: AWS (Professional)
- EC2 for server
- RDS for database
- S3 for file storage
- CloudFront for CDN

## 🔒 Security Considerations

### 1. Environment Variables
- Never commit `.env` files
- Use strong JWT secrets
- Rotate secrets regularly

### 2. Database Security
- Use strong passwords
- Enable SSL connections
- Regular backups
- Access control

### 3. API Security
- Rate limiting enabled
- Input validation
- CORS configuration
- Helmet.js for headers

## 📊 Monitoring & Logging

### 1. Application Monitoring
```bash
# Add monitoring packages
npm install winston morgan

# Configure logging
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### 2. Database Monitoring
- Enable PostgreSQL logging
- Monitor slow queries
- Set up alerts for errors

## 🧪 Testing

### 1. API Testing
```bash
# Install testing tools
npm install --save-dev jest supertest

# Run tests
npm test
```

### 2. Load Testing
```bash
# Install load testing tool
npm install -g artillery

# Run load test
artillery quick --count 100 --num 10 http://localhost:3000/api/health
```

## 📱 Push Notifications

### 1. Firebase Cloud Messaging
```bash
# Install FCM
npm install firebase-admin

# Configure FCM
const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'your-project-id'
});
```

### 2. iOS Integration
- Add FCM SDK to iOS app
- Handle device tokens
- Send notifications from backend

## 🔄 CI/CD Pipeline

### GitHub Actions Example:
```yaml
name: Deploy Backend
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Railway
        run: |
          # Deploy commands
```

## 📈 Performance Optimization

### 1. Database Optimization
- Add indexes for frequent queries
- Use connection pooling
- Implement caching (Redis)

### 2. API Optimization
- Implement pagination
- Use compression
- Cache responses
- Optimize images

## 🆘 Troubleshooting

### Common Issues:

**1. Database Connection Failed**
```bash
# Check PostgreSQL status
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql
```

**2. Port Already in Use**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

**3. JWT Token Issues**
- Check JWT_SECRET in .env
- Verify token expiration
- Check token format in requests

## 📞 Support

For backend setup issues:
1. Check logs: `npm run dev`
2. Verify database connection
3. Test API endpoints with Postman
4. Check environment variables

## 🎯 Next Steps

1. **Complete API Routes**: Implement all CRUD operations
2. **Add File Upload**: Configure S3/Cloudinary
3. **Real-time Features**: Add WebSocket support
4. **Analytics**: Implement user analytics
5. **Testing**: Add comprehensive test suite
6. **Documentation**: Generate API documentation 