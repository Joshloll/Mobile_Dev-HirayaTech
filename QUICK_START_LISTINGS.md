# Quick Start - Listings & Messaging

## ⚡ 3-Minute Setup

### Step 1: Run the SQL (2 minutes)

1. Open: https://app.supabase.com/project/kdbctvolqjmhboikhutx/sql

2. Copy ALL content from `supabase_listings_and_messaging.sql`

3. Paste into SQL Editor

4. Click **"Run"**

5. Wait for "Success" ✅

### Step 2: Run Your App (1 minute)

```bash
flutter run
```

That's it! You're ready to go! 🎉

## 🧪 Test It Right Now

### Test 1: Create a Listing (30 seconds)

1. Open app
2. Click **"List a Device"** (floating button)
3. Choose **SELL**
4. Fill in:
   - Title: Test Device
   - Description: This is a test
   - Price: 1000
5. Add a photo from gallery
6. Click **"Post Listing"**

✅ Your listing should appear in the Market tab!

### Test 2: Message System (30 seconds)

1. Create a second test account (sign up with different email)
2. Log in with second account
3. See the listing you created
4. Click on it
5. Click **"Message Seller"**
6. Send a message: "Hello!"

✅ Message sent!

7. Log back in with first account
8. Click message icon (top right)
9. See the conversation

✅ Messaging works!

## 🎯 What You Get

### Listing Creation
- Three buttons: DONATE / SELL / TRADE
- Simple form with photo upload
- Posted to public feed instantly

### Public Feed
- All users see active listings
- Filter by type (All/Sell/Trade/Donate)
- Grid view with images

### Messaging
- Click "Message Seller" on any listing
- Two-way chat
- See all conversations in one place
- Real-time delivery

## ❓ Issues?

### SQL Error
→ Make sure you copied the **entire** SQL file  
→ Check you're in the right Supabase project

### Can't Create Listing
→ Did you run the SQL?  
→ Check Table Editor shows `listings` table

### Messages Not Working
→ Run the SQL again  
→ Check `conversations` and `messages` tables exist

### Photos Not Uploading
→ Check Storage → `listing_images` bucket exists  
→ Re-run SQL if bucket missing

## 📚 Full Guide

For complete documentation, see:
- **LISTINGS_AND_MESSAGING_GUIDE.md** - Detailed guide
- **supabase_listings_and_messaging.sql** - Database schema

---

**That's all you need! Start listing and messaging! 🚀**

