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
    
    // Fallback to hardcoded values (for GitHub Pages)
    const fallbackUrl = 'https://ddajjvdnzakznqjmtdwp.supabase.co';
    const fallbackKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkYWpqdmRuemFrem5xam10ZHdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MjQxNTIsImV4cCI6MjA3NTQwMDE1Mn0.SwLSlSqnZn-fAFXj5uy1v50ZFSbOQi51IAk56VTmwUU';
    
    return {
      SUPABASE_URL: envUrl || fallbackUrl,
      SUPABASE_ANON_KEY: envKey || fallbackKey,
      ENABLE_RLS: this.getEnvVar('ENABLE_RLS') === 'true' || true,
      DEBUG_MODE: this.getEnvVar('DEBUG_MODE') === 'true' || false
    };
  }

  getEnvVar(name) {
    // For Netlify/Vercel, environment variables are available in process.env
    if (typeof process !== 'undefined' && process.env) {
      return process.env[name];
    }
    
    // For GitHub Pages, we can't access environment variables
    // This is why we need RLS policies for security
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

  // Security warning for development
  logSecurityWarning() {
    if (this.isDebugMode()) {
      console.warn('🔒 SECURITY: Running in debug mode. Ensure RLS is enabled in production.');
    }
    
    if (!this.isRLSEnabled()) {
      console.error('🚨 SECURITY WARNING: RLS is disabled! Enable Row Level Security immediately.');
    }
  }
}

// Initialize secure configuration
const secureConfig = new SecureConfig();

// Export for use in other scripts
window.SecureConfig = secureConfig;

// Log security status
secureConfig.logSecurityWarning();
