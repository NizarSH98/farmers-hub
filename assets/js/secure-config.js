// SECURITY FIX #2: Secure Configuration Loader
// This script loads configuration securely and provides fallbacks

class SecureConfig {
  constructor() {
    this.config = this.loadConfig();
  }

  loadConfig() {
    // Try to load from environment variables (for Netlify/Vercel)
    const envUrl = this.getEnvVar('SUPABASE_URL');
    const envKey = this.getEnvVar('SUPABASE_ANON_KEY');
    
    // Try to load from config.js (for GitHub Pages)
    const configUrl = this.getConfigVar('SUPABASE_URL');
    const configKey = this.getConfigVar('SUPABASE_ANON_KEY');
    
    // Fallback to hardcoded values (last resort)
    const fallbackUrl = 'https://ddajjvdnzakznqjmtdwp.supabase.co';
    const fallbackKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkYWpqdmRuemFrem5xam10ZHdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MjQxNTIsImV4cCI6MjA3NTQwMDE1Mn0.SwLSlSqnZn-fAFXj5uy1v50ZFSbOQi51IAk56VTmwUU';
    
    return {
      SUPABASE_URL: envUrl || configUrl || fallbackUrl,
      SUPABASE_ANON_KEY: envKey || configKey || fallbackKey,
      ENABLE_RLS: this.getEnvVar('ENABLE_RLS') === 'true' || this.getConfigVar('ENABLE_RLS') === true || true,
      DEBUG_MODE: this.getEnvVar('DEBUG_MODE') === 'true' || this.getConfigVar('DEBUG_MODE') === true || false
    };
  }

  getEnvVar(name) {
    // For Netlify/Vercel, environment variables are available in process.env
    if (typeof process !== 'undefined' && process.env) {
      return process.env[name];
    }
    
    // For GitHub Pages, we can't access environment variables
    return null;
  }

  getConfigVar(name) {
    // Try to get from config.js file
    if (typeof window !== 'undefined' && window.APP_CONFIG) {
      return window.APP_CONFIG[name];
    }
    
    return null;
  }

  getSupabaseUrl() {
    return this.config.SUPABASE_URL;
  }

  getSupabaseKey() {
    return this.config.SUPABASE_ANON_KEY;
  }

  isRLSEnabled() {
    return this.config.ENABLE_RLS;
  }

  isDebugMode() {
    return this.config.DEBUG_MODE;
  }

  // Get configuration source for debugging
  getConfigSource() {
    if (this.getEnvVar('SUPABASE_URL')) {
      return 'environment-variables';
    } else if (this.getConfigVar('SUPABASE_URL')) {
      return 'config-file';
    } else {
      return 'fallback';
    }
  }

  // Security warning for development
  logSecurityWarning() {
    const source = this.getConfigSource();
    
    if (this.isDebugMode()) {
      console.warn('🔒 SECURITY: Running in debug mode. Ensure RLS is enabled in production.');
    }
    
    if (!this.isRLSEnabled()) {
      console.error('🚨 SECURITY WARNING: RLS is disabled! Enable Row Level Security immediately.');
    }
    
    // Log configuration source
    console.log(`🔧 Configuration loaded from: ${source}`);
    
    if (source === 'fallback') {
      console.warn('⚠️ Using fallback configuration. Consider setting up environment variables for better security.');
    }
  }
}

// Initialize secure configuration
const secureConfig = new SecureConfig();

// Export for use in other scripts
window.SecureConfig = secureConfig;

// Log security status
secureConfig.logSecurityWarning();
