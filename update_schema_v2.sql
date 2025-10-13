-- Farmer Hub: Add new fields for bilingual products and availability
-- Run this in Supabase SQL Editor

-- Add product_ar column (Arabic product name - required)
ALTER TABLE listings ADD COLUMN IF NOT EXISTS product_ar TEXT;

-- Add availability column (stores months as JSON array or 'all')
ALTER TABLE listings ADD COLUMN IF NOT EXISTS availability TEXT DEFAULT 'all';

-- Add index for product_ar for faster searching
CREATE INDEX IF NOT EXISTS idx_listings_product_ar ON listings(product_ar);

-- Add comments
COMMENT ON COLUMN listings.product_ar IS 'Product name in Arabic (required)';
COMMENT ON COLUMN listings.product IS 'Product name in English (optional)';
COMMENT ON COLUMN listings.availability IS 'Availability months as JSON array (e.g. ["1","3","6"]) or "all"';

-- Make product column nullable (it's now optional, Arabic is required)
ALTER TABLE listings ALTER COLUMN product DROP NOT NULL;

