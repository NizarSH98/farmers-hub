# Farmer Hub V2 Updates

## What's New

### 1. Light/Dark Mode Toggle
- **Default**: Light mode (clean white background)
- **Toggle**: Button in navigation switches between light/dark
- **Persistent**: Choice saved in localStorage
- **Comprehensive**: All colors properly themed for both modes

### 2. Bilingual Product Names
- **Arabic Name**: Required field (primary)
- **English Name**: Optional field
- **Display**: Both names shown side-by-side in marketplace
- **Search**: Can search in both languages

### 3. Seasonal Availability
- **Month Selector**: Toggle buttons for each month + "All Year" option
- **Out of Season**: Products not in current month appear darkened (60% opacity)
- **Still Contactable**: Contact buttons work even when out of season
- **Visual Indicator**: Badge shows "Out of Season" or availability months

## Database Changes Required

Run this SQL in your Supabase SQL Editor:

```sql
-- Add product_ar column (Arabic product name - required)
ALTER TABLE listings ADD COLUMN IF NOT EXISTS product_ar TEXT;

-- Add availability column (stores months as JSON array or 'all')
ALTER TABLE listings ADD COLUMN IF NOT EXISTS availability TEXT DEFAULT 'all';

-- Add index for product_ar for faster searching
CREATE INDEX IF NOT EXISTS idx_listings_product_ar ON listings(product_ar);

-- Add comments
COMMENT ON COLUMN listings.product_ar IS 'Product name in Arabic (required)';
COMMENT ON COLUMN listings.product IS 'Product name in English (optional)';
COMMENT ON COLUMN listings.availability IS 'Availability months as JSON array (e.g. ["1","3","6"]) or "all"';

-- Make product column nullable (it's now optional, Arabic is required)
ALTER TABLE listings ALTER COLUMN product DROP NOT NULL;
```

## Files Updated

### ✅ Completed:
1. **index.html** - Submission form with all new features
2. **update_schema_v2.sql** - Database schema update

### ⏳ In Progress:
3. **index-ar.html** - Arabic submission form
4. **market.html** - English marketplace
5. **market-ar.html** - Arabic marketplace

## Testing Checklist

After all updates:
- [ ] Run SQL script in Supabase
- [ ] Test light/dark mode toggle
- [ ] Submit a test listing with Arabic & English names
- [ ] Set availability to specific months
- [ ] Check marketplace displays bilingual names
- [ ] Verify out-of-season products are darkened
- [ ] Test all contact buttons work
- [ ] Check mobile responsiveness
- [ ] Commit and push to GitHub

## Key Features

### Theme Toggle Implementation
```javascript
// Light mode (default)
const savedTheme = localStorage.getItem('theme') || 'light';
htmlEl.setAttribute('data-theme', savedTheme);

// CSS uses data-theme attribute
:root { /* light mode colors */ }
[data-theme="dark"] { /* dark mode colors */ }
```

### Availability Check
```javascript
// Check if product is in season
function isInSeason(availability) {
  if (availability === 'all') return true;
  const currentMonth = new Date().getMonth() + 1;
  const months = JSON.parse(availability);
  return months.includes(currentMonth);
}
```

### Display Format
```
Product Card:
┌─────────────────────────────┐
│ 🖼️ Image                     │
├─────────────────────────────┤
│ زيت زيتون • Olive Oil       │
│ 📍 Location                  │
│ 📦 Quantity • 💰 Price       │
│ Description...               │
│ [WhatsApp] [Call] [Email]   │
│ Seller • Date                │
└─────────────────────────────┘

When out of season: Entire card 60% opacity + badge
```

## Migration Notes

### Existing Data
- Old listings without `product_ar` will show only English name
- Old listings without `availability` default to "all" (always available)
- Recommend asking users to update their listings

### Backward Compatibility
- English-only products still work
- Products without availability are always shown
- All existing functionality preserved

## Next Steps

1. **Run SQL Update**: Execute `update_schema_v2.sql` in Supabase
2. **Test Locally**: Open index.html and test submission
3. **Deploy**: Push to GitHub and wait for Pages to rebuild
4. **Notify Users**: Inform farmers about new bilingual feature
5. **Update Old Listings**: Optionally add Arabic names to existing products


