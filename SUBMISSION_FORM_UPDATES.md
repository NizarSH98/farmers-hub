# Submission Form Updates

## Changes Implemented

### 1. Field Priority Swap
- **Brand Name** is now the primary identifier and is **Required**.
- **Full Name** is now secondary and **Optional**.
- The HTML structure has been updated to reflect this hierarchy, with Brand Name appearing first (full width).

### 2. Validation Logic
- The form submission logic now enforces the presence of `brand_name`.
- The check for `name` has been removed from the mandatory fields list.

### 3. Auto-Generated IDs
- If a user submits a listing without a Full Name, the system automatically generates a random ID in the format `Farmer-XXXX` (e.g., `Farmer-4829`).
- This ensures database compatibility while allowing the user to remain anonymous if desired.

### Files Modified
- `submit.html` (English version)
- `submit-ar.html` (Arabic version)
