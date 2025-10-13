# ⚠️ LEGACY: Google Sheets Backend (DEPRECATED)

> **Note**: This guide is for the old Google Sheets backend. We now recommend using **Supabase** for much better features including direct image uploads!
> 
> **👉 See [QUICKSTART.md](QUICKSTART.md) for the new setup (5 minutes)**

---

## Old System Documentation (Google Sheets)

This repo gives you a ready-to-deploy, **free** mini-platform:

- **`index.html`** — Farmers submit their product listing (name, contact, product, price, location, etc.).
- **`market.html`** — Public marketplace to **search, filter, and contact** farmers (WhatsApp/Call/Email).
- **`apps_script.gs`** — Google Apps Script that stores submissions in **Google Sheets** and serves them as JSON.

No servers, no fees. Host the two HTML pages on **GitHub Pages / Netlify / Vercel**, and use **Google Sheets** as your database via the Apps Script web app.

---

## 1) Create the Google Sheet

1. In Google Drive, create a new **Google Sheet** named e.g. `FarmerHub`.
2. Copy the **Sheet ID** from the URL (the long string after `/d/`).
3. You don't need to pre-create columns; the script will add a header row automatically.

---

## 2) Add the Apps Script backend

1. In the Sheet, go to **Extensions → Apps Script**.
2. Delete the default code and paste **`apps_script.gs`**.
3. In the code, set:
   - `SHEET_ID = 'YOUR_SHEET_ID_HERE'`
   - `SHARED_SECRET = 'some-long-random-string'` (generate any random string; copy it for later)
4. **Deploy** → **Manage deployments** → **New deployment** → **Web app**:
   - **Who has access**: `Anyone`
   - Click **Deploy** and copy the **Web app URL**.

> If your account doesn't allow public access, pick "Anyone with the link" (if available), or publish under a workspace that allows it.

---

## 3) Wire the frontend pages

Open **`index.html`** and **`market.html`**, and set:

- `APPS_SCRIPT_URL = "YOUR_WEB_APP_URL_HERE"`
- `SHARED_SECRET = "the same string you used in Apps Script"` (in `index.html` only)

> Search for `REPLACE_WITH_...` to find all placeholders.

---

## 4) Host the pages for free

Any static hosting works. Examples:

### GitHub Pages
1. Create a repo, add `index.html` and `market.html`.
2. Commit and push.
3. Repo Settings → Pages → Branch: `main` (or `master`), folder: `/root`. Save.
4. Your site will be live at `https://<your-username>.github.io/<repo>/`.

### Netlify
1. Drag-and-drop the two HTML files on https://app.netlify.com/drop.
2. Or connect your Git repo.
3. Update the site domain from the Netlify dashboard.

### Vercel
1. Create a project from your Git repo.
2. Build output is static (no frameworks needed).

---

## 5) Test

- Open `index.html` from your hosted site.
- Fill the form and submit. You should see **"Listing submitted ✅"**.
- Open `market.html` and confirm your listing appears.
- Listings auto-refresh every 30 seconds.

---

## 6) Optional tweaks

- **Restrict CORS** in `apps_script.gs` by replacing `ALLOWED_ORIGINS = ['*']` with your domain(s).
- Add more fields (varieties, certifications, delivery options) — just add inputs and append to the Apps Script row.
- Export to CSV by using Google Sheet’s native export.
- Moderate entries by adding a new column (e.g., `approved`) and returning only approved rows in `doGet`.

---

## Troubleshooting

- **403 Unauthorized** on submit → Check that `SHARED_SECRET` matches in both the HTML and Apps Script.
- **Failed to load data** in marketplace → Confirm you deployed the Apps Script as a Web app and used the correct URL in the HTML.
- **No entries show** → Ensure the Sheet has at least the header row (the script adds it automatically on first run). Submit one test entry.

---

## Security Note

This is intentionally lightweight. The shared secret reduces casual spam. For stronger protections, add reCAPTCHA Enterprise or move to a free-tier DB like Supabase and restrict writes with Row Level Security.

---

Happy farming! 🌱
