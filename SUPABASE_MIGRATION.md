# Supabase Migration Guide - EcoWaste App

## Overview
Your app has been successfully migrated from Firebase to Supabase! This document provides all the information you need to complete the setup and understand the changes.

## What Was Changed

### 1. Dependencies
- **Removed:** `firebase_core`, `firebase_auth`
- **Added:** `supabase_flutter`

### 2. New Files Created
- `lib/services/supabase_service.dart` - Main Supabase service handling auth and database operations
- `supabase_setup.sql` - SQL script to set up your Supabase database

### 3. Updated Files
- `lib/main.dart` - Now initializes Supabase instead of Firebase
- `lib/auth_wrapper.dart` - Uses Supabase auth state changes
- `lib/services/auth_service.dart` - Wrapper around SupabaseService
- `lib/models/user_model.dart` - Added `UserProfile` class for dynamic user data
- `lib/profile/profile_page.dart` - Fetches user data from Supabase
- `lib/profile/edit_profile_page.dart` - Saves user data and images to Supabase
- `lib/auth/create_account_page.dart` - Creates user profile on registration
- `lib/widgets/app_drawer.dart` - Displays dynamic user data and handles logout
- `lib/screens/home_screen.dart` - Routes to the main marketplace page

## Setup Instructions

### Step 1: Set Up Supabase Database

1. Go to your Supabase Dashboard: https://app.supabase.com/project/kdbctvolqjmhboikhutx
2. Click on "SQL Editor" in the left sidebar
3. Create a new query
4. Copy the entire content of `supabase_setup.sql` and paste it into the editor
5. Click "Run" to execute the SQL

This will create:
- `profiles` table to store user information
- Row Level Security (RLS) policies for data protection
- `avatars` storage bucket for profile images
- Triggers and functions for automatic timestamp updates

### Step 2: Configure Supabase Storage (Optional)

If you want users to be able to upload custom profile pictures:

1. Go to "Storage" in your Supabase Dashboard
2. Verify that the `avatars` bucket was created
3. The bucket is already configured to be public (images are viewable by everyone)

### Step 3: Test the App

Run your app:
```bash
flutter run
```

## Features Implemented

### Authentication
✅ **Sign Up** - Users can create an account with email and password
- A profile is automatically created in the database
- Default name is extracted from email
- Default avatar is set to a placeholder image

✅ **Sign In** - Users can log in with their credentials
- Session is managed automatically by Supabase
- Auth state persists across app restarts

✅ **Sign Out** - Users can log out
- Confirmation dialog prevents accidental logout
- Auth state is cleared

### User Profile
✅ **View Profile** - Displays user information
- Name is fetched from the database
- Avatar image is loaded from Supabase Storage
- Shows "Member since" with the year they joined

✅ **Edit Profile** - Users can update their information
- Change name
- Add/update phone number
- Upload custom profile picture
- Changes are saved to Supabase database
- Profile auto-refreshes after saving

### Profile Picture Upload
✅ **Image Upload** - Users can upload profile pictures
- Images are stored in Supabase Storage
- Old images are replaced when new ones are uploaded
- Images are publicly accessible via CDN URLs

## Database Schema

### Profiles Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, references auth.users |
| email | TEXT | User's email address |
| name | TEXT | User's display name |
| phone_number | TEXT | User's phone number (optional) |
| avatar_url | TEXT | URL to profile picture |
| created_at | TIMESTAMP | Account creation date |
| updated_at | TIMESTAMP | Last profile update |

## Security

### Row Level Security (RLS)
All tables have RLS enabled, which means:
- Users can only view, edit, and delete their own data
- Authentication is required for most operations
- Data is protected at the database level

### Storage Security
- Profile pictures are publicly viewable (needed to display them in the app)
- Only authenticated users can upload images
- Users can only modify their own uploads

## How the App Works

### User Flow

1. **New User:**
   - Opens app → Sees Login Screen
   - Clicks "Sign Up" → Fills out form
   - Creates account → Profile is created in database
   - Automatically shows success message
   - Can now log in

2. **Existing User:**
   - Opens app → Sees Login Screen
   - Enters credentials → Signs in
   - Sees main app with bottom navigation
   - Profile shows their actual name and avatar

3. **Profile Management:**
   - User navigates to Profile tab or opens side drawer
   - Clicks "Edit Profile" (in drawer or settings)
   - Updates name, phone, or profile picture
   - Clicks "Save Changes"
   - Profile updates across the app

### State Management
- `AuthWrapper` listens to Supabase auth state changes
- When user logs in → Shows `HomeScreen` (marketplace)
- When user logs out → Shows `LoginScreen`
- No manual navigation needed!

## Troubleshooting

### "Failed to create account" error
- Check that the SQL script was executed successfully
- Verify that RLS policies are in place
- Make sure the user doesn't already exist

### Profile not showing
- Check that the profiles table has data
- Verify that the user ID matches between auth.users and profiles
- Check console logs for error messages

### Images not uploading
- Verify the avatars bucket exists
- Check that storage policies are set up correctly
- Ensure the user is authenticated

### App crashes on login
- Make sure `flutter pub get` was run
- Check that all imports are correct
- Verify Supabase credentials in `main.dart`

## Important Notes

⚠️ **Your Supabase credentials are in the code**
The anon key is safe to expose in client apps, but keep your service role key secret!

⚠️ **Email Confirmation**
By default, Supabase requires email confirmation. To disable this for testing:
1. Go to Authentication → Settings
2. Turn off "Enable email confirmations"

⚠️ **Password Requirements**
Supabase enforces minimum password length (6 characters by default)

## Next Steps

### Recommended Enhancements
1. Add email verification flow
2. Implement password reset functionality
3. Add social login (Google, Apple, Facebook)
4. Create a more detailed onboarding flow
5. Add profile completion percentage
6. Implement real-time profile updates using Supabase real-time

### Clean Up
You can now safely remove:
- Firebase configuration files (`firebase_options.dart`, `google-services.json`)
- Firebase dependencies from `pubspec.yaml` (if any remain)
- Any Firebase-specific Android/iOS configuration

## Support

If you encounter any issues:
1. Check the Supabase logs in your dashboard
2. Use Flutter DevTools to debug
3. Check the Supabase documentation: https://supabase.com/docs

## Summary

Your app is now fully integrated with Supabase! The backend is connected, user authentication works, and profile management is functional. Users can:
- Create accounts
- Log in and out
- View their profile
- Edit their name, phone, and profile picture
- See their information across the app

The frontend design remains exactly as it was - only the backend has changed! 🎉

