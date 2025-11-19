# Availability Option Update

## Changes Implemented

### 1. Submission Form (`submit.html` & `submit-ar.html`)
- Added an **"Unavailable (Coming Soon)"** button to the availability selector.
- Updated CSS to style the new button (gray/muted color).
- Updated JavaScript logic:
    - Selecting "Unavailable" clears other month selections.
    - Selecting a month or "All Year" clears "Unavailable".
    - Submits `'unavailable'` as the availability value to the database.
    - Correctly loads the `'unavailable'` state when editing a listing.

### 2. Marketplace Display (`index.html` & `index-ar.html`)
- Updated `isInSeason` function to return `false` for `'unavailable'` (so the card appears dimmed/out-of-season).
- Updated `getAvailabilityBadge` function to display a **"Currently Unavailable"** badge (red) when availability is `'unavailable'`.
- Fixed logic to prevent showing both "Out of Season" and "Currently Unavailable" badges simultaneously.

### 3. Arabic Support
- Applied all changes to Arabic files with appropriate translations:
    - Button: "غير متوفر (قريباً)"
    - Badge: "غير متوفر حالياً"

## How to Test
1.  Go to the **Submit Listing** page.
2.  Select **"Unavailable (Coming Soon)"** in the availability section.
3.  Submit the listing.
4.  Go to the **Marketplace** (index page).
5.  Verify that the new listing appears dimmed and has a red **"Currently Unavailable"** badge.
6.  Try editing the listing to ensure the "Unavailable" button is pre-selected.
