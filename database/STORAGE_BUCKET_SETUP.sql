-- =====================================================
-- STORAGE BUCKET SETUP FOR PRODUCT IMAGES
-- =====================================================
-- Run this AFTER the main database setup
-- Note: You may need to create the bucket via Supabase UI first
-- =====================================================

-- Create storage policies for product-images bucket
-- These allow public uploads and reads

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow public uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public access" ON storage.objects;
DROP POLICY IF EXISTS "Public upload access" ON storage.objects;
DROP POLICY IF EXISTS "Public read access" ON storage.objects;

-- Policy: Allow anyone to upload images
CREATE POLICY "Public upload to product-images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'product-images');

-- Policy: Allow anyone to read images
CREATE POLICY "Public read from product-images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- Policy: Allow anyone to update images
CREATE POLICY "Public update in product-images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'product-images');

-- Policy: Allow anyone to delete images (for listing deletion)
CREATE POLICY "Public delete from product-images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'product-images');

-- Success message
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'STORAGE POLICIES CREATED!';
  RAISE NOTICE '';
  RAISE NOTICE 'Make sure you have created the bucket:';
  RAISE NOTICE '1. Go to Storage in Supabase';
  RAISE NOTICE '2. Create bucket named: product-images';
  RAISE NOTICE '3. Make it PUBLIC';
  RAISE NOTICE '========================================';
END $$;

