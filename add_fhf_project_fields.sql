-- Farmer Hub: Add FHF project tracking fields to verified_users table
-- This migration adds fields to track if users were part of FHF projects
-- Run this after the initial create_verified_users_table.sql

-- Add new columns for FHF project tracking
ALTER TABLE verified_users 
ADD COLUMN IF NOT EXISTS was_part_of_fhf_project BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS fhf_project_name TEXT;

-- Create index for project filtering
CREATE INDEX IF NOT EXISTS idx_verified_users_fhf_project ON verified_users(was_part_of_fhf_project);

-- Add comments
COMMENT ON COLUMN verified_users.was_part_of_fhf_project IS 'Indicates if user was previously part of an FHF project';
COMMENT ON COLUMN verified_users.fhf_project_name IS 'Name of the FHF project they were part of (CODRA, ILO, Releaf, Resolve, etc.)';

