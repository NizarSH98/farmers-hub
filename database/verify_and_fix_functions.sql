-- ========================================
-- DIAGNOSTIC & FIX: Verify Functions Exist
-- ========================================

-- STEP 1: Check if functions exist
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'CHECKING EXISTING FUNCTIONS...';
  RAISE NOTICE '========================================';
END $$;

-- List all authentication functions
SELECT 
  routine_name,
  routine_type,
  security_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'authenticate_user',
    'authenticate_admin',
    'hash_password',
    'verify_password',
    'update_admin_login_time',
    'change_admin_password',
    'create_admin_user'
  )
ORDER BY routine_name;

-- STEP 2: Enable pgcrypto extension (required for password hashing)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- STEP 3: Recreate all functions with proper permissions

-- Function: hash_password
CREATE OR REPLACE FUNCTION hash_password(plain_password TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN crypt(plain_password, gen_salt('bf', 12));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: verify_password
CREATE OR REPLACE FUNCTION verify_password(plain_password TEXT, hashed_password TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN crypt(plain_password, hashed_password) = hashed_password;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: authenticate_user
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
      (u.password_hash IS NOT NULL AND verify_password(password_input, u.password_hash))
      OR
      (u.password_hash IS NULL AND u.password = password_input)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: authenticate_admin
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
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: update_admin_login_time
CREATE OR REPLACE FUNCTION update_admin_login_time(admin_id BIGINT)
RETURNS VOID AS $$
BEGIN
  UPDATE admin_users 
  SET last_login = NOW() 
  WHERE id = admin_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: change_admin_password
CREATE OR REPLACE FUNCTION change_admin_password(
  current_username TEXT,
  current_password TEXT,
  new_password TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  admin_record RECORD;
BEGIN
  SELECT * INTO admin_record
  FROM admin_users
  WHERE username = current_username
    AND is_active = true
    AND verify_password(current_password, password_hash);
  
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;
  
  UPDATE admin_users
  SET password_hash = crypt(new_password, gen_salt('bf', 12))
  WHERE username = current_username;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: create_admin_user
CREATE OR REPLACE FUNCTION create_admin_user(
  new_username TEXT,
  new_password TEXT,
  admin_role TEXT DEFAULT 'admin'
)
RETURNS BOOLEAN AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM admin_users WHERE username = new_username) THEN
    RETURN FALSE;
  END IF;
  
  INSERT INTO admin_users (username, password_hash, role, notes)
  VALUES (
    new_username,
    crypt(new_password, gen_salt('bf', 12)),
    admin_role,
    'Created via admin utility'
  );
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- STEP 4: Grant EXECUTE permissions to ALL roles
REVOKE ALL ON FUNCTION authenticate_user(TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION authenticate_admin(TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION update_admin_login_time(BIGINT) FROM PUBLIC;
REVOKE ALL ON FUNCTION hash_password(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION verify_password(TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION change_admin_password(TEXT, TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_admin_user(TEXT, TEXT, TEXT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION authenticate_user(TEXT, TEXT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION authenticate_admin(TEXT, TEXT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION update_admin_login_time(BIGINT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION hash_password(TEXT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION change_admin_password(TEXT, TEXT, TEXT) TO anon, authenticated, postgres, public;
GRANT EXECUTE ON FUNCTION create_admin_user(TEXT, TEXT, TEXT) TO anon, authenticated, postgres, public;

-- STEP 5: Verify functions are now accessible
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'ALL FUNCTIONS RECREATED!';
  RAISE NOTICE 'Testing authenticate_admin...';
END $$;

-- Test authenticate_admin function
SELECT 'authenticate_admin exists' AS status, 
       COUNT(*) AS count
FROM pg_proc 
WHERE proname = 'authenticate_admin';

-- STEP 6: Show current function permissions
SELECT 
  p.proname AS function_name,
  pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
  CASE WHEN p.prosecdef THEN 'DEFINER' ELSE 'INVOKER' END AS security,
  array_to_string(p.proacl, ', ') AS permissions
FROM pg_proc p
WHERE p.proname IN (
  'authenticate_user',
  'authenticate_admin',
  'hash_password',
  'verify_password',
  'update_admin_login_time',
  'change_admin_password',
  'create_admin_user'
)
AND p.pronamespace = 'public'::regnamespace
ORDER BY p.proname;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'FUNCTIONS VERIFIED AND FIXED!';
  RAISE NOTICE 'Try logging in again';
  RAISE NOTICE '========================================';
END $$;

