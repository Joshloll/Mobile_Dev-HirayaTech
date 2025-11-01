# Quick Start Guide - Supabase Setup

## Before Running the App

### 1. Set Up Your Supabase Database (REQUIRED)

1. Open your browser and go to: https://app.supabase.com/project/kdbctvolqjmhboikhutx/sql

2. Click "New Query" or use the SQL Editor

3. Open the `supabase_setup.sql` file in this project

4. Copy ALL the SQL code from that file

5. Paste it into the Supabase SQL Editor

6. Click **"Run"** or press **Ctrl+Enter** (Cmd+Enter on Mac)

7. You should see a success message. If there are any errors, make sure you copied the entire file.

### 2. Verify Setup

After running the SQL:

1. Go to "Table Editor" in Supabase
2. You should see a `profiles` table
3. Go to "Storage" in Supabase
4. You should see an `avatars` bucket

### 3. Optional: Disable Email Confirmation (for testing)

By default, Supabase requires email confirmation. To test quickly:

1. Go to: https://app.supabase.com/project/kdbctvolqjmhboikhutx/auth/users
2. Click "Configuration" or "Settings"
3. Find "Email Confirmations"
4. **Turn it OFF** for testing
5. Turn it back ON when you deploy to production

## Running the App

```bash
# Make sure dependencies are installed
flutter pub get

# Run on your device/emulator
flutter run
```

## Testing the App

### Test Sign Up
1. Open the app
2. Click "Sign Up" or "Create Account"
3. Enter:
   - Email: test@example.com
   - Password: password123
   - Confirm Password: password123
4. Click "Create Account"
5. You should see a success message

### Test Sign In
1. Click "Log In"
2. Enter the same credentials
3. You should be taken to the main app

### Test Profile
1. Click on the "Profile" tab at the bottom
2. You should see your name (from your email)
3. Click the settings icon → Edit Profile
4. Change your name
5. (Optional) Upload a profile picture
6. Click "Save Changes"
7. Go back to the profile - your changes should be visible

### Test Logout
1. Open the side drawer (hamburger menu)
2. Click "Logout"
3. Confirm logout
4. You should be returned to the login screen

## Troubleshooting

### "Unable to load profile" error
→ Make sure you ran the SQL setup script

### "Failed to create account" error
→ Check that email confirmations are disabled OR check your email for confirmation link

### Can't upload images
→ Verify the avatars bucket exists in Supabase Storage

### App crashes on startup
→ Run `flutter clean` then `flutter pub get`

## What's Next?

Read `SUPABASE_MIGRATION.md` for:
- Detailed explanation of all changes
- Database schema details
- Security information
- Advanced features

## Need Help?

1. Check the Supabase logs: https://app.supabase.com/project/kdbctvolqjmhboikhutx/logs/explorer
2. Check Flutter console for error messages
3. Verify all SQL was executed successfully

---

**That's it!** Your app is now connected to Supabase. 🚀

