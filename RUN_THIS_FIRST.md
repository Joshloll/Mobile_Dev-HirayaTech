# ⚠️ CRITICAL - RUN THIS FIRST!

## 🚨 Your App Won't Work Without This Setup!

The error you're seeing means **you haven't set up the database tables yet.**

## 📝 Quick Fix (10 minutes)

### Step 1: Run First SQL Script - User Profiles

1. **Open:** https://app.supabase.com/project/kdbctvolqjmhboikhutx/sql

2. **Open file:** `supabase_setup.sql` in your project

3. **Copy ALL** the content

4. **Paste** into Supabase SQL Editor

5. **Click "Run"**

6. **Wait** for SUCCESS ✅

### Step 2: Run Second SQL Script - Listings & Messaging

1. **Stay in** the same SQL Editor

2. **Open file:** `supabase_listings_and_messaging.sql`

3. **Copy ALL** the content

4. **Paste** into SQL Editor

5. **Click "Run"**

6. **Wait** for SUCCESS ✅

### Step 3: Run Third SQL Script - Community Features

1. **Stay in** the same SQL Editor

2. **Open file:** `supabase_community.sql`

3. **Copy ALL** the content

4. **Paste** into SQL Editor

5. **Click "Run"**

6. **Wait** for SUCCESS ✅

## ✅ Verify Everything is Set Up

### Check Tables

1. Go to: https://app.supabase.com/project/kdbctvolqjmhboikhutx/editor

2. You should see these tables:
   - ✅ **profiles** (user information)
   - ✅ **listings** (device posts)
   - ✅ **conversations** (chat threads)
   - ✅ **messages** (chat messages)
   - ✅ **community_posts** (community posts)
   - ✅ **post_reactions** (likes)
   - ✅ **post_comments** (comments)

### Check Storage

1. Go to: https://app.supabase.com/project/kdbctvolqjmhboikhutx/storage/buckets

2. You should see these buckets:
   - ✅ **avatars** (profile pictures)
   - ✅ **listing_images** (device photos)
   - ✅ **community_posts** (post images)

## 🎯 Now Try Your App Again

After running all three SQL scripts:

```bash
flutter run
```

**Everything will work:**
- ✅ Create account and login
- ✅ Edit profile
- ✅ List devices (DONATE/SELL/TRADE)
- ✅ Post to community
- ✅ Like and comment on posts
- ✅ Message other users
- ✅ View transaction history

## 📚 What Each Script Does

### Script 1: `supabase_setup.sql`
- Creates **profiles** table
- Sets up profile picture storage
- Enables user authentication

### Script 2: `supabase_listings_and_messaging.sql`
- Creates **listings** table for devices
- Creates **conversations** and **messages** tables
- Sets up listing image storage
- Enables marketplace features

### Script 3: `supabase_community.sql`
- Creates **community_posts** table
- Creates **post_reactions** table (likes)
- Creates **post_comments** table
- Sets up post image storage
- Enables community features

## ❗ Common Mistakes

### Mistake 1: Skipping a Script
❌ Running only one or two scripts

✅ Run ALL THREE scripts in order

### Mistake 2: Not Copying Everything
❌ Copying part of the SQL file

✅ Copy the ENTIRE file (all lines)

### Mistake 3: Wrong Project
❌ Running in a different Supabase project

✅ Use this URL: https://app.supabase.com/project/kdbctvolqjmhboikhutx/sql

### Mistake 4: Not Waiting for Success
❌ Moving on before SQL finishes

✅ Wait for the green "Success" message

## 🆘 Still Having Issues?

### Error: "Table already exists"
→ That's OK! It means you already ran that script
→ Continue with the next script

### Error: "Permission denied"
→ Check you're logged into the correct Supabase account
→ Make sure you're the project owner

### Error: "Syntax error"
→ You might have missed part of the SQL
→ Copy the ENTIRE file again and re-run

### Tables Don't Show Up
→ Refresh the Table Editor page
→ Wait a few seconds for database to sync

### Storage Buckets Missing
→ Re-run the SQL script
→ Check the SQL output for errors

## 📖 Documentation

After setup, read these guides:

1. **START_HERE.md** - Original features
2. **QUICK_START_LISTINGS.md** - Listing features
3. **COMMUNITY_FEATURES_GUIDE.md** - Community features
4. **FEATURES_SUMMARY.md** - Complete overview

## 🎊 Summary

**Three SQL scripts to run:**
1. ✅ supabase_setup.sql
2. ✅ supabase_listings_and_messaging.sql
3. ✅ supabase_community.sql

**In this order. In the Supabase SQL Editor. Copy everything. Click Run.**

**That's it!** Your app will work perfectly after this! 🚀

---

**Don't skip this - it's the only setup required!**
