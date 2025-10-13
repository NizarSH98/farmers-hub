# ⚡ Quick Start Checklist

Follow these steps to get your Farmer Hub live in 5 minutes.

---

## ✅ Step-by-Step Checklist

### [ ] 1. Supabase Setup (2 minutes)

1. **Create Database Table**
   - Go to [supabase.com](https://supabase.com) → Your Project → Table Editor
   - Click "New Table" → Name: `listings`
   - **Uncheck** "Enable RLS"
   - Add columns (see [SUPABASE_SETUP.md](SUPABASE_SETUP.md#step-1-create-your-database-table) for details)

2. **Create Storage Bucket**
   - Go to Storage → New Bucket
   - Name: `product-images`
   - ✅ Check "Public bucket"
   - Add policy: Allow all operations (see [SUPABASE_SETUP.md](SUPABASE_SETUP.md#step-2-create-storage-bucket-for-images))

3. **Get API Credentials**
   - Go to Project Settings (gear icon) → API
   - Copy:
     - Project URL: `https://xxxxx.supabase.co`
     - anon public key: `eyJhbGc...`

---

### [ ] 2. Configure HTML Files (1 minute)

**In both `index.html` AND `market.html`:**

Find this section near the top:
```javascript
const SUPABASE_URL = "https://YOUR_PROJECT.supabase.co";
const SUPABASE_KEY = "YOUR_ANON_KEY_HERE";
```

Replace with your actual values from Step 1.3 above.

---

### [ ] 3. Test Locally (1 minute)

1. Open `index.html` in your browser
2. Click "🧪 Fill Test Data"
3. Upload a test image
4. Click "✓ Submit Listing"
5. Open `market.html` → verify listing appears!

---

### [ ] 4. Deploy to Web (1 minute)

**Option A: Netlify (Easiest)**
1. Go to [app.netlify.com/drop](https://app.netlify.com/drop)
2. Drag & drop your two HTML files
3. Done! Copy your live URL

**Option B: GitHub Pages**
```bash
git init
git add index.html market.html
git commit -m "Initial commit"
git remote add origin YOUR_REPO_URL
git push -u origin main
# Enable Pages in repo Settings
```

**Option C: Vercel**
```bash
npm i -g vercel
vercel
```

---

### [ ] 5. Share & Test (30 seconds)

1. Visit your live site
2. Submit a real listing with an image
3. Check marketplace
4. Test WhatsApp/Call/Email buttons
5. Share with farmers! 🎉

---

## 🚨 Common Issues

### "Not authorized to insert" or "Failed to submit"
→ **Solution**: Disable RLS on `listings` table
   - Table Editor → `listings` → Click table name → Disable RLS

### "Failed to upload image"
→ **Solution**: Make storage bucket public
   - Storage → `product-images` → Settings → Public Access: ON
   - Add policy: Allow INSERT and SELECT (see setup guide)

### "SUPABASE_URL is not defined"
→ **Solution**: Update BOTH files (`index.html` AND `market.html`)
   - Check for typos in URL/KEY
   - Ensure you saved both files before deploying

### Images not showing
→ **Solution**: 
   - Verify bucket is public
   - Check Table Editor → image_url column has valid URLs
   - Test URL directly in browser address bar

---

## 📚 Next Steps

Once everything works:

- [ ] Read [README.md](README.md) for customization options
- [ ] Add your branding/colors
- [ ] Share with your farming community
- [ ] Optional: Enable RLS for better security (see setup guide)

---

## 🎯 Expected Results

After completing this checklist:

✅ Farmers can submit listings with photos in < 2 minutes  
✅ Buyers can browse, search, and contact farmers  
✅ Images upload automatically (no external hosting needed)  
✅ Everything loads fast and looks beautiful  
✅ 100% FREE with generous limits  

---

**Need Help?**
- Detailed guide: [SUPABASE_SETUP.md](SUPABASE_SETUP.md)
- Migration from Sheets: [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
- Full docs: [README.md](README.md)

---

**Stuck?** Check [SUPABASE_SETUP.md](SUPABASE_SETUP.md#troubleshooting) troubleshooting section!

