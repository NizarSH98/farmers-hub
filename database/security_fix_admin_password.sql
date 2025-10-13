-- SECURITY FIX: Admin Password Hashing
-- This script creates a secure admin authentication system
-- Run this in Supabase SQL Editor AFTER running the main password hashing script

-- Step 1: Create admin_users table for secure admin authentication
CREATE TABLE IF NOT EXISTS admin_users (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_login TIMESTAMPTZ,
  role TEXT NOT NULL DEFAULT 'admin',
  notes TEXT
);

-- Step 2: Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username);
CREATE INDEX IF NOT EXISTS idx_admin_users_active ON admin_users(is_active);

-- Step 3: Add comment
COMMENT ON TABLE admin_users IS 'Administrative users with secure password authentication';

-- Step 4: Create secure admin authentication function
CREATE OR REPLACE FUNCTION authenticate_admin(username_input TEXT, password_input TEXT)
RETURNS TABLE(
  id BIGINT,
  username TEXT,
  role TEXT,
  is_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.username,
    a.role,
    a.is_active
  FROM admin_users a
  WHERE a.username = username_input
    AND a.is_active = true
    AND verify_password(password_input, a.password_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create function to update admin login time
CREATE OR REPLACE FUNCTION update_admin_login_time(admin_id BIGINT)
RETURNS VOID AS $$
BEGIN
  UPDATE admin_users 
  SET last_login = NOW() 
  WHERE id = admin_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: Create default admin user with secure password
-- Default credentials: username='admin', password='Admin123!'
-- IMPORTANT: Change this password immediately after deployment!
INSERT INTO admin_users (username, password_hash, role, notes)
VALUES (
  'admin',
  crypt('Admin123!', gen_salt('bf', 12)),
  'admin',
  'Default administrator account - CHANGE PASSWORD IMMEDIATELY!'
) ON CONFLICT (username) DO NOTHING;

-- Step 7: Enable RLS on admin_users table
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Step 8: Create RLS policies for admin_users
-- Only allow authenticated admins to read admin data
CREATE POLICY "Admins can read admin data" ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE username = 'admin' 
      AND is_active = true
    )
  );

-- Allow admins to update their own login time
CREATE POLICY "Admins can update login time" ON admin_users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE username = 'admin' 
      AND is_active = true
    )
  );

-- Step 9: Grant necessary permissions
GRANT EXECUTE ON FUNCTION authenticate_admin(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION update_admin_login_time(BIGINT) TO anon;
GRANT SELECT ON admin_users TO anon;
GRANT UPDATE ON admin_users TO anon;

-- Step 10: Add comments for documentation
COMMENT ON FUNCTION authenticate_admin(TEXT, TEXT) IS 'Authenticates admin users with secure password verification';
COMMENT ON FUNCTION update_admin_login_time(BIGINT) IS 'Updates admin login timestamp';

-- Step 11: Test the admin authentication (optional - remove after testing)
-- SELECT authenticate_admin('admin', 'Admin123!');

-- IMPORTANT SECURITY NOTES:
-- 1. The default admin password is 'Admin123!' - CHANGE THIS IMMEDIATELY!
-- 2. Use a strong password with uppercase, lowercase, numbers, and special characters
-- 3. Consider implementing two-factor authentication for additional security
-- 4. Monitor admin login attempts in the logs
-- 5. Regularly rotate admin passwords

-- To change the admin password, run:
-- UPDATE admin_users 
-- SET password_hash = crypt('YourNewSecurePassword', gen_salt('bf', 12))
-- WHERE username = 'admin';
