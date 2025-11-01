-- Supabase Database Schema for Listings and Messaging
-- Run this SQL in your Supabase SQL Editor after running supabase_setup.sql

-- ============================================
-- LISTINGS/DEVICES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_type TEXT NOT NULL CHECK (listing_type IN ('sell', 'trade', 'donate')),
  
  -- Device Information
  device_type TEXT,
  brand TEXT,
  model TEXT,
  storage_capacity TEXT,
  color TEXT,
  
  -- Listing Details
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2),
  trade_details TEXT,
  
  -- Images
  image_urls TEXT[], -- Array of image URLs
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'pending', 'sold', 'traded', 'donated', 'cancelled')),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view active listings
CREATE POLICY "Anyone can view active listings"
  ON listings
  FOR SELECT
  USING (status = 'active' OR auth.uid() = user_id);

-- Policy: Users can insert their own listings
CREATE POLICY "Users can insert own listings"
  ON listings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own listings
CREATE POLICY "Users can update own listings"
  ON listings
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own listings
CREATE POLICY "Users can delete own listings"
  ON listings
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger to update updated_at timestamp
CREATE TRIGGER update_listings_updated_at
  BEFORE UPDATE ON listings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create index for faster queries
CREATE INDEX idx_listings_user_id ON listings(user_id);
CREATE INDEX idx_listings_type ON listings(listing_type);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_created_at ON listings(created_at DESC);

-- ============================================
-- CONVERSATIONS TABLE (for chat threads)
-- ============================================

CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure unique conversation between two users
  CONSTRAINT unique_conversation UNIQUE (user1_id, user2_id),
  -- Ensure user1_id < user2_id to avoid duplicates
  CONSTRAINT ordered_users CHECK (user1_id < user2_id)
);

-- Enable Row Level Security
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view conversations they're part of
CREATE POLICY "Users can view own conversations"
  ON conversations
  FOR SELECT
  USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Policy: Users can create conversations
CREATE POLICY "Users can create conversations"
  ON conversations
  FOR INSERT
  WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Policy: Users can update conversations they're part of
CREATE POLICY "Users can update own conversations"
  ON conversations
  FOR UPDATE
  USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Create indexes
CREATE INDEX idx_conversations_user1 ON conversations(user1_id);
CREATE INDEX idx_conversations_user2 ON conversations(user2_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- ============================================
-- MESSAGES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view messages in their conversations
CREATE POLICY "Users can view messages in own conversations"
  ON messages
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
  );

-- Policy: Users can insert messages in their conversations
CREATE POLICY "Users can send messages in own conversations"
  ON messages
  FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
  );

-- Policy: Users can update their own messages (e.g., mark as read)
CREATE POLICY "Users can update messages in own conversations"
  ON messages
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
  );

-- Create indexes
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to get or create a conversation between two users
CREATE OR REPLACE FUNCTION get_or_create_conversation(
  p_user1_id UUID,
  p_user2_id UUID,
  p_listing_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_conversation_id UUID;
  v_min_user_id UUID;
  v_max_user_id UUID;
BEGIN
  -- Ensure user1_id < user2_id
  IF p_user1_id < p_user2_id THEN
    v_min_user_id := p_user1_id;
    v_max_user_id := p_user2_id;
  ELSE
    v_min_user_id := p_user2_id;
    v_max_user_id := p_user1_id;
  END IF;

  -- Try to find existing conversation
  SELECT id INTO v_conversation_id
  FROM conversations
  WHERE user1_id = v_min_user_id AND user2_id = v_max_user_id;

  -- If not found, create new conversation
  IF v_conversation_id IS NULL THEN
    INSERT INTO conversations (user1_id, user2_id, listing_id)
    VALUES (v_min_user_id, v_max_user_id, p_listing_id)
    RETURNING id INTO v_conversation_id;
  END IF;

  RETURN v_conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update last_message_at when a new message is sent
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update conversation's last_message_at
CREATE TRIGGER update_conversation_on_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_conversation_last_message();

-- ============================================
-- STORAGE BUCKET FOR LISTING IMAGES
-- ============================================

-- Create storage bucket for listing images
INSERT INTO storage.buckets (id, name, public)
VALUES ('listing_images', 'listing_images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Anyone can view listing images
CREATE POLICY "Listing images are publicly accessible"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'listing_images');

-- Policy: Authenticated users can upload listing images
CREATE POLICY "Users can upload listing images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'listing_images' 
    AND auth.role() = 'authenticated'
  );

-- Policy: Users can update their own listing images
CREATE POLICY "Users can update their listing images"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'listing_images' 
    AND auth.role() = 'authenticated'
  );

-- Policy: Users can delete their own listing images
CREATE POLICY "Users can delete their listing images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'listing_images' 
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- VIEWS FOR EASIER QUERIES
-- ============================================

-- View to get listings with user information
CREATE OR REPLACE VIEW listings_with_users AS
SELECT 
  l.*,
  p.name as user_name,
  p.avatar_url as user_avatar_url,
  p.email as user_email
FROM listings l
JOIN profiles p ON l.user_id = p.id;

-- View to get conversations with user information and last message
CREATE OR REPLACE VIEW conversations_with_details AS
SELECT 
  c.*,
  p1.name as user1_name,
  p1.avatar_url as user1_avatar_url,
  p2.name as user2_name,
  p2.avatar_url as user2_avatar_url,
  (
    SELECT content
    FROM messages m
    WHERE m.conversation_id = c.id
    ORDER BY m.created_at DESC
    LIMIT 1
  ) as last_message_content
FROM conversations c
JOIN profiles p1 ON c.user1_id = p1.id
JOIN profiles p2 ON c.user2_id = p2.id;

