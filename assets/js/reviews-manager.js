// =====================================================
// FARMERS HUB - REVIEWS & RATINGS MANAGER
// =====================================================
// Centralized review and rating management system
// Handles display, submission, and CRUD operations
// =====================================================

class ReviewsManager {
  constructor(supabase, authManager) {
    this.supabase = supabase;
    this.auth = authManager;
    this.cache = new Map(); // Cache rating summaries
    this.CACHE_TTL = 60000; // 1 minute cache
  }

  // =====================================================
  // RATING SUMMARY & DISPLAY
  // =====================================================

  /**
   * Get rating summary for a listing (cached)
   * @param {number} listingId 
   * @returns {Promise<Object>} { averageRating, totalReviews, percentage, starsBreakdown }
   */
  async getRatingSummary(listingId) {
    const cacheKey = `summary_${listingId}`;
    const cached = this.cache.get(cacheKey);
    
    if (cached && (Date.now() - cached.timestamp < this.CACHE_TTL)) {
      return cached.data;
    }

    try {
      const { data, error } = await this.supabase
        .rpc('get_listing_rating_summary', { p_listing_id: listingId });

      if (error) throw error;

      const summary = data && data.length > 0 ? data[0] : {
        listing_id: listingId,
        average_rating: 0,
        total_reviews: 0,
        rating_percentage: 0,
        stars_breakdown: { '5': 0, '4': 0, '3': 0, '2': 0, '1': 0 }
      };

      // Cache the result
      this.cache.set(cacheKey, { data: summary, timestamp: Date.now() });

      return summary;
    } catch (e) {
      console.error('Failed to get rating summary:', e);
      return {
        listing_id: listingId,
        average_rating: 0,
        total_reviews: 0,
        rating_percentage: 0,
        stars_breakdown: { '5': 0, '4': 0, '3': 0, '2': 0, '1': 0 }
      };
    }
  }

  /**
   * Generate star rating HTML
   * @param {number} rating - Average rating (0-5)
   * @param {boolean} interactive - Whether stars are clickable
   * @returns {string} HTML string
   */
  generateStarsHTML(rating, interactive = false) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.3 && rating % 1 < 0.8;
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    let html = '<span class="stars-container">';
    
    // Full stars
    for (let i = 0; i < fullStars; i++) {
      html += interactive 
        ? `<span class="star star-full" data-rating="${i + 1}">★</span>`
        : '<span class="star star-full">★</span>';
    }
    
    // Half star
    if (hasHalfStar) {
      html += '<span class="star star-half">⯪</span>';
    }
    
    // Empty stars
    for (let i = 0; i < emptyStars; i++) {
      const ratingValue = fullStars + (hasHalfStar ? 1 : 0) + i + 1;
      html += interactive
        ? `<span class="star star-empty" data-rating="${ratingValue}">☆</span>`
        : '<span class="star star-empty">☆</span>';
    }
    
