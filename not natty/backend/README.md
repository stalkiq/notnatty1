# Not Natty Backend

Node.js/Express backend API for the Not Natty iOS app.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp env.example .env
   # Edit .env with your database credentials
   ```

3. **Install PostgreSQL:**
   - **macOS**: Download from https://www.postgresql.org/download/macosx/
   - **Windows**: Download from https://www.postgresql.org/download/windows/
   - **Linux**: `sudo apt install postgresql postgresql-contrib`

4. **Create database:**
   ```bash
   # Connect to PostgreSQL
   psql -U postgres
   
   # Create database and user
   CREATE DATABASE not_natty_db;
   CREATE USER not_natty_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE not_natty_db TO not_natty_user;
   \q
   ```

5. **Update .env file:**
   ```env
   DATABASE_URL=postgresql://not_natty_user:your_password@localhost:5432/not_natty_db
   JWT_SECRET=your_super_secret_jwt_key_here
   ```

6. **Set up database:**
   ```bash
   npm run setup
   ```

7. **Start development server:**
   ```bash
   npm run dev
   ```

## 📋 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Logout user

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `GET /api/users/verified` - Get verified users

### Posts
- `GET /api/posts` - Get posts (with pagination)
- `POST /api/posts` - Create new post
- `GET /api/posts/:id` - Get specific post
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post

### Cycles
- `GET /api/cycles` - Get user cycles
- `POST /api/cycles` - Create new cycle
- `GET /api/cycles/:id` - Get specific cycle
- `PUT /api/cycles/:id` - Update cycle
- `DELETE /api/cycles/:id` - Delete cycle

### Injections
- `GET /api/injections` - Get user injections
- `POST /api/injections` - Log new injection
- `GET /api/injections/:id` - Get specific injection
- `PUT /api/injections/:id` - Update injection
- `DELETE /api/injections/:id` - Delete injection

### Side Effects
- `GET /api/side-effects` - Get user side effects
- `POST /api/side-effects` - Log new side effect
- `GET /api/side-effects/:id` - Get specific side effect
- `PUT /api/side-effects/:id` - Update side effect
- `DELETE /api/side-effects/:id` - Delete side effect

## 🔧 Development

### Database Models
- `User` - User accounts and profiles
- `Post` - Social media posts
- `Comment` - Post comments
- `Like` - Post likes
- `Cycle` - Steroid cycles
- `Compound` - Steroid compounds
- `Injection` - Injection logs
- `SideEffect` - Side effect logs
- `Follower` - User relationships
- `Notification` - User notifications

### Environment Variables
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/database
JWT_SECRET=your_jwt_secret
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_S3_BUCKET=your_bucket_name
```

### Testing
```bash
npm test
```

## 🚀 Deployment

### Railway (Recommended)
1. Connect GitHub repository to Railway
2. Add PostgreSQL service
3. Set environment variables
4. Deploy automatically

### Heroku
```bash
heroku create not-natty-backend
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
```

### AWS
- EC2 for server
- RDS for database
- S3 for file storage

## 📊 Health Check

Visit `http://localhost:3000/health` to check if the server is running.

## 🔒 Security

- JWT authentication
- Password hashing with bcrypt
- Rate limiting
- Input validation
- CORS configuration
- Helmet.js security headers

## 📝 License

MIT License 