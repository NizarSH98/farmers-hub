# Food Heritage Foundation (FHF) - Branding Asset Guide

## 📁 Directory Structure

```
assets/
├── images/
│   ├── logos/
│   │   ├── fhf-logo-main.png          (Primary FHF logo - full color)
│   │   ├── fhf-logo-white.png         (White version for dark backgrounds)
│   │   ├── fhf-logo-icon.png          (Icon-only version for small spaces)
│   │   └── fhf-logo-horizontal.png    (Horizontal layout for headers)
│   └── branding/
│       ├── hero-background.jpg        (Optional hero/banner image)
│       └── pattern-overlay.png        (Optional decorative pattern)
└── BRANDING_GUIDE.md                  (This file)
```

## 🎨 Logo Specifications

### Primary Logo (`fhf-logo-main.png`)
- **Format**: PNG with transparent background
- **Recommended Size**: 400x400px minimum
- **Usage**: Main header, authentication modal, footer
- **Location in code**: Header brand section, auth modal header

### White Logo (`fhf-logo-white.png`)
- **Format**: PNG with transparent background
- **Recommended Size**: 400x400px minimum
- **Usage**: Dark theme mode, colored backgrounds
- **Location in code**: Automatically switches in dark mode

### Icon Logo (`fhf-logo-icon.png`)
- **Format**: PNG with transparent background
- **Recommended Size**: 128x128px minimum
- **Usage**: Favicon, mobile icon, small spaces
- **Location in code**: Browser tab icon, mobile home screen

### Horizontal Logo (`fhf-logo-horizontal.png`)
- **Format**: PNG with transparent background
- **Recommended Size**: 800x200px minimum
- **Usage**: Wide header layouts, email templates
- **Location in code**: Alternative header layout option

## 🎨 FHF Brand Colors (Pre-configured)

The platform is configured with professional colors suitable for agricultural/food heritage organizations:

### Primary Colors
- **FHF Green**: `#2d5016` (Primary brand color)
- **FHF Gold**: `#d4af37` (Accent color)
- **Warm Brown**: `#6b4423` (Secondary accent)

### Supporting Colors
- **Success Green**: `#10b981` (Confirmations, success states)
- **Alert Orange**: `#f59e0b` (Warnings, attention items)
- **Error Red**: `#ef4444` (Errors, critical actions)

### Neutral Colors
- **Dark Text**: `#1f2937` (Primary text, light mode)
- **Light Text**: `#f3f4f6` (Primary text, dark mode)
- **Muted Gray**: `#6b7280` (Secondary text, descriptions)

## 📐 Logo Placement Guide

### Header (Main Navigation)
- **Size**: 44x44px icon with 22px font brand name
- **Position**: Left side (English) / Right side (Arabic)
- **Padding**: 16px vertical, 24px horizontal
- **Logo file**: `fhf-logo-main.png` or `fhf-logo-icon.png`

### Authentication Modal
- **Size**: 64x64px icon centered
- **Position**: Top of modal, centered above title
- **Logo file**: `fhf-logo-icon.png`

### Footer
- **Size**: 32x32px icon or 150px wide horizontal logo
- **Position**: Center aligned with tagline
- **Logo file**: `fhf-logo-horizontal.png` or `fhf-logo-icon.png`

### Favicon
- **Size**: 32x32px, 16x16px (multiple sizes)
- **Format**: ICO or PNG
- **Logo file**: `fhf-logo-icon.png`

## 🖼️ How to Add Your Logos

1. **Prepare your logo files** according to the specifications above
2. **Save them** in `assets/images/logos/` with the exact filenames listed
3. The platform will **automatically display** them (no code changes needed)
4. **Refresh the page** to see the logos appear

### Quick Setup Checklist
- [ ] Add `fhf-logo-main.png` to `assets/images/logos/`
- [ ] Add `fhf-logo-white.png` to `assets/images/logos/`
- [ ] Add `fhf-logo-icon.png` to `assets/images/logos/`
- [ ] Add `fhf-logo-horizontal.png` to `assets/images/logos/` (optional)
- [ ] Test in both light and dark themes
- [ ] Verify responsive display on mobile devices

## 🎯 Branding Consistency

### Typography
- **Primary Font**: Inter (modern, professional, multilingual support)
- **Arabic Font**: Cairo (optimized for Arabic script)
- **Fallback**: System fonts for maximum compatibility

### Design Principles
- **Clean & Modern**: Minimalist design with focus on content
- **Accessible**: High contrast ratios, readable fonts
- **Responsive**: Works on all devices and screen sizes
- **Bilingual**: Equal quality in English and Arabic

### Spacing & Layout
- **Card Radius**: 16-24px (modern, friendly)
- **Padding**: Generous whitespace (40px cards, 24px sections)
- **Shadows**: Subtle depth with soft shadows

## 📱 Platform Integration Points

### Files with Logo Placeholders:
1. `index.html` - English listing form
2. `index-ar.html` - Arabic listing form
3. `market.html` - English marketplace
4. `market-ar.html` - Arabic marketplace
5. `admin.html` - Admin panel

### Automatic Features:
- ✅ Dark mode logo switching
- ✅ Responsive logo sizing
- ✅ RTL layout support
- ✅ Fallback to emoji icons if logos missing
- ✅ Lazy loading for performance

## 🔄 Updating Branding

If FHF updates its brand guidelines:

1. **Colors**: Edit CSS variables in each HTML file (`:root` section)
2. **Fonts**: Update Google Fonts import and font-family declarations
3. **Logos**: Replace files in `assets/images/logos/` (keep same filenames)
4. **No code changes needed** - design system handles the rest!

## 📞 Support

For questions about logo formats or branding requirements:
- Contact FHF Communications Team
- Refer to official FHF Brand Guidelines document
- Technical support: Check platform documentation

---

**Last Updated**: October 2025  
**Platform Version**: 2.0 - Self-Service with FHF Branding