    html += '</span>';
    return html;
  }

  /**
   * Generate rating display for product tile
   * @param {Object} summary - Rating summary from getRatingSummary
   * @returns {string} HTML string
   */
  generateRatingDisplay(summary) {
    if (!summary || summary.total_reviews === 0) {
      return `
        <div class="rating-display no-reviews">
          <span class="stars-container">
            <span class="star star-empty">☆</span>
            <span class="star star-empty">☆</span>
            <span class="star star-empty">☆</span>
            <span class="star star-empty">☆</span>
            <span class="star star-empty">☆</span>
          </span>
          <span class="rating-text">No reviews yet</span>
        </div>
      `;
    }

    const stars = this.generateStarsHTML(summary.average_rating, false);
    const percentage = Math.round(summary.rating_percentage);
    
    return `
      <div class="rating-display">
        ${stars}
        <span class="rating-text">
          ${summary.average_rating.toFixed(1)} 
          <span class="rating-percentage">(${percentage}%)</span>
        </span>
      </div>
    `;
  }

  // =====================================================
  // REVIEWS FETCHING & DISPLAY
  // =====================================================

  /**
   * Get reviews for a listing
   * @param {number} listingId 
   * @param {number} limit 
   * @param {number} offset 
   * @param {string} sortBy - 'newest', 'highest', 'lowest'
   * @returns {Promise<Array>} Array of review objects
   */
  async getReviews(listingId, limit = 10, offset = 0, sortBy = 'newest') {
    try {
      const { data, error } = await this.supabase
        .rpc('get_listing_reviews', {
          p_listing_id: listingId,
          p_limit: limit,
          p_offset: offset,
          p_sort_by: sortBy
        });

      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('Failed to get reviews:', e);
      return [];
    }
  }

  /**
   * Check if current user has reviewed a listing
   * @param {number} listingId 
   * @returns {Promise<Object|null>} User's review or null
   */
  async getUserReview(listingId) {
    const user = this.auth.getUser();
    if (!user) return null;

    try {
      const { data, error } = await this.supabase
        .rpc('get_user_review_for_listing', {
          p_user_id: user.id,
          p_listing_id: listingId
        });

      if (error) throw error;
      return data && data.length > 0 ? data[0] : null;
    } catch (e) {
      console.error('Failed to get user review:', e);
      return null;
    }
  }

  /**
   * Generate single review card HTML
   * @param {Object} review 
   * @param {boolean} isOwnReview 
   * @returns {string} HTML string
   */
  generateReviewCard(review, isOwnReview = false) {
    const stars = this.generateStarsHTML(review.rating, false);
    const date = new Date(review.created_at).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
    
    const editedBadge = review.is_edited 
      ? '<span class="edited-badge" title="This review was edited">Edited</span>'
      : '';
    
    const actions = isOwnReview
      ? `
        <div class="review-actions">
          <button class="btn-review-edit" data-review-id="${review.id}" data-listing-id="${review.listing_id || ''}" title="Edit your review">
            ✏️ Edit
          </button>
          <button class="btn-review-delete" data-review-id="${review.id}" title="Delete your review">
            🗑️ Delete
          </button>
        </div>
      `
      : '';
    
    return `
      <div class="review-card" data-review-id="${review.id}">
        <div class="review-header">
          <div class="review-user">
            <span class="review-username">👤 ${this.escapeHtml(review.full_name || review.username)}</span>
            ${editedBadge}
          </div>
          <div class="review-meta">
            ${stars}
            <span class="review-date">${date}</span>
          </div>
        </div>
        ${review.comment ? `
          <div class="review-comment">
            ${this.escapeHtml(review.comment)}
          </div>
        ` : ''}
        ${actions}
      </div>
    `;
  }

  // =====================================================
  // REVIEW SUBMISSION & EDITING
  // =====================================================

  /**
   * Submit a new review
   * @param {number} listingId 
   * @param {number} rating 
   * @param {string} comment 
   * @returns {Promise<Object>} { success, data, error }
   */
  async submitReview(listingId, rating, comment = null) {
    const user = this.auth.getUser();
    
    if (!user) {
      return { success: false, error: 'You must be logged in to submit a review' };
    }

    if (!rating || rating < 1 || rating > 5) {
      return { success: false, error: 'Please provide a rating between 1 and 5 stars' };
    }

    if (comment && comment.length > 500) {
      return { success: false, error: 'Comment is too long (max 500 characters)' };
    }

    try {
      const { data, error } = await this.supabase
        .from('reviews')
        .insert([{
          listing_id: listingId,
          user_id: user.id,
          rating: rating,
          comment: comment ? comment.trim() : null
        }])
        .select()
        .single();

      if (error) {
        if (error.code === '23505') { // Unique constraint violation
          return { success: false, error: 'You have already reviewed this product' };
        }
        throw error;
      }

      // Invalidate cache
      this.cache.delete(`summary_${listingId}`);

      return { success: true, data };
    } catch (e) {
      console.error('Failed to submit review:', e);
      return { success: false, error: e.message || 'Failed to submit review' };
    }
  }

  /**
   * Update an existing review
   * @param {number} reviewId 
   * @param {number} rating 
   * @param {string} comment 
   * @returns {Promise<Object>} { success, data, error }
   */
  async updateReview(reviewId, rating, comment = null) {
    const user = this.auth.getUser();
    
    if (!user) {
      return { success: false, error: 'You must be logged in to update a review' };
    }

    if (!rating || rating < 1 || rating > 5) {
      return { success: false, error: 'Please provide a rating between 1 and 5 stars' };
    }

    if (comment && comment.length > 500) {
      return { success: false, error: 'Comment is too long (max 500 characters)' };
    }

    try {
      // First verify ownership
      const { data: existingReview } = await this.supabase
        .from('reviews')
        .select('user_id, listing_id')
        .eq('id', reviewId)
        .single();

      if (!existingReview || existingReview.user_id !== user.id) {
        return { success: false, error: 'You can only edit your own reviews' };
      }

      const { data, error } = await this.supabase
        .from('reviews')
        .update({
          rating: rating,
          comment: comment ? comment.trim() : null
        })
        .eq('id', reviewId)
        .select()
        .single();

      if (error) throw error;

      // Invalidate cache
      this.cache.delete(`summary_${existingReview.listing_id}`);

      return { success: true, data };
    } catch (e) {
      console.error('Failed to update review:', e);
      return { success: false, error: e.message || 'Failed to update review' };
    }
  }

  /**
   * Delete a review
   * @param {number} reviewId 
   * @returns {Promise<Object>} { success, error }
   */
  async deleteReview(reviewId) {
    const user = this.auth.getUser();
    
    if (!user) {
      return { success: false, error: 'You must be logged in to delete a review' };
    }

    try {
      // First get the listing_id for cache invalidation and verify ownership
      const { data: existingReview } = await this.supabase
        .from('reviews')
        .select('user_id, listing_id')
        .eq('id', reviewId)
        .single();

      if (!existingReview || existingReview.user_id !== user.id) {
        return { success: false, error: 'You can only delete your own reviews' };
      }

      const { error } = await this.supabase
        .from('reviews')
        .delete()
        .eq('id', reviewId);

      if (error) throw error;

      // Invalidate cache
      this.cache.delete(`summary_${existingReview.listing_id}`);

      return { success: true };
    } catch (e) {
      console.error('Failed to delete review:', e);
      return { success: false, error: e.message || 'Failed to delete review' };
    }
  }

  // =====================================================
  // ADMIN FUNCTIONS
  // =====================================================

  /**
   * Get all reviews (admin only)
   * @param {number} limit 
   * @param {number} offset 
   * @returns {Promise<Array>}
   */
  async getAllReviews(limit = 50, offset = 0) {
    try {
      const { data, error } = await this.supabase
        .from('reviews')
        .select(`
          *,
          listing:listings(id, product, product_ar),
          user:verified_users(id, username, full_name)
        `)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);

      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('Failed to get all reviews:', e);
      return [];
    }
  }

  /**
   * Delete any review (admin only - no ownership check)
   * @param {number} reviewId 
   * @param {number} listingId - For cache invalidation
   * @returns {Promise<Object>} { success, error }
   */
  async adminDeleteReview(reviewId, listingId) {
    try {
      const { error } = await this.supabase
        .from('reviews')
        .delete()
        .eq('id', reviewId);

      if (error) throw error;

      // Invalidate cache
      if (listingId) {
        this.cache.delete(`summary_${listingId}`);
      }

      return { success: true };
    } catch (e) {
      console.error('Failed to delete review (admin):', e);
      return { success: false, error: e.message || 'Failed to delete review' };
    }
  }

  // =====================================================
  // UTILITY FUNCTIONS
  // =====================================================

  /**
   * Escape HTML to prevent XSS
   * @param {string} text 
   * @returns {string}
   */
  escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  /**
   * Clear cache for a specific listing
   * @param {number} listingId 
   */
  clearCache(listingId) {
    if (listingId) {
      this.cache.delete(`summary_${listingId}`);
    } else {
      this.cache.clear();
    }
  }

  /**
   * Validate review data
   * @param {number} rating 
   * @param {string} comment 
   * @returns {Object} { valid, errors }
   */
  validateReviewData(rating, comment) {
    const errors = [];

    if (!rating || rating < 1 || rating > 5) {
      errors.push('Rating must be between 1 and 5 stars');
    }

    if (comment) {
      const trimmed = comment.trim();
      if (trimmed.length > 500) {
        errors.push('Comment must be 500 characters or less');
      }
      if (trimmed.length < 3 && trimmed.length > 0) {
        errors.push('Comment must be at least 3 characters');
      }
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }
}

// =====================================================
// Initialize Global Instance
// =====================================================
// This will be initialized after Supabase client is ready
window.ReviewsManager = ReviewsManager;

// Export for module usage if needed
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ReviewsManager;
}

