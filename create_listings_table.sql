-- Farmer Hub: Create listings table
-- Copy and paste this entire script into Supabase SQL Editor

CREATE TABLE listings (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  product TEXT NOT NULL,
  quantity TEXT,
  price TEXT,
  location TEXT NOT NULL,
  harvest_date DATE,
  image_url TEXT,
  description TEXT
);

-- Create index for faster queries
CREATE INDEX idx_listings_created_at ON listings(created_at DESC);
CREATE INDEX idx_listings_product ON listings(product);
CREATE INDEX idx_listings_location ON listings(location);

-- Add comment to table
COMMENT ON TABLE listings IS 'Farmer Hub product listings';

