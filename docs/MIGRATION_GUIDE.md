# 📦 Migration Guide: Google Sheets → Supabase

If you already have listings in Google Sheets and want to migrate them to Supabase, follow this guide.

---

## Option 1: Fresh Start (Recommended for New Projects)

**If you have no data or just test data:**

1. Complete the [Supabase setup](SUPABASE_SETUP.md)
2. Deploy the new HTML files
3. Start fresh with direct image uploads!

✅ **Done!** No migration needed.

---

## Option 2: Migrate Existing Data

**If you have real listings you want to keep:**

### Step 1: Export from Google Sheets

1. Open your Google Sheet with listings
2. **File** → **Download** → **Comma Separated Values (.csv)**
3. Save as `listings_export.csv`

### Step 2: Prepare the CSV

Open the CSV in a text editor and ensure the columns match this order:

```
timestamp,name,phone,email,product,quantity,price,location,harvest_date,image_url,description,secret
```

You can delete the `secret` column if present (not needed in Supabase).

### Step 3: Import to Supabase

1. Go to your Supabase dashboard
2. Navigate to **Table Editor** → `listings` table
3. Click **"Insert"** dropdown → **"Import data from CSV"**
4. Upload your `listings_export.csv`
5. Map the columns:
   - `timestamp` → `created_at`
   - `name` → `name`
   - `phone` → `phone`
   - `email` → `email`
   - `product` → `product`
   - `quantity` → `quantity`
   - `price` → `price`
   - `location` → `location`
   - `harvest_date` → `harvest_date`
   - `image_url` → `image_url`
   - `description` → `description`

6. Click **"Import"**

### Step 4: Verify

1. Check the **Table Editor** to see all your rows
2. Visit your marketplace (`market.html`) and verify listings appear
3. Existing image URLs should still work

---

## Option 3: Manual Entry (Small Datasets)

**If you have less than 10 listings:**

1. Set up Supabase
2. Go to the new `index.html` form
3. Manually re-enter each listing with proper images

This takes 2-3 minutes per listing but ensures you have proper image uploads.

---

## What About Images?

### Existing Image URLs
- If your old listings have working image URLs (e.g., from Imgur, Google Drive with public access), they'll continue to work in Supabase
- No action needed for existing images

### New Uploads
- All **new** submissions will use Supabase Storage
- Images are automatically uploaded and managed
- Much better UX for farmers!

### Migrating Images (Optional)

If you want to move old images to Supabase Storage:

1. Download each image from its current URL
2. Create a new listing in the form
3. Upload the downloaded image
4. Delete the old listing

---

## Parallel Running (Transition Period)

You can run both systems simultaneously during migration:

1. Keep your old Google Sheets system running
2. Set up new Supabase system on a different URL (e.g., `new.yoursite.com`)
3. Test thoroughly
4. When satisfied, redirect old URL → new URL
5. Archive Google Sheets

---

## Rolling Back (If Needed)

If something goes wrong:

1. Keep your old `index.html` and `market.html` files backed up
2. Your Google Sheet is unchanged
3. Simply re-deploy the old files
4. Supabase data remains safe for retry

---

## Common Migration Issues

### "CSV import failed"
- Ensure date formats are valid (YYYY-MM-DD)
- Remove any special characters in text fields
- Check that column names match exactly

### "Old images not showing"
- Verify image URLs are publicly accessible
- Test URLs directly in browser
- Some services (Google Drive) may have changed permissions

### "Data looks corrupted"
- Check CSV encoding (should be UTF-8)
- Ensure quotes are properly escaped
- Try importing smaller batches (50 rows at a time)

---

## Post-Migration Cleanup

After successful migration:

1. ✅ Test all features in new system
2. ✅ Verify search and filters work
3. ✅ Test new image uploads
4. ✅ Check WhatsApp/Call/Email buttons work
5. 🗑️ Archive (don't delete) Google Sheet as backup
6. 🗑️ Deactivate old Apps Script deployment (optional)

---

## Need Help?

- **Supabase Docs**: https://supabase.com/docs/guides/database/import-data
- **CSV Format Issues**: Use Excel → Save As → CSV UTF-8
- **Large Datasets**: Contact Supabase support for bulk import assistance

---

**Estimated Migration Time:**
- 0-10 listings: 5-15 minutes
- 10-50 listings: 15-30 minutes  
- 50+ listings: 30-60 minutes

Good luck! 🚀

