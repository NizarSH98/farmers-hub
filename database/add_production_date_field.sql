-- Farmer Hub: Add production_date field to listings table
-- This allows tracking separate dates for harvest and production (processing)
-- Run this in Supabase SQL Editor

-- Add production_date column (for products that need processing after harvest)
ALTER TABLE listings ADD COLUMN IF NOT EXISTS production_date DATE;

-- Add index for production_date for faster queries
CREATE INDEX IF NOT EXISTS idx_listings_production_date ON listings(production_date);

-- Add comment to explain the field
COMMENT ON COLUMN listings.production_date IS 'Production/processing date (for products processed after harvest, like olive oil, cheese, etc.)';
COMMENT ON COLUMN listings.harvest_date IS 'Harvest date (when raw product was harvested)';

-- Update existing records: NULL is acceptable (means not applicable or same as harvest)
-- No data migration needed

