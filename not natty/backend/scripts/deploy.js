const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Starting deployment preparation...');

// Check if we're in production
const isProduction = process.env.NODE_ENV === 'production';

if (isProduction) {
  console.log('📦 Production environment detected');
  
  // Create necessary directories
  const dirs = ['logs', 'uploads'];
  dirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`✅ Created directory: ${dir}`);
    }
  });
  
  // Set proper permissions
  try {
    execSync('chmod +x server.js');
    console.log('✅ Set executable permissions on server.js');
  } catch (error) {
    console.log('⚠️ Could not set permissions (this is normal in some environments)');
  }
}

console.log('✅ Deployment preparation completed'); 