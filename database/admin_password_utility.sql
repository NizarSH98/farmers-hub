-- ADMIN PASSWORD CHANGE UTILITY
-- Use this script to change the admin password securely
-- Run this in Supabase SQL Editor

-- Function to change admin password
CREATE OR REPLACE FUNCTION change_admin_password(
  current_username TEXT,
  current_password TEXT,
  new_password TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  admin_record RECORD;
BEGIN
  -- Verify current credentials
  SELECT * INTO admin_record
  FROM admin_users
  WHERE username = current_username
    AND is_active = true
    AND verify_password(current_password, password_hash);
  
  -- If no matching admin found, return false
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  -- Update password with new hash
  UPDATE admin_users
  SET password_hash = crypt(new_password, gen_salt('bf', 12))
  WHERE username = current_username;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create new admin user
CREATE OR REPLACE FUNCTION create_admin_user(
  new_username TEXT,
  new_password TEXT,
  admin_role TEXT DEFAULT 'admin'
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if username already exists
  IF EXISTS (SELECT 1 FROM admin_users WHERE username = new_username) THEN
    RETURN FALSE;
  END IF;
  
  -- Create new admin user
  INSERT INTO admin_users (username, password_hash, role, notes)
  VALUES (
    new_username,
    crypt(new_password, gen_salt('bf', 12)),
    admin_role,
    'Created via admin utility'
  );
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION change_admin_password(TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION create_admin_user(TEXT, TEXT, TEXT) TO anon;

-- Add comments
COMMENT ON FUNCTION change_admin_password(TEXT, TEXT, TEXT) IS 'Securely changes admin password after verifying current credentials';
COMMENT ON FUNCTION create_admin_user(TEXT, TEXT, TEXT) IS 'Creates a new admin user with secure password hashing';

-- USAGE EXAMPLES:

-- 1. Change admin password (from default to secure):
-- SELECT change_admin_password('admin', 'Admin123!', 'YourNewSecurePassword123!');

-- 2. Create additional admin user:
-- SELECT create_admin_user('admin2', 'SecurePassword123!', 'admin');

-- 3. Verify admin users:
-- SELECT username, role, is_active, last_login FROM admin_users;

-- SECURITY NOTES:
-- 1. Use strong passwords with uppercase, lowercase, numbers, and special characters
-- 2. Change the default admin password immediately after deployment
-- 3. Consider creating multiple admin accounts for redundancy
-- 4. Regularly rotate admin passwords
-- 5. Monitor admin login attempts in Supabase logs
