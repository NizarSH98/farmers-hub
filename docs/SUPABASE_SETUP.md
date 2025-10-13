# 🚀 Supabase Setup Guide — Farmer Hub Migration

**Total Setup Time: ~5 minutes**

This guide will help you migrate from Google Sheets to Supabase for a much better experience with **direct image uploads** and a real database.

---

## ✅ What You Get (100% Free Forever)

- **500MB Database** (thousands of listings)
- **1GB Image Storage** (hundreds of product photos)
- **Direct image uploads** from users' devices
- **Fast API** (no more slow Google Sheets)
- **Real-time updates** (optional)
- **Automatic backups**

---

## Step 1: Create Your Database Table

1. In your Supabase dashboard, go to **Table Editor** (left sidebar)
2. Click **"New Table"**
3. Name it: `listings`
4. **Uncheck** "Enable Row Level Security (RLS)" for now
5. Add these columns by clicking **"Add Column"** for each:

| Column Name | Type | Default Value | Nullable |
|------------|------|---------------|----------|
| `id` | `int8` | Auto (Identity) | ❌ No |
| `created_at` | `timestamptz` | `now()` | ❌ No |
| `name` | `text` | - | ❌ No |
| `phone` | `text` | - | ❌ No |
| `email` | `text` | - | ✅ Yes |
| `product` | `text` | - | ❌ No |
| `quantity` | `text` | - | ✅ Yes |
| `price` | `text` | - | ✅ Yes |
| `location` | `text` | - | ❌ No |
| `harvest_date` | `date` | - | ✅ Yes |
| `image_url` | `text` | - | ✅ Yes |
| `description` | `text` | - | ✅ Yes |

6. Click **"Save"**

> **Note**: The `id` should be set as the **Primary Key** (this happens automatically if you use Identity)

---

## Step 2: Create Storage Bucket for Images

1. Go to **Storage** (left sidebar)
2. Click **"New Bucket"**
3. Name it: `product-images`
4. **Make it Public** (check "Public bucket")
5. Click **"Create Bucket"**

### Set Storage Policies (Allow Anyone to Upload)

1. Click on the `product-images` bucket
2. Go to **"Policies"** tab
3. Click **"New Policy"** → **"For full customization"**
4. **Policy Name**: `Allow public uploads`
5. **Allowed operations**: SELECT + INSERT
6. **Policy definition**:
   ```sql
   true
   ```
7. Click **"Review"** → **"Save Policy"**

---

## Step 3: Get Your API Credentials

1. Go to **Project Settings** (gear icon, bottom left)
2. Click **"API"** in the sidebar
3. Copy these two values:

   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (long string)

4. Keep these handy for the next step!

---

## Step 4: Update Your HTML Files

Open **`index.html`** and **`market.html`** and find this section near the top of the `<script>` tag:

```javascript
// === CONFIG ===
const SUPABASE_URL = "PASTE_YOUR_PROJECT_URL_HERE";
const SUPABASE_KEY = "PASTE_YOUR_ANON_KEY_HERE";
```

Replace with your actual values from Step 3.

---

## Step 5: Deploy & Test

1. **Upload the updated files** to your hosting (GitHub Pages / Netlify / Vercel)
2. Open your live site
3. Click **"🧪 Fill Test Data"** button
4. Upload a test image
5. Submit the form
6. Go to marketplace and verify it appears!

---

## 🔒 Optional: Enable Row Level Security (Later)

Once you're comfortable, you can enable RLS for better security:

1. Go to **Table Editor** → `listings` table
2. Click **"Enable RLS"**
3. Add policies for read (public) and write (with validation)

For now, the shared secret in the frontend provides basic protection.

---

## 📊 Viewing Your Data

- **Database**: Table Editor → `listings` table
- **Images**: Storage → `product-images` bucket
- **API Logs**: Logs → API Logs (see all requests)

---

## 💾 Backup Your Old Data (Optional)

If you want to migrate existing Google Sheets data:

1. Export your sheet as CSV
2. Go to Supabase **Table Editor** → `listings`
3. Click **"Insert"** → **"Import data from CSV"**
4. Upload your CSV (map columns correctly)

---

## 🎉 You're Done!

Your farmer hub now has:
- ✅ Direct image uploads
- ✅ Real database
- ✅ Much faster performance
- ✅ Better UX for farmers
- ✅ Still 100% FREE

---

## 🆘 Troubleshooting

**"Failed to upload image"**
- Check Storage policies are set correctly
- Ensure bucket is public
- Verify SUPABASE_URL and SUPABASE_KEY are correct

**"Failed to submit listing"**
- Check that RLS is disabled or policies allow INSERT
- Verify table name is exactly `listings`
- Check browser console for detailed errors

**"Images not showing in marketplace"**
- Ensure bucket is public
- Check that image_url column exists in table
- Verify image upload was successful (check Storage bucket)

---

**Need Help?** Check Supabase docs: https://supabase.com/docs

