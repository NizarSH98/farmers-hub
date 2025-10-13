-- Farmer Hub: Create storage policies for product-images bucket
-- This allows anyone to upload and view images

-- Policy 1: Allow public uploads (INSERT)
CREATE POLICY "Allow public uploads"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'product-images');

-- Policy 2: Allow public reads (SELECT)
CREATE POLICY "Allow public access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'product-images');

