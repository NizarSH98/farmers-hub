# 🔐 Admin System Setup Guide

This guide will help you set up the user verification system and admin panel.

---

## 🎯 What You Get

- **Admin Panel** - Manage verified users and delete listings
- **User Authentication** - Only approved users can submit listings
- **Auto-Generated Passwords** - Easy user onboarding
- **Listing Tracking** - Know who created each listing

---

## 📋 Step 1: Create the Users Table

Go to Supabase **SQL Editor** and run the SQL from `create_verified_users_table.sql`:

```sql
-- Copy and paste this entire script

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
INSERT INTO verified_users (username, password, full_name, phone, email, notes)
VALUES ('admin', 'admin123', 'Administrator', '', '', 'System administrator account');
```

✅ Click **"Run"** - You should see: "Success"

---

## 🔒 Step 2: Change Admin Password

**IMPORTANT:** Change the default admin password immediately!

### Option 1: Change in Code (Recommended)

1. Open `admin.html` in your code editor
2. Find line ~14:
   ```javascript
   const ADMIN_PASSWORD = "admin123"; // Change this to your secure password!
   ```
3. Change to a strong password:
   ```javascript
   const ADMIN_PASSWORD = "YourSecurePassword2024!";
   ```
4. Save and push to GitHub

### Option 2: Remove Sample Admin User

1. After first login, delete the `admin` user from the Users tab
2. Create your own admin user with a different username

---

## 🎉 Step 3: Access Admin Panel

1. Go to: `https://nizarsh98.github.io/farmers-hub/admin.html`
2. Enter password: `admin123` (or your custom password)
3. You're in! 🎊

---

## 👥 Step 4: Add Your First Farmer

1. In Admin Panel, click **"👥 Verified Users"** tab
2. Click **"+ Add New User"** button
3. Fill in the form:
   - **Username**: `john_farmer` (any unique username)
   - **Password**: Auto-generated (shown in the form)
   - **Full Name**: John Doe
   - **Phone**: +961... (optional)
   - **Email**: john@example.com (optional)
   - **Notes**: Any notes about this user (optional)
4. Click **"✓ Create User"**

✅ **Done!** The farmer can now submit listings using their username and password.

---

## 📝 How Farmers Submit Listings

1. Farmer goes to: `https://nizarsh98.github.io/farmers-hub/`
2. **First**, they enter their **username** and **password** (provided by you)
3. Then fill in the rest of the form (product, contact, etc.)
4. Upload image and submit!

---

## 🗑️ Deleting Listings

As admin, you can delete any listing:

1. Go to Admin Panel → **"📦 Manage Listings"** tab
2. Find the listing you want to remove
3. Click **"Delete"** button
4. Confirm deletion

✅ The listing AND its image are permanently deleted.

---

## 🔑 Managing Users

### Add New User
- Click **"+ Add New User"**
- Password is auto-generated (farmer will use this to login)
- You can click **"🔄 Generate New Password"** if you want a different one

### Delete User
- Click **"Delete"** button next to the user
- ⚠️ This doesn't delete their listings (just prevents new ones)

### View User Credentials
- All usernames and passwords are visible in the Users table
- ✅ You can copy/paste to send to farmers via WhatsApp/Email

---

## 📊 Dashboard Stats

The admin panel shows:
- **Verified Users** - Total number of approved farmers
- **Total Listings** - All listings in database
- **Listings Today** - Submissions in the last 24 hours

---

## 🔐 Security Features

✅ **Password-protected admin panel** - Only you can access  
✅ **User verification** - Only approved users can submit  
✅ **No anonymous submissions** - Every listing tracked to a user  
✅ **Active/Inactive users** - Deactivate problematic users  
✅ **Admin can delete any listing** - Full moderation control  

---

## ⚙️ Advanced: Customize Admin Password

### Method 1: Environment Variable (More Secure)

Instead of hardcoding the password in `admin.html`, you can use a prompt:

```javascript
// In admin.html, change:
const ADMIN_PASSWORD = "admin123";

// To:
const ADMIN_PASSWORD = prompt("Enter admin password:") || "admin123";
```

### Method 2: Multi-Admin System

Create multiple admin users in the `verified_users` table and check against those.

---

## 🚨 Troubleshooting

### "Failed to create user"
- Check that username is unique
- Verify `verified_users` table exists
- Check browser console for detailed error

### "Invalid username or password" on submission form
- Verify user exists in Admin Panel → Users tab
- Check username/password are entered correctly (case-sensitive)
- Ensure user status is "Active" (green badge)

### Can't login to admin panel
- Check that ADMIN_PASSWORD in `admin.html` matches what you're entering
- Clear browser cache and try again
- Check browser console for errors

### Listings not showing user info
- Old listings (before adding user system) won't have `user_id`
- New listings will be tracked properly
- You can manually add `user_id` to old listings via SQL if needed

---

## 📋 Default Credentials

**Admin Panel Login:**
- Password: `admin123`

**Sample User (from SQL):**
- Username: `admin`
- Password: `admin123`

**⚠️ CHANGE THESE IMMEDIATELY!**

---

## 🎯 Workflow Summary

1. **Admin**: Create user in admin panel → Copy username/password
2. **Admin**: Send credentials to farmer (WhatsApp/Email/SMS)
3. **Farmer**: Visit submission form → Enter username/password → Submit listing
4. **Admin**: Monitor listings in admin panel → Delete spam if needed

---

## 🆘 Need Help?

- Check browser console (F12) for detailed errors
- Verify Supabase table structures match SQL
- Make sure GitHub Pages is updated with latest code

---

**Your admin panel is ready!** 🎉

Access it at: `https://nizarsh98.github.io/farmers-hub/admin.html`

