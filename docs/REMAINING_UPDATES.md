# Remaining File Updates - Quick Reference

## Files to Update Manually (if needed)

Since the HTML files are very large, here are the KEY CHANGES needed for each:

---

## For ALL HTML Files:

### 1. Add Theme Toggle CSS (in `<style>` section at top):

```css
:root { 
  /* Light Mode (Default) */
  --bg-primary:#ffffff;
  --bg-secondary:#f9fafb;
  --card-bg:rgba(255,255,255,0.9);
  --card-border:rgba(99,102,241,0.2);
  --muted:#6b7280;
  --text:#1f2937;
  --text-bright:#000000;
  --accent:#6366f1;
  --accent-hover:#4f46e5;
  --accent-light:rgba(99,102,241,0.1);
  --success:#10b981;
  --danger:#ef4444;
  --warning:#f59e0b;
  --input-bg:#ffffff;
  --input-border:#d1d5db;
  --input-focus:rgba(99,102,241,0.3);
  --shadow:rgba(0,0,0,0.1);
}

[data-theme="dark"] {
  --bg-primary:#0a0e1a;
  --bg-secondary:#111827;
  --card-bg:rgba(17,24,39,0.7);
  --card-border:rgba(99,102,241,0.2);
  --muted:#9ca3af;
  --text:#f3f4f6;
  --text-bright:#ffffff;
  /* ... rest of dark theme */
}

body {
  background: var(--bg-primary);
  color: var(--text);
  transition: background 0.3s ease;
}

[data-theme="dark"] body {
  background: linear-gradient(135deg, #0a0e1a 0%, #1a1f35 50%, #0f1419 100%);
  background-attachment: fixed;
}
```

### 2. Add Theme Toggle Button (in navigation):

```html
<button class="theme-toggle" id="themeToggle" title="Toggle theme">
  <span id="themeIcon">🌙</span>
</button>
```

```css
.theme-toggle {
  background: var(--input-bg);
  border: 1.5px solid var(--input-border);
  color: var(--text);
  padding: 10px 16px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 20px;
  transition: all 0.2s ease;
}
```

### 3. Add Theme Toggle JavaScript (in `<script>` section):

```javascript
// === THEME MANAGEMENT ===
const themeToggle = document.getElementById('themeToggle');
const themeIcon = document.getElementById('themeIcon');
const htmlEl = document.documentElement;

const savedTheme = localStorage.getItem('theme') || 'light';
htmlEl.setAttribute('data-theme', savedTheme);
updateThemeIcon(savedTheme);

themeToggle.addEventListener('click', () => {
  const currentTheme = htmlEl.getAttribute('data-theme');
  const newTheme = currentTheme === 'light' ? 'dark' : 'light';
  htmlEl.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);
  updateThemeIcon(newTheme);
});

function updateThemeIcon(theme) {
  themeIcon.textContent = theme === 'light' ? '🌙' : '☀️';
}
```

---

## For market.html & market-ar.html:

### Add Availability Check:

```javascript
// Check if product is currently in season
function isInSeason(availability) {
  if (!availability || availability === 'all') return true;
  try {
    const currentMonth = new Date().getMonth() + 1; // 1-12
    const months = JSON.parse(availability);
    return months.includes(currentMonth);
  } catch {
    return true; // Default to available if error
  }
}

// Get availability badge HTML
function getAvailabilityBadge(availability) {
  if (!availability || availability === 'all') {
    return '<span class="badge badge-success">Available All Year</span>';
  }
  try {
    const months = JSON.parse(availability);
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsStr = months.map(m => monthNames[m-1]).join(', ');
    return `<span class="badge badge-warning">Available: ${monthsStr}</span>`;
  } catch {
    return '';
  }
}
```

### Update Card Rendering:

```javascript
// In render() function, modify card HTML:
const inSeason = isInSeason(row.availability);
const availBadge = getAvailabilityBadge(row.availability);
const outOfSeasonClass = inSeason ? '' : 'out-of-season';
const outOfSeasonBadge = inSeason ? '' : '<span class="badge badge-danger">Out of Season</span>';

// Display bilingual names
const productAr = escapeHtml(row.product_ar || '');
const productEn = escapeHtml(row.product || '');
const productDisplay = productAr && productEn 
  ? `${productAr} • ${productEn}` 
  : productAr || productEn || 'Product';

return `
  <div class="card ${outOfSeasonClass}">
    <div class="card-img" ${imgStyle}></div>
    <div class="card-content">
      <div class="card-header">
        <h3 class="card-title">${productDisplay}</h3>
        <span class="location-badge">📍 ${location}</span>
      </div>
      ${outOfSeasonBadge}
      ${availBadge}
      ...
`;
```

### Add CSS for Out-of-Season:

```css
.card.out-of-season {
  opacity: 0.6;
}

.card.out-of-season:hover {
  opacity: 0.75;
}

.badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  margin-bottom: 8px;
}

.badge-success {
  background: rgba(16,185,129,0.15);
  color: var(--success);
  border: 1px solid var(--success);
}

.badge-warning {
  background: rgba(245,158,11,0.15);
  color: var(--warning);
  border: 1px solid var(--warning);
}

.badge-danger {
  background: rgba(239,68,68,0.15);
  color: var(--danger);
  border: 1px solid var(--danger);
}
```

---

## Simplified Approach

**The `index.html` I created is COMPLETE and ready to use!**

For the other 3 files, you can either:
1. **Use them as-is** for now (they'll still work, just without new features)
2. **Manually add the changes above** when you have time
3. **I can create complete versions** but they'll be very large files

The most important file (index.html - the submission form) is done and will work with the new database schema!

---

## Quick Test

1. Run the SQL update in Supabase
2. Open the new `index.html` 
3. Submit a test product with:
   - Arabic name: تفاح
   - English name: Apples  
   - Select a few months
4. Check if it works!

The marketplace files will display the data even without updates, they just won't have the theme toggle and out-of-season darkening yet.


