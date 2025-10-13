# 🌾 Farmer Hub — Direct-to-Consumer Agricultural Marketplace

A beautiful, modern, **100% FREE** web platform connecting farmers directly with buyers. No servers, no monthly fees, no hassle.

![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Cost](https://img.shields.io/badge/cost-FREE%20forever-success)

---

## ✨ Features

### For Farmers (Sellers)
- 📝 **Easy submission form** — list products in under 2 minutes
- 📸 **Direct image upload** — drag & drop product photos (no URL needed!)
- 🤖 **Smart autocomplete** — suggests previously used products and locations
- ✅ **Mobile-friendly** — submit from phone or desktop

### For Buyers
- 🔍 **Powerful search & filters** — find exactly what you need
- 📍 **Location-based** — discover local farmers in your area
- 💰 **Price comparison** — sort by price, date, or name
- 📱 **One-tap contact** — WhatsApp, call, or email sellers directly

### Technical
- ⚡ **Blazing fast** — real database (PostgreSQL via Supabase)
- 🖼️ **1GB image storage** — automatic uploads and CDN delivery
- 🔄 **Real-time updates** — new listings appear instantly
- 🎨 **Beautiful UI** — modern dark theme with smooth animations
- 📱 **Fully responsive** — perfect on all devices

---

## 🎯 Quick Start (5 Minutes)

### 1. Set Up Supabase (FREE)

1. Create account at [supabase.com](https://supabase.com)
2. Create a new project
3. Follow our **[Supabase Setup Guide](SUPABASE_SETUP.md)** (step-by-step with screenshots)

### 2. Configure Your Site

Open `index.html` and `market.html`, find this section and add your credentials:

```javascript
// === CONFIG ===
const SUPABASE_URL = "https://xxxxx.supabase.co";  // From Supabase dashboard
const SUPABASE_KEY = "eyJhbGc...";                  // From Supabase dashboard
```

### 3. Deploy for FREE

Choose any free hosting:

**GitHub Pages** (Easiest)
```bash
git init
git add .
git commit -m "Initial commit"
git push origin main
# Enable Pages in repo settings
```

**Netlify** (Fastest)
- Drag & drop files at [netlify.com/drop](https://app.netlify.com/drop)
- Done!

**Vercel**
```bash
vercel deploy
```

---

## 📁 Project Structure

```
farmers-hub/
├── index.html              # Submission form (farmers list their products)
├── market.html             # Public marketplace (buyers browse & contact)
├── SUPABASE_SETUP.md       # Complete Supabase configuration guide
├── MIGRATION_GUIDE.md      # Migrate from Google Sheets (if applicable)
├── README.md               # You are here!
└── apps_script.gs          # (DEPRECATED - legacy Google Sheets backend)
```

---

## 🆓 What's FREE Forever?

| Resource | Free Tier | Enough For |
|----------|-----------|------------|
| **Database** | 500MB | ~50,000 listings |
| **Image Storage** | 1GB | ~500-1000 product photos |
| **Bandwidth** | 2GB/month | ~10,000 page views |
| **API Requests** | Unlimited* | Any amount of traffic |
| **Hosting** | Free | GitHub Pages / Netlify / Vercel |

*Rate limits apply but are generous for small-medium sites

---

## 🖼️ Image Upload System

### How It Works
1. Farmer clicks/drags image into upload area
2. Image preview shows instantly
3. On submit:
   - Listing saved to database
   - Image uploaded to Supabase Storage
   - Public URL automatically generated
   - Listing updated with image link
4. Buyers see images on marketplace immediately

### Supported Formats
- ✅ JPG/JPEG
- ✅ PNG
- ✅ WebP
- ✅ GIF (static or animated)
- 📏 Max 5MB per image

### Storage Structure
```
product-images/
├── 1-1699876543210.jpg    # listingID-timestamp.ext
├── 2-1699876678901.png
└── 3-1699876890123.webp
```

---

## 🛠️ Customization

### Colors & Theme

Edit CSS variables in `index.html` and `market.html`:

```css
:root { 
  --accent: #6366f1;           /* Primary brand color */
  --bg-primary: #0a0e1a;       /* Page background */
  --text: #f3f4f6;             /* Body text */
  /* ... */
}
```

### Add More Fields

1. **Database**: Add column in Supabase table editor
2. **Form**: Add input in `index.html`
3. **Submission**: Update payload object
4. **Display**: Update `market.html` rendering

Example: Add "Organic Certified" checkbox

```javascript
// In payload
organic: formData.get('organic') === 'on'
```

### Enable Row Level Security (RLS)

Once comfortable with Supabase:

1. Table Editor → `listings` → Enable RLS
2. Add policies:
   - **Read**: Allow all (public marketplace)
   - **Insert**: Custom validation logic

---

## 🔒 Security

### Current Protection
- Form validation (required fields)
- File type validation (images only)
- File size limits (5MB max)
- Supabase handles SQL injection, XSS automatically

### Optional Enhancements
- Enable RLS for database-level security
- Add reCAPTCHA to prevent spam
- Implement rate limiting
- Add content moderation

---

## 📊 Monitoring & Analytics

### View Your Data
- **Database**: Supabase Table Editor
- **Images**: Supabase Storage Browser
- **API Usage**: Supabase Dashboard → Reports

### Add Analytics

Insert before `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## 🐛 Troubleshooting

### "Failed to upload image"
- Check Storage bucket is **public**
- Verify storage policies allow INSERT
- Ensure SUPABASE_URL and KEY are correct

### "Failed to submit listing"
- Disable RLS initially for testing
- Check browser console for detailed errors
- Verify table name is exactly `listings`

### "No products showing"
- Check Supabase Table Editor has data
- Verify SUPABASE credentials in marketplace
- Check browser console for errors

### Images Not Loading
- Verify bucket is public
- Check image URLs in table are valid
- Test URL directly in browser

**More help**: See [SUPABASE_SETUP.md](SUPABASE_SETUP.md#troubleshooting)

---

## 🚀 Scaling Up

When your platform grows:

### Performance
- Supabase auto-scales to 10,000+ listings
- Add database indexes for faster searches
- Enable Supabase CDN for images

### Features
- Add user authentication (login/signup)
- Implement favorites/bookmarks
- Add in-app messaging
- Payment processing integration
- Admin dashboard for moderation

### Costs
Free tier handles most small-medium sites. If you outgrow it:
- Supabase Pro: $25/month (100GB storage)
- Still cheaper than traditional hosting!

---

## 🌍 Localization

Change text/language in HTML files:

```html
<!-- English -->
<h1>Local Produce Marketplace</h1>

<!-- Arabic -->
<h1>سوق المنتجات المحلية</h1>

<!-- French -->
<h1>Marché des Produits Locaux</h1>
```

For RTL languages (Arabic, Hebrew), add:

```html
<html lang="ar" dir="rtl">
```

---

## 🤝 Contributing

Contributions welcome! Areas needing help:
- Translation to other languages
- Mobile app wrapper (React Native)
- Payment integration
- Analytics dashboard
- Unit tests

---

## 📜 License

MIT License - feel free to use for commercial projects!

---

## 🙏 Credits

Built with:
- [Supabase](https://supabase.com) — Backend & Storage
- [Inter Font](https://rsms.me/inter/) — Typography
- Pure HTML/CSS/JS — No frameworks needed!

---

## 📞 Support

- 📖 Read [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for setup help
- 🔄 See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for migration from Google Sheets
- 🐛 Open an issue for bugs
- 💡 Discussions for feature requests

---

## ⭐ Success Stories

Using Farmer Hub for your community? Let us know! We'd love to feature your story.

---

**Made with ❤️ for farmers and local communities worldwide** 🌾

