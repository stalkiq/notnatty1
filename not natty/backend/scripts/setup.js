const { testConnection, syncDatabase } = require('../models');
const { User, Compound } = require('../models');
const bcrypt = require('bcryptjs');

const setupDatabase = async () => {
  try {
    console.log('🔧 Setting up Not Natty database...');
    
    // Test connection
    await testConnection();
    
    // Sync database (create tables)
    await syncDatabase(true); // force: true will drop existing tables
    
    console.log('✅ Database tables created successfully');
    
    // Create default compounds
    const defaultCompounds = [
      { name: 'Testosterone Enanthate', category: 'Testosterone', halfLifeHours: 168, dosageUnit: 'mg' },
      { name: 'Testosterone Cypionate', category: 'Testosterone', halfLifeHours: 168, dosageUnit: 'mg' },
      { name: 'Testosterone Propionate', category: 'Testosterone', halfLifeHours: 48, dosageUnit: 'mg' },
      { name: 'Nandrolone Decanoate', category: 'Nandrolone', halfLifeHours: 336, dosageUnit: 'mg' },
      { name: 'Nandrolone Phenylpropionate', category: 'Nandrolone', halfLifeHours: 72, dosageUnit: 'mg' },
      { name: 'Boldenone Undecylenate', category: 'Boldenone', halfLifeHours: 336, dosageUnit: 'mg' },
      { name: 'Trenbolone Acetate', category: 'Trenbolone', halfLifeHours: 72, dosageUnit: 'mg' },
      { name: 'Trenbolone Enanthate', category: 'Trenbolone', halfLifeHours: 168, dosageUnit: 'mg' },
      { name: 'Methandrostenolone', category: 'Oral', halfLifeHours: 6, dosageUnit: 'mg' },
      { name: 'Oxandrolone', category: 'Oral', halfLifeHours: 8, dosageUnit: 'mg' },
      { name: 'Stanozolol', category: 'Oral', halfLifeHours: 9, dosageUnit: 'mg' },
      { name: 'Anastrozole', category: 'AI', halfLifeHours: 46, dosageUnit: 'mg' },
      { name: 'Letrozole', category: 'AI', halfLifeHours: 48, dosageUnit: 'mg' },
      { name: 'Tamoxifen', category: 'SERM', halfLifeHours: 168, dosageUnit: 'mg' },
      { name: 'Clomiphene', category: 'SERM', halfLifeHours: 120, dosageUnit: 'mg' },
      { name: 'Human Chorionic Gonadotropin', category: 'HCG', halfLifeHours: 24, dosageUnit: 'IU' }
    ];
    
    for (const compound of defaultCompounds) {
      await Compound.findOrCreate({
        where: { name: compound.name },
        defaults: compound
      });
    }
    
    console.log('✅ Default compounds created successfully');
    
    // Create a test user
    const hashedPassword = await bcrypt.hash('password123', 12);
    await User.findOrCreate({
      where: { email: 'test@example.com' },
      defaults: {
        email: 'test@example.com',
        username: 'testuser',
        password: hashedPassword,
        fullName: 'Test User',
        verificationStatus: 'verified'
      }
    });
    
    console.log('✅ Test user created successfully');
    console.log('📧 Email: test@example.com');
    console.log('🔑 Password: password123');
    
    console.log('\n🎉 Database setup completed successfully!');
    console.log('🚀 You can now start the server with: npm run dev');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error);
    process.exit(1);
  }
};

// Run setup if this file is executed directly
if (require.main === module) {
  setupDatabase();
}

module.exports = setupDatabase; 