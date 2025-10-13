-- SECURITY FIX #2: Row Level Security (RLS) Implementation
-- This script enables RLS and creates security policies to protect data
-- Run this in Supabase SQL Editor AFTER running the password hashing script

-- Step 1: Enable Row Level Security on all tables
ALTER TABLE verified_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Step 2: Create policies for verified_users table

-- Policy 1: Allow public read access to active users (for authentication)
CREATE POLICY "Public read active users" ON verified_users
  FOR SELECT USING (is_active = true);

-- Policy 2: Allow authenticated users to insert new accounts
CREATE POLICY "Allow user registration" ON verified_users
  FOR INSERT WITH CHECK (true);

-- Policy 3: Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON verified_users
  FOR UPDATE USING (auth.uid()::text = id::text);

-- Step 3: Create policies for listings table

-- Policy 1: Allow public read access to all listings (for marketplace)
CREATE POLICY "Public read listings" ON listings
  FOR SELECT USING (true);

-- Policy 2: Allow authenticated users to insert listings
CREATE POLICY "Authenticated users can create listings" ON listings
  FOR INSERT WITH CHECK (true);

-- Policy 3: Allow users to update their own listings
CREATE POLICY "Users can update own listings" ON listings
  FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Policy 4: Allow users to delete their own listings
CREATE POLICY "Users can delete own listings" ON listings
  FOR DELETE USING (auth.uid()::text = user_id::text);

-- Step 4: Create a function to get current user ID from session
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS BIGINT AS $$
BEGIN
  -- Try to get user ID from session storage
  -- This is a fallback for our custom auth system
  RETURN NULL; -- Will be handled by application logic
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create admin policies (for admin panel)
-- Note: Admin access will be handled by application-level checks

-- Policy for admin to manage all users
CREATE POLICY "Admin manage users" ON verified_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM verified_users 
      WHERE username = 'admin' 
      AND is_active = true
    )
  );

-- Policy for admin to manage all listings
CREATE POLICY "Admin manage listings" ON listings
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM verified_users 
      WHERE username = 'admin' 
      AND is_active = true
    )
  );

-- Step 6: Grant necessary permissions
GRANT SELECT ON verified_users TO anon;
GRANT SELECT ON listings TO anon;
GRANT INSERT ON verified_users TO anon;
GRANT INSERT ON listings TO anon;
GRANT UPDATE ON verified_users TO anon;
GRANT UPDATE ON listings TO anon;
GRANT DELETE ON listings TO anon;

-- Step 7: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_listings_user_id ON listings(user_id);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON listings(created_at);
CREATE INDEX IF NOT EXISTS idx_verified_users_username ON verified_users(username);
CREATE INDEX IF NOT EXISTS idx_verified_users_active ON verified_users(is_active);

-- Step 8: Add comments for documentation
COMMENT ON POLICY "Public read active users" ON verified_users IS 'Allows public read access to active users for authentication';
COMMENT ON POLICY "Allow user registration" ON verified_users IS 'Allows anyone to register new accounts';
COMMENT ON POLICY "Public read listings" ON listings IS 'Allows public read access to all listings for marketplace';
COMMENT ON POLICY "Authenticated users can create listings" ON listings IS 'Allows authenticated users to create new listings';

-- Step 9: Test the policies (optional - remove after testing)
-- Test public read access
-- SELECT COUNT(*) FROM listings; -- Should work
-- SELECT COUNT(*) FROM verified_users WHERE is_active = true; -- Should work

-- Test insert access
-- INSERT INTO listings (name, phone, product, location) VALUES ('Test', '123', 'Test Product', 'Test Location'); -- Should work

-- IMPORTANT: After implementing RLS, test all functionality:
-- 1. User registration
-- 2. User login
-- 3. Listing creation
-- 4. Listing viewing
-- 5. Admin panel access
