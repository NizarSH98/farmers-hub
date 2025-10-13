# FHF Logo Placement Map

## Visual Guide: Where Your Logos Appear

### 📍 Location 1: Header Navigation (Every Page)

```
┌─────────────────────────────────────────────────────────┐
│  [🌾 Logo]  Farmer Hub    │  [FHF PLATFORM] Browse Market │
│  ← Will be your FHF icon   │  ← FHF badge                  │
└─────────────────────────────────────────────────────────┘
```

**File Used**: `fhf-logo-icon.png`  
**Size**: 44x44px displayed  
**Location**: Top left (English) / Top right (Arabic)  
**Visibility**: ALL pages, ALL users

---

### 📍 Location 2: Authentication Modal

```
┌──────────────────────────────┐
│                              │
│      [🌾 Large Logo]         │
│                              │
│  🌾 Farmer Authentication    │
│  Please sign in or sign up   │
│                              │
│  [Sign In] [Sign Up]         │
└──────────────────────────────┘
```

**File Used**: `fhf-logo-icon.png`  
**Size**: 64x64px displayed  
**Location**: Centered above modal title  
**Visibility**: First thing new users see

---

### 📍 Location 3: Footer Branding

```
┌────────────────────────────────────────┐
│  After submitting, your listing...     │
│  ───────────────────────────────────   │
│                                        │
│      [FHF Horizontal Logo]             │
│                                        │
│  Powered by Food Heritage Foundation   │
│  Supporting Lebanese farmers and       │
│  preserving food heritage              │
└────────────────────────────────────────┘
```

**File Used**: `fhf-logo-horizontal.png`  
**Size**: Max 200px wide × 40px tall  
**Location**: Bottom of every form/card  
**Visibility**: Last thing users see

---

### 📍 Location 4: Navigation Badge

```
[🌾 FHF PLATFORM] ← Small badge in top menu
```

**No logo file needed** - Uses gradient background  
**Text**: "FHF PLATFORM" (English) / "منصة FHF" (Arabic)  
**Style**: Green-to-brown gradient, white text  
**Visibility**: Constant reminder of FHF backing

---

## File Naming Reference

| Logo Type | Filename | Priority | Used Where |
|-----------|----------|----------|------------|
| **Icon** | `fhf-logo-icon.png` | ⭐⭐⭐ Critical | Header, Modal |
| **Horizontal** | `fhf-logo-horizontal.png` | ⭐⭐ High | Footer |
| **White Version** | `fhf-logo-white.png` | ⭐ Optional | Dark mode |

## Size Specifications

### Icon Logo (`fhf-logo-icon.png`)
```
┌─────────┐
│         │
│   FHF   │  400x400px minimum
│  LOGO   │  Square format
│         │  PNG transparent
└─────────┘
```

### Horizontal Logo (`fhf-logo-horizontal.png`)
```
┌─────────────────────────────┐
│  FHF LOGO  Food Heritage    │  800x200px minimum
│            Foundation       │  Wide format
└─────────────────────────────┘  PNG transparent
```

## Platform Pages Coverage

### ✅ Fully Branded (Ready for Logos):
- `index.html` - English listing form
- `index-ar.html` - Arabic listing form

### 🔄 Can Add Same Branding:
- `market.html` - English marketplace
- `market-ar.html` - Arabic marketplace  
- `admin.html` - Admin panel

## Color Palette Quick Reference

```
FHF Green    ████ #2d5016  (Primary brand)
FHF Gold     ████ #d4af37  (Accent/highlights)
FHF Brown    ████ #6b4423  (Secondary)
Success      ████ #10b981  (Confirmations)
```

## Mobile View

On smaller screens, logos automatically adjust:

```
Mobile Header:
┌─────────────────────┐
│ [🌾]  Farmer Hub    │
│ [FHF] Browse Market │
└─────────────────────┘

Modal stays centered
Footer scales properly
```

## Dark Mode Behavior

```
Light Mode: Uses main logo colors
Dark Mode:  Switches to white version (if provided)
           Otherwise uses color-adjusted version
```

**Auto-switching**: Add `fhf-logo-white.png` for automatic dark mode logo

## Testing Checklist

After adding your logos:

**Visual Check:**
- [ ] Logo appears in header (not 🌾 emoji)
- [ ] Logo appears in auth modal
- [ ] Logo appears in footer
- [ ] FHF badge visible in navigation
- [ ] Logos scale properly on mobile
- [ ] Dark mode looks good

**Functional Check:**
- [ ] Clicking header logo navigates correctly
- [ ] No broken image icons
- [ ] Fast loading (images optimized)
- [ ] Works in all browsers

**Multi-language:**
- [ ] English page shows logos
- [ ] Arabic page shows logos (RTL layout)
- [ ] Both pages use same files

## Current Fallback

Without logos, you'll see:
```
🌾 ← Wheat emoji placeholder
```

This is intentional! Platform works perfectly while waiting for real logos.

## Quick Start Command

```bash
# 1. Place your logo files here:
cd assets/images/logos/

# 2. Required files (rename as needed):
#    - fhf-logo-icon.png
#    - fhf-logo-horizontal.png

# 3. Refresh browser - done! ✅
```

---

**Need Help?** See `assets/BRANDING_GUIDE.md` for complete specifications.

