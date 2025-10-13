// SECURITY FIX #3: Input Validation & Sanitization
// This script provides comprehensive input validation and sanitization

class InputValidator {
  constructor() {
    this.patterns = {
      username: /^[a-zA-Z0-9_]{3,20}$/,
      email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      phone: /^[\+]?[0-9\s\-\(\)]{8,15}$/,
      password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/,
      product: /^[a-zA-Z0-9\s\-\.\,\u0600-\u06FF]{2,100}$/, // Arabic + English
      location: /^[a-zA-Z0-9\s\-\.\,\u0600-\u06FF]{2,100}$/,
      quantity: /^[0-9]+(\.[0-9]+)?\s*[a-zA-Z\u0600-\u06FF]*$/,
      price: /^[0-9]+(\.[0-9]+)?\s*[a-zA-Z\u0600-\u06FF]*$/
    };
    
    this.maxLengths = {
      username: 20,
      email: 100,
      phone: 15,
      password: 128,
      product: 100,
      location: 100,
      quantity: 50,
      price: 50,
      description: 500,
      fullName: 100
    };
  }

  // Sanitize input to prevent XSS
  sanitize(input) {
    if (typeof input !== 'string') return input;
    
    return input
      .trim()
      .replace(/[<>\"']/g, '') // Remove dangerous characters
      .replace(/javascript:/gi, '') // Remove javascript: protocol
      .replace(/on\w+=/gi, '') // Remove event handlers
      .substring(0, 1000); // Limit length
  }

  // Validate username
  validateUsername(username) {
    const sanitized = this.sanitize(username);
    
    if (!sanitized) {
      return { valid: false, error: 'Username is required' };
    }
    
    if (sanitized.length < 3 || sanitized.length > this.maxLengths.username) {
      return { valid: false, error: 'Username must be 3-20 characters' };
    }
    
    if (!this.patterns.username.test(sanitized)) {
      return { valid: false, error: 'Username can only contain letters, numbers, and underscores' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate email
  validateEmail(email) {
    if (!email) return { valid: true, value: null }; // Email is optional
    
    const sanitized = this.sanitize(email);
    
    if (sanitized.length > this.maxLengths.email) {
      return { valid: false, error: 'Email is too long' };
    }
    
    if (!this.patterns.email.test(sanitized)) {
      return { valid: false, error: 'Please enter a valid email address' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate phone
  validatePhone(phone) {
    if (!phone) return { valid: true, value: null }; // Phone is optional
    
    const sanitized = this.sanitize(phone);
    
    if (sanitized.length > this.maxLengths.phone) {
      return { valid: false, error: 'Phone number is too long' };
    }
    
    if (!this.patterns.phone.test(sanitized)) {
      return { valid: false, error: 'Please enter a valid phone number' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate password
  validatePassword(password) {
    const sanitized = this.sanitize(password);
    
    if (!sanitized) {
      return { valid: false, error: 'Password is required' };
    }
    
    if (sanitized.length < 8) {
      return { valid: false, error: 'Password must be at least 8 characters' };
    }
    
    if (sanitized.length > this.maxLengths.password) {
      return { valid: false, error: 'Password is too long' };
    }
    
    if (!this.patterns.password.test(sanitized)) {
      return { valid: false, error: 'Password must contain uppercase, lowercase, and number' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate full name
  validateFullName(fullName) {
    const sanitized = this.sanitize(fullName);
    
    if (!sanitized) {
      return { valid: false, error: 'Full name is required' };
    }
    
    if (sanitized.length < 2 || sanitized.length > this.maxLengths.fullName) {
      return { valid: false, error: 'Full name must be 2-100 characters' };
    }
    
    // Allow letters, spaces, hyphens, and Arabic characters
    if (!/^[a-zA-Z\s\-\u0600-\u06FF]+$/.test(sanitized)) {
      return { valid: false, error: 'Full name can only contain letters, spaces, and hyphens' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate product name
  validateProduct(product) {
    const sanitized = this.sanitize(product);
    
    if (!sanitized) {
      return { valid: false, error: 'Product name is required' };
    }
    
    if (sanitized.length < 2 || sanitized.length > this.maxLengths.product) {
      return { valid: false, error: 'Product name must be 2-100 characters' };
    }
    
    if (!this.patterns.product.test(sanitized)) {
      return { valid: false, error: 'Product name contains invalid characters' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate location
  validateLocation(location) {
    const sanitized = this.sanitize(location);
    
    if (!sanitized) {
      return { valid: false, error: 'Location is required' };
    }
    
    if (sanitized.length < 2 || sanitized.length > this.maxLengths.location) {
      return { valid: false, error: 'Location must be 2-100 characters' };
    }
    
    if (!this.patterns.location.test(sanitized)) {
      return { valid: false, error: 'Location contains invalid characters' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate quantity
  validateQuantity(quantity) {
    if (!quantity) return { valid: true, value: null }; // Quantity is optional
    
    const sanitized = this.sanitize(quantity);
    
    if (sanitized.length > this.maxLengths.quantity) {
      return { valid: false, error: 'Quantity is too long' };
    }
    
    if (!this.patterns.quantity.test(sanitized)) {
      return { valid: false, error: 'Please enter a valid quantity' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate price
  validatePrice(price) {
    if (!price) return { valid: true, value: null }; // Price is optional
    
    const sanitized = this.sanitize(price);
    
    if (sanitized.length > this.maxLengths.price) {
      return { valid: false, error: 'Price is too long' };
    }
    
    if (!this.patterns.price.test(sanitized)) {
      return { valid: false, error: 'Please enter a valid price' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate description
  validateDescription(description) {
    if (!description) return { valid: true, value: null }; // Description is optional
    
    const sanitized = this.sanitize(description);
    
    if (sanitized.length > this.maxLengths.description) {
      return { valid: false, error: 'Description is too long' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate harvest date
  validateHarvestDate(date) {
    if (!date) return { valid: true, value: null }; // Date is optional
    
    const sanitized = this.sanitize(date);
    const dateObj = new Date(sanitized);
    
    if (isNaN(dateObj.getTime())) {
      return { valid: false, error: 'Please enter a valid date' };
    }
    
    // Check if date is not too far in the past or future
    const now = new Date();
    const oneYearAgo = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
    const oneYearFromNow = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate());
    
    if (dateObj < oneYearAgo || dateObj > oneYearFromNow) {
      return { valid: false, error: 'Date must be within the last year or next year' };
    }
    
    return { valid: true, value: sanitized };
  }

  // Validate availability selection
  validateAvailability(selectedMonths) {
    if (!selectedMonths || selectedMonths.size === 0) {
      return { valid: false, error: 'Please select availability months' };
    }
    
    return { valid: true, value: selectedMonths };
  }

  // Validate image file
  validateImageFile(file) {
    if (!file) return { valid: true, value: null }; // Image is optional
    
    // Check file type
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return { valid: false, error: 'Please select a valid image file (JPEG, PNG, or WebP)' };
    }
    
    // Check file size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      return { valid: false, error: 'Image file is too large. Maximum size is 5MB.' };
    }
    
    return { valid: true, value: file };
  }

  // Validate FHF project selection
  validateFhfProject(wasFhfProject, fhfProjectName) {
    if (wasFhfProject === 'yes' && !fhfProjectName) {
      return { valid: false, error: 'Please select which FHF project you were part of' };
    }
    
    return { valid: true, value: { wasFhfProject, fhfProjectName } };
  }

  // Comprehensive form validation
  validateSignUpForm(formData) {
    const errors = {};
    const validatedData = {};
    
    // Validate required fields
    const usernameResult = this.validateUsername(formData.username);
    if (!usernameResult.valid) errors.username = usernameResult.error;
    else validatedData.username = usernameResult.value;
    
    const passwordResult = this.validatePassword(formData.password);
    if (!passwordResult.valid) errors.password = passwordResult.error;
    else validatedData.password = passwordResult.value;
    
    const fullNameResult = this.validateFullName(formData.fullName);
    if (!fullNameResult.valid) errors.fullName = fullNameResult.error;
    else validatedData.fullName = fullNameResult.value;
    
    // Validate optional fields
    const emailResult = this.validateEmail(formData.email);
    if (!emailResult.valid) errors.email = emailResult.error;
    else validatedData.email = emailResult.value;
    
    const phoneResult = this.validatePhone(formData.phone);
    if (!phoneResult.valid) errors.phone = phoneResult.error;
    else validatedData.phone = phoneResult.value;
    
    const fhfResult = this.validateFhfProject(formData.wasFhfProject, formData.fhfProjectName);
    if (!fhfResult.valid) errors.fhfProject = fhfResult.error;
    else validatedData.fhfProject = fhfResult.value;
    
    return {
      valid: Object.keys(errors).length === 0,
      errors,
      data: validatedData
    };
  }

  // Validate listing form
  validateListingForm(formData) {
    const errors = {};
    const validatedData = {};
    
    // Validate required fields
    const nameResult = this.validateFullName(formData.name);
    if (!nameResult.valid) errors.name = nameResult.error;
    else validatedData.name = nameResult.value;
    
    const phoneResult = this.validatePhone(formData.phone);
    if (!phoneResult.valid) errors.phone = phoneResult.error;
    else validatedData.phone = phoneResult.value;
    
    const productResult = this.validateProduct(formData.product);
    if (!productResult.valid) errors.product = productResult.error;
    else validatedData.product = productResult.value;
    
    const locationResult = this.validateLocation(formData.location);
    if (!locationResult.valid) errors.location = locationResult.error;
    else validatedData.location = locationResult.value;
    
    // Validate optional fields
    const emailResult = this.validateEmail(formData.email);
    if (!emailResult.valid) errors.email = emailResult.error;
    else validatedData.email = emailResult.value;
    
    const quantityResult = this.validateQuantity(formData.quantity);
    if (!quantityResult.valid) errors.quantity = quantityResult.error;
    else validatedData.quantity = quantityResult.value;
    
    const priceResult = this.validatePrice(formData.price);
    if (!priceResult.valid) errors.price = priceResult.error;
    else validatedData.price = priceResult.value;
    
    const descriptionResult = this.validateDescription(formData.description);
    if (!descriptionResult.valid) errors.description = descriptionResult.error;
    else validatedData.description = descriptionResult.value;
    
    const dateResult = this.validateHarvestDate(formData.harvest_date);
    if (!dateResult.valid) errors.harvest_date = dateResult.error;
    else validatedData.harvest_date = dateResult.value;
    
    return {
      valid: Object.keys(errors).length === 0,
      errors,
      data: validatedData
    };
  }
}

// Initialize validator
const inputValidator = new InputValidator();

// Export for use in other scripts
window.InputValidator = inputValidator;
