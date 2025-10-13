-- Fix availability column to ensure it always has a value
-- Run this in Supabase SQL Editor if you haven't already

-- Set default value for availability column
ALTER TABLE listings 
  ALTER COLUMN availability SET DEFAULT 'all';

-- Update any existing NULL values to 'all'
UPDATE listings 
  SET availability = 'all' 
  WHERE availability IS NULL OR availability = '';

-- Make the column NOT NULL
ALTER TABLE listings 
  ALTER COLUMN availability SET NOT NULL;

-- Add a check constraint to ensure valid values
ALTER TABLE listings 
  ADD CONSTRAINT availability_valid CHECK (
    availability = 'all' OR 
    (availability ~ '^\[[\s]*[0-9,\s"]+[\s]*\]$')
  );

-- Comment for documentation
COMMENT ON COLUMN listings.availability IS 'Product availability: "all" or JSON array of month numbers [1-12], e.g. ["1","2","3"]';

