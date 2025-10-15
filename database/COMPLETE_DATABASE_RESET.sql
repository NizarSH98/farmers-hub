-- =====================================================
-- FARMERS HUB - COMPLETE DATABASE SETUP FROM SCRATCH
-- =====================================================
-- Run this entire script in Supabase SQL Editor
-- This will DROP and RECREATE everything cleanly
-- =====================================================

-- =====================================================
-- STEP 1: CLEAN SLATE - Drop everything
-- =====================================================

-- Drop existing policies first
DROP POLICY IF EXISTS "allow_all_verified_users" ON verified_users CASCADE;
DROP POLICY IF EXISTS "allow_all_admin_users" ON admin_users CASCADE;
DROP POLICY IF EXISTS "allow_all_listings" ON listings CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS authenticate_user(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS authenticate_admin(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS update_admin_login_time(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS hash_password(TEXT) CASCADE;
DROP FUNCTION IF EXISTS verify_password(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS change_admin_password(TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS create_admin_user(TEXT, TEXT, TEXT) CASCADE;

-- Drop existing tables
DROP TABLE IF EXISTS listings CASCADE;
DROP TABLE IF EXISTS verified_users CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;

-- =====================================================
-- STEP 2: Enable Required Extensions
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- STEP 3: Create Tables
-- =====================================================

-- Table: verified_users (farmers and customers)
CREATE TABLE verified_users (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  username TEXT NOT NULL UNIQUE,
  password TEXT, -- Legacy plain text (will be migrated)
  password_hash TEXT, -- Secure hashed password
  full_name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_login TIMESTAMPTZ,
  was_part_of_fhf_project BOOLEAN DEFAULT false,
  fhf_project_name TEXT,
  notes TEXT
);

-- Table: admin_users (system administrators)
CREATE TABLE admin_users (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_login TIMESTAMPTZ,
  role TEXT NOT NULL DEFAULT 'admin',
  notes TEXT
);

-- Table: listings (product listings)
CREATE TABLE listings (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id BIGINT REFERENCES verified_users(id),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  product TEXT, -- English product name (optional)
  product_ar TEXT, -- Arabic product name (required)
  quantity TEXT,
  price TEXT,
  location TEXT NOT NULL,
  harvest_date DATE,
  description TEXT,
  availability TEXT DEFAULT 'all', -- 'all' or JSON array like ["1","2","3"]
  image_url TEXT
);

-- =====================================================
-- STEP 4: Create Indexes
-- =====================================================

-- verified_users indexes
CREATE INDEX idx_verified_users_username ON verified_users(username);
CREATE INDEX idx_verified_users_active ON verified_users(is_active);
CREATE INDEX idx_verified_users_password_hash ON verified_users(password_hash);
CREATE INDEX idx_verified_users_fhf_project ON verified_users(was_part_of_fhf_project);

-- admin_users indexes
CREATE INDEX idx_admin_users_username ON admin_users(username);
CREATE INDEX idx_admin_users_active ON admin_users(is_active);

-- listings indexes
CREATE INDEX idx_listings_user_id ON listings(user_id);
CREATE INDEX idx_listings_created_at ON listings(created_at DESC);
CREATE INDEX idx_listings_product ON listings(product);
CREATE INDEX idx_listings_product_ar ON listings(product_ar);
CREATE INDEX idx_listings_location ON listings(location);

-- =====================================================
-- STEP 5: Create Functions
-- =====================================================

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

-- Function: authenticate_user (for farmers/customers)
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
      -- Check hashed password first (new method)
      (u.password_hash IS NOT NULL AND verify_password(password_input, u.password_hash))
      OR
      -- Fallback to plain text for migration (remove after migration)
      (u.password_hash IS NULL AND u.password = password_input)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Function: authenticate_admin (for system admins)
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

-- =====================================================
-- STEP 6: Enable Row Level Security (RLS)
-- =====================================================

ALTER TABLE verified_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Create permissive policies (application handles access control)
CREATE POLICY "allow_all_verified_users" 
  ON verified_users 
  FOR ALL 
  USING (true) 
  WITH CHECK (true);

CREATE POLICY "allow_all_admin_users" 
  ON admin_users 
  FOR ALL 
  USING (true) 
  WITH CHECK (true);

CREATE POLICY "allow_all_listings" 
  ON listings 
  FOR ALL 
  USING (true) 
  WITH CHECK (true);

-- =====================================================
-- STEP 7: Grant Permissions
-- =====================================================

-- Grant table permissions
GRANT ALL ON verified_users TO anon, authenticated, postgres;
GRANT ALL ON admin_users TO anon, authenticated, postgres;
GRANT ALL ON listings TO anon, authenticated, postgres;

-- Grant sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, postgres;

-- Grant function permissions
GRANT EXECUTE ON FUNCTION hash_password(TEXT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION authenticate_user(TEXT, TEXT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION authenticate_admin(TEXT, TEXT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION update_admin_login_time(BIGINT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION change_admin_password(TEXT, TEXT, TEXT) TO anon, authenticated, postgres;
GRANT EXECUTE ON FUNCTION create_admin_user(TEXT, TEXT, TEXT) TO anon, authenticated, postgres;

-- =====================================================
-- STEP 8: Add Comments for Documentation
-- =====================================================

COMMENT ON TABLE verified_users IS 'Farmers and customers who can submit listings';
COMMENT ON TABLE admin_users IS 'System administrators with panel access';
COMMENT ON TABLE listings IS 'Product listings from farmers';
COMMENT ON COLUMN verified_users.password_hash IS 'Securely hashed password using bcrypt';
COMMENT ON COLUMN verified_users.password IS 'Legacy plain text password (deprecated)';
COMMENT ON COLUMN listings.availability IS 'Product availability: "all" or JSON array of month numbers';
COMMENT ON COLUMN listings.product_ar IS 'Product name in Arabic (required)';
COMMENT ON COLUMN listings.product IS 'Product name in English (optional)';

-- =====================================================
-- STEP 9: Insert Default Users
-- =====================================================

-- Default admin user (CHANGE PASSWORD IMMEDIATELY!)
INSERT INTO admin_users (username, password_hash, role, notes)
VALUES (
  'admin',
  crypt('Admin123!', gen_salt('bf', 12)),
  'admin',
  'Default administrator - CHANGE PASSWORD IMMEDIATELY!'
);

-- Sample verified users from your screenshot
INSERT INTO verified_users (username, password, password_hash, full_name, phone, email, notes)
VALUES 
  ('Nizar', 'CJFDcSX2', crypt('CJFDcSX2', gen_salt('bf', 12)), 'Nizar Shehayeb', '71397813', 'jasberni@gmail.com', 'Sample user'),
  ('SarahKhechen', 'k4u8sfkY', crypt('k4u8sfkY', gen_salt('bf', 12)), 'Sarah', '76983677', 'khechen@example.com', 'Sample user'),
  ('Test', 'Test1234', crypt('Test1234', gen_salt('bf', 12)), 'Test', NULL, NULL, 'Test account');

-- =====================================================
-- STEP 10: Verify Setup
-- =====================================================

-- Check tables
SELECT 'Tables created:' AS status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('verified_users', 'admin_users', 'listings')
ORDER BY table_name;

-- Check functions
SELECT 'Functions created:' AS status;
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name LIKE '%authenticate%'
ORDER BY routine_name;

-- Check extensions
SELECT 'Extensions enabled:' AS status;
SELECT extname, extversion FROM pg_extension WHERE extname = 'pgcrypto';

-- Test authentication
SELECT 'Testing admin authentication...' AS status;
SELECT * FROM authenticate_admin('admin', 'Admin123!');

SELECT 'Testing user authentication...' AS status;
SELECT * FROM authenticate_user('Nizar', 'CJFDcSX2');

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'DATABASE SETUP COMPLETE!';
  RAISE NOTICE '';
  RAISE NOTICE 'Admin Credentials:';
  RAISE NOTICE '  Username: admin';
  RAISE NOTICE '  Password: Admin123!';
  RAISE NOTICE '';
  RAISE NOTICE 'Sample User Credentials:';
  RAISE NOTICE '  Username: Nizar';
  RAISE NOTICE '  Password: CJFDcSX2';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '1. Create product-images storage bucket';
  RAISE NOTICE '2. Test login on your website';
  RAISE NOTICE '3. Change admin password';
  RAISE NOTICE '========================================';
END $$;

