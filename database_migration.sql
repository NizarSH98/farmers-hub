-- =====================================================
-- FARMERS HUB - DATABASE MIGRATION SCRIPT
-- Adding brand_name column to support branding feature
-- =====================================================

-- Add brand_name column to verified_users table
ALTER TABLE verified_users 
ADD COLUMN IF NOT EXISTS brand_name TEXT;

-- Add brand_name column to listings table  
ALTER TABLE listings 
ADD COLUMN IF NOT EXISTS brand_name TEXT;

-- Add comments to document the new columns
COMMENT ON COLUMN verified_users.brand_name IS 'Optional brand name for established farmers/businesses';
COMMENT ON COLUMN listings.brand_name IS 'Optional brand name for the product listing';

-- Create index on brand_name for better query performance (optional)
CREATE INDEX IF NOT EXISTS idx_verified_users_brand_name ON verified_users(brand_name);
CREATE INDEX IF NOT EXISTS idx_listings_brand_name ON listings(brand_name);

-- =====================================================
-- VERIFICATION QUERIES (run these to confirm changes)
-- =====================================================

-- Check if columns were added successfully
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name IN ('verified_users', 'listings') 
AND column_name = 'brand_name';

-- Check table structure (alternative to \d command)
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('verified_users', 'listings')
ORDER BY table_name, ordinal_position;

-- =====================================================
-- ROLLBACK SCRIPT (if needed)
-- =====================================================

-- To rollback these changes, run:
-- ALTER TABLE verified_users DROP COLUMN IF EXISTS brand_name;
-- ALTER TABLE listings DROP COLUMN IF EXISTS brand_name;
-- DROP INDEX IF EXISTS idx_verified_users_brand_name;
-- DROP INDEX IF EXISTS idx_listings_brand_name;
