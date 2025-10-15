// Universal Authentication Manager for Farmers Hub
// Provides centralized authentication across all pages

class AuthManager {
  constructor() {
    // Use a single storage key for universal auth
    this.STORAGE_KEY = 'farmersHubUser';
    this.currentUser = null;
    this.init();
  }

  init() {
    // Load user from session storage
    this.currentUser = this.getStoredUser();
  }

  // Store user session
  setUser(userData) {
    if (!userData) {
      this.currentUser = null;
      sessionStorage.removeItem(this.STORAGE_KEY);
      return;
    }

    // Normalize user data structure
    const normalizedUser = {
      id: userData.id,
      username: userData.username,
      full_name: userData.full_name,
      phone: userData.phone || null,
      email: userData.email || null,
      timestamp: Date.now()
    };

    this.currentUser = normalizedUser;
    sessionStorage.setItem(this.STORAGE_KEY, JSON.stringify(normalizedUser));
    
    // Dispatch custom event for other components to listen
    window.dispatchEvent(new CustomEvent('authStateChanged', { 
      detail: { user: normalizedUser } 
    }));
  }

  // Get stored user from session
  getStoredUser() {
    try {
      const stored = sessionStorage.getItem(this.STORAGE_KEY);
      if (!stored) return null;

      const user = JSON.parse(stored);
      
      // Validate session (expire after 24 hours)
      const ONE_DAY = 24 * 60 * 60 * 1000;
      if (user.timestamp && (Date.now() - user.timestamp > ONE_DAY)) {
        this.logout();
        return null;
      }

      return user;
    } catch (e) {
      console.error('Failed to parse stored user:', e);
      sessionStorage.removeItem(this.STORAGE_KEY);
      return null;
    }
  }

  // Get current user
  getUser() {
    return this.currentUser;
  }

  // Check if user is logged in
  isLoggedIn() {
    return this.currentUser !== null;
  }

  // Logout user
  logout() {
    this.currentUser = null;
    sessionStorage.removeItem(this.STORAGE_KEY);
    
    // Clear any legacy storage keys
    sessionStorage.removeItem('farmerUser');
    sessionStorage.removeItem('marketUser');
    
    // Dispatch logout event
    window.dispatchEvent(new CustomEvent('authStateChanged', { 
      detail: { user: null } 
    }));
  }

  // Authenticate user with Supabase
  async authenticate(supabase, username, password) {
    try {
      // Input validation
      if (!username || !password) {
        return { 
          success: false, 
          error: 'Please enter both username and password' 
        };
      }

      // Call Supabase authentication function
      const { data: users, error } = await supabase.rpc('authenticate_user', {
        username_input: username.trim(),
        password_input: password.trim()
      });

      if (error) {
        console.error('Authentication error:', error);
        return { 
          success: false, 
          error: 'Authentication failed. Please try again.' 
        };
      }

      if (!users || users.length === 0) {
        return { 
          success: false, 
          error: 'Invalid username or password' 
        };
      }

      const user = users[0];

      if (!user.is_active) {
        return { 
          success: false, 
          error: 'Your account is not active. Contact admin.' 
        };
      }

      // Store user session
      this.setUser({
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email
      });

      return { 
        success: true, 
        user: this.currentUser 
      };

    } catch (e) {
      console.error('Login error:', e);
      return { 
        success: false, 
        error: 'Login failed: ' + e.message 
      };
    }
  }

  // Migrate legacy sessions
  migrateLegacySessions() {
    const legacyKeys = ['farmerUser', 'marketUser'];
    
    for (const key of legacyKeys) {
      const legacyData = sessionStorage.getItem(key);
      if (legacyData && !this.currentUser) {
        try {
          const userData = JSON.parse(legacyData);
          this.setUser(userData);
          sessionStorage.removeItem(key);
          console.log(`✅ Migrated session from ${key} to ${this.STORAGE_KEY}`);
          break;
        } catch (e) {
          console.error(`Failed to migrate ${key}:`, e);
          sessionStorage.removeItem(key);
        }
      }
    }
  }
}

// Initialize global auth manager
window.AuthManager = new AuthManager();

// Migrate any existing sessions
window.AuthManager.migrateLegacySessions();

// Export for easy access
window.auth = window.AuthManager;

