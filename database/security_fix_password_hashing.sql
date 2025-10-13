-- SECURITY FIX #1: Password Hashing Migration
-- This script migrates from plain text passwords to secure hashed passwords
-- Run this in Supabase SQL Editor

-- Step 1: Add password hash column
ALTER TABLE verified_users ADD COLUMN password_hash TEXT;

-- Step 2: Create a function to hash passwords using PostgreSQL's crypt function
CREATE OR REPLACE FUNCTION hash_password(plain_password TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN crypt(plain_password, gen_salt('bf', 12));
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create a function to verify passwords
CREATE OR REPLACE FUNCTION verify_password(plain_password TEXT, hashed_password TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN crypt(plain_password, hashed_password) = hashed_password;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Migrate existing passwords to hashed versions
-- This will hash all existing plain text passwords
UPDATE verified_users 
SET password_hash = hash_password(password)
WHERE password_hash IS NULL AND password IS NOT NULL;

-- Step 5: Create an index for faster password lookups
CREATE INDEX IF NOT EXISTS idx_verified_users_password_hash ON verified_users(password_hash);

-- Step 6: Add comments for documentation
COMMENT ON COLUMN verified_users.password_hash IS 'Securely hashed password using bcrypt';
COMMENT ON FUNCTION hash_password(TEXT) IS 'Hashes a plain text password using bcrypt';
COMMENT ON FUNCTION verify_password(TEXT, TEXT) IS 'Verifies a plain text password against a hash';

-- Step 7: Create a secure login function
CREATE OR REPLACE FUNCTION authenticate_user(username_input TEXT, password_input TEXT)
RETURNS TABLE(
  id BIGINT,
  username TEXT,
  full_name TEXT,
  phone TEXT,
  email TEXT,
  is_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.username,
    u.full_name,
    u.phone,
    u.email,
    u.is_active
  FROM verified_users u
  WHERE u.username = username_input
    AND u.is_active = true
    AND (
      -- Check hashed password (new method)
      (u.password_hash IS NOT NULL AND verify_password(password_input, u.password_hash))
      OR
      -- Fallback to plain text for migration period (REMOVE AFTER MIGRATION)
      (u.password_hash IS NULL AND u.password = password_input)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Grant necessary permissions
GRANT EXECUTE ON FUNCTION authenticate_user(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION hash_password(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO anon;

-- Step 9: Test the migration (optional - remove after testing)
-- SELECT authenticate_user('admin', 'admin123');

-- IMPORTANT: After confirming everything works, run this to remove plain text passwords:
-- ALTER TABLE verified_users DROP COLUMN password;
