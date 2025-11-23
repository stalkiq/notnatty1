const validateRegistration = (req, res, next) => {
  const { email, username, password, fullName } = req.body;

  // Validate email
  if (!email || !email.includes('@')) {
    return res.status(400).json({
      error: 'Invalid email',
      message: 'Please provide a valid email address'
    });
  }

  // Validate username
  if (!username || username.length < 3 || username.length > 20) {
    return res.status(400).json({
      error: 'Invalid username',
      message: 'Username must be between 3 and 20 characters'
    });
  }

  // Validate password
  if (!password || password.length < 8) {
    return res.status(400).json({
      error: 'Invalid password',
      message: 'Password must be at least 8 characters long'
    });
  }

  // Validate fullName (optional)
  if (fullName && fullName.length > 100) {
    return res.status(400).json({
      error: 'Invalid full name',
      message: 'Full name must be less than 100 characters'
    });
  }

  next();
};

const validateLogin = (req, res, next) => {
  const { email, password } = req.body;

  // Validate email
  if (!email || !email.includes('@')) {
    return res.status(400).json({
      error: 'Invalid email',
      message: 'Please provide a valid email address'
    });
  }

  // Validate password
  if (!password) {
    return res.status(400).json({
      error: 'Missing password',
      message: 'Password is required'
    });
  }

  next();
};

module.exports = {
  validateRegistration,
  validateLogin
}; 