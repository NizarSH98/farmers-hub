-- =====================================================
-- FARMERS HUB - REVIEWS & RATINGS SYSTEM
-- =====================================================
-- Run this script in Supabase SQL Editor
-- This adds a complete review system to your marketplace
-- =====================================================

-- =====================================================
-- STEP 1: Create Reviews Table
-- =====================================================

CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  listing_id BIGINT NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES verified_users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_edited BOOLEAN DEFAULT false,
  
  -- Ensure one review per user per listing
  UNIQUE(listing_id, user_id)
);

-- Add comments to table
COMMENT ON TABLE reviews IS 'Product reviews and ratings from verified users';
COMMENT ON COLUMN reviews.rating IS 'Rating from 1 to 5 stars';
COMMENT ON COLUMN reviews.comment IS 'Optional text review (max 500 characters recommended)';

-- =====================================================
-- STEP 2: Create Indexes for Performance
-- =====================================================

CREATE INDEX idx_reviews_listing_id ON reviews(listing_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Composite index for common queries
CREATE INDEX idx_reviews_listing_rating ON reviews(listing_id, rating);

-- =====================================================
-- STEP 3: Enable Row Level Security (RLS)
-- =====================================================

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view reviews (public access)
CREATE POLICY "allow_public_read_reviews" ON reviews
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can insert their own reviews
CREATE POLICY "allow_authenticated_insert_reviews" ON reviews
  FOR INSERT
  WITH CHECK (true); -- App handles verification

-- Policy: Users can update their own reviews
CREATE POLICY "allow_users_update_own_reviews" ON reviews
  FOR UPDATE
  USING (true) -- App handles ownership verification
  WITH CHECK (true);

-- Policy: Users can delete their own reviews (admins can delete any)
CREATE POLICY "allow_users_delete_own_reviews" ON reviews
  FOR DELETE
  USING (true); -- App handles ownership verification

-- =====================================================
-- STEP 4: Create Helper Functions
-- =====================================================

-- Function: Get rating summary for a listing
CREATE OR REPLACE FUNCTION get_listing_rating_summary(p_listing_id BIGINT)
RETURNS TABLE(
  listing_id BIGINT,
  average_rating NUMERIC,
  total_reviews INTEGER,
  rating_percentage NUMERIC,
  stars_breakdown JSON
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_listing_id as listing_id,
    ROUND(AVG(rating)::numeric, 2) as average_rating,
    COUNT(*)::INTEGER as total_reviews,
    ROUND((AVG(rating) / 5.0 * 100)::numeric, 1) as rating_percentage,
    json_build_object(
      '5', COUNT(*) FILTER (WHERE rating = 5),
      '4', COUNT(*) FILTER (WHERE rating = 4),
      '3', COUNT(*) FILTER (WHERE rating = 3),
      '2', COUNT(*) FILTER (WHERE rating = 2),
      '1', COUNT(*) FILTER (WHERE rating = 1)
    ) as stars_breakdown
  FROM reviews
  WHERE reviews.listing_id = p_listing_id
  GROUP BY p_listing_id;
  
  -- Return null values if no reviews
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT 
      p_listing_id,
      0::NUMERIC,
      0::INTEGER,
      0::NUMERIC,
      json_build_object('5', 0, '4', 0, '3', 0, '2', 0, '1', 0)::JSON;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Check if user has already reviewed a listing
CREATE OR REPLACE FUNCTION get_user_review_for_listing(p_user_id BIGINT, p_listing_id BIGINT)
RETURNS TABLE(
  id BIGINT,
  rating INTEGER,
  comment TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  is_edited BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.rating,
    r.comment,
    r.created_at,
    r.updated_at,
    r.is_edited
  FROM reviews r
  WHERE r.user_id = p_user_id AND r.listing_id = p_listing_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Get reviews for a listing with user details
CREATE OR REPLACE FUNCTION get_listing_reviews(
  p_listing_id BIGINT,
  p_limit INTEGER DEFAULT 10,
  p_offset INTEGER DEFAULT 0,
  p_sort_by TEXT DEFAULT 'newest' -- 'newest', 'highest', 'lowest'
)
RETURNS TABLE(
  id BIGINT,
  rating INTEGER,
  comment TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  is_edited BOOLEAN,
  user_id BIGINT,
  username TEXT,
  full_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.rating,
    r.comment,
    r.created_at,
    r.updated_at,
    r.is_edited,
    r.user_id,
    u.username,
    u.full_name
  FROM reviews r
  JOIN verified_users u ON r.user_id = u.id
  WHERE r.listing_id = p_listing_id
  ORDER BY 
    CASE 
      WHEN p_sort_by = 'newest' THEN r.created_at
      ELSE NULL
    END DESC,
    CASE 
      WHEN p_sort_by = 'highest' THEN r.rating
      WHEN p_sort_by = 'lowest' THEN -r.rating
      ELSE NULL
    END DESC NULLS LAST
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Update review timestamp trigger
CREATE OR REPLACE FUNCTION update_review_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.is_edited = true;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER reviews_updated_at_trigger
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_review_timestamp();

-- =====================================================
-- STEP 5: Grant Permissions
-- =====================================================

-- Grant access to functions
GRANT EXECUTE ON FUNCTION get_listing_rating_summary(BIGINT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_user_review_for_listing(BIGINT, BIGINT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_listing_reviews(BIGINT, INTEGER, INTEGER, TEXT) TO anon, authenticated;

-- Grant table access
GRANT SELECT ON reviews TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON reviews TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE reviews_id_seq TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES (Run these to test)
-- =====================================================

-- Check if table was created successfully
-- SELECT * FROM reviews LIMIT 1;

-- Test rating summary function (will return zeros if no reviews)
-- SELECT * FROM get_listing_rating_summary(1);

-- Test get reviews function
-- SELECT * FROM get_listing_reviews(1, 10, 0, 'newest');

-- =====================================================
-- SUCCESS! 
-- =====================================================
-- ✅ Reviews table created
-- ✅ Indexes created for performance
-- ✅ RLS policies enabled (public read, authenticated write)
-- ✅ Helper functions created
-- ✅ Permissions granted
-- =====================================================

