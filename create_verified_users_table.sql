-- Farmer Hub: Create verified users table
-- This table stores approved farmers who can submit listings

CREATE TABLE verified_users (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_login TIMESTAMPTZ,
  notes TEXT
);

-- Create index for faster lookups
CREATE INDEX idx_verified_users_username ON verified_users(username);
CREATE INDEX idx_verified_users_active ON verified_users(is_active);

-- Add comment
COMMENT ON TABLE verified_users IS 'Approved farmers who can submit listings';

-- Add user_id column to listings table to track who created what
ALTER TABLE listings ADD COLUMN user_id BIGINT REFERENCES verified_users(id);
CREATE INDEX idx_listings_user_id ON listings(user_id);

-- Sample admin user (username: admin, password: admin123)
-- You can change this after first login!
INSERT INTO verified_users (username, password, full_name, phone, email, notes)
VALUES ('admin', 'admin123', 'Administrator', '', '', 'System administrator account');

