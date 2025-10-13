// config.js - Build-time configuration for GitHub Pages
// This file provides configuration for platforms that don't support environment variables

window.APP_CONFIG = {
  // Supabase Configuration
  SUPABASE_URL: 'https://ddajjvdnzakznqjmtdwp.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkYWpqdmRuemFrem5xam10ZHdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MjQxNTIsImV4cCI6MjA3NTQwMDE1Mn0.SwLSlSqnZn-fAFXj5uy1v50ZFSbOQi51IAk56VTmwUU',
  
  // Security Settings
  ENABLE_RLS: true,
  DEBUG_MODE: false,
  
  // Application Settings
  APP_NAME: 'Farmer Hub',
  APP_VERSION: '2.0.0',
  APP_ENVIRONMENT: 'production',
  
  // Feature Flags
  ENABLE_ANALYTICS: false,
  ENABLE_FORM_HANDLING: true,
  ENABLE_IMAGE_OPTIMIZATION: true,
  
  // API Settings
  API_TIMEOUT: 30000,
  MAX_FILE_SIZE: 5242880, // 5MB
  
  // Security Notes:
  // - This configuration is safe for client-side use
  // - Security is maintained through Row Level Security (RLS)
  // - Password hashing and input validation provide additional protection
  // - The anon key is designed for public client-side use
};

// Log configuration status (only in debug mode)
if (window.APP_CONFIG.DEBUG_MODE) {
  console.log('🔧 Configuration loaded:', window.APP_CONFIG);
  console.log('🔒 Security: RLS enabled =', window.APP_CONFIG.ENABLE_RLS);
}
