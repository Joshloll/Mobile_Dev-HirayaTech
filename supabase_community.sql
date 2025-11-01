-- Supabase Community Feed Schema
-- Run this AFTER running supabase_setup.sql and supabase_listings_and_messaging.sql

-- ============================================
-- COMMUNITY POSTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS community_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view posts
CREATE POLICY "Anyone can view community posts"
  ON community_posts
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
  ON community_posts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own posts
CREATE POLICY "Users can update own posts"
  ON community_posts
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own posts
CREATE POLICY "Users can delete own posts"
  ON community_posts
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at DESC);

-- Trigger for updated_at
CREATE TRIGGER update_community_posts_updated_at
  BEFORE UPDATE ON community_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- POST REACTIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS post_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('like', 'love', 'care', 'wow', 'sad', 'angry')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id) -- One reaction per user per post
);

-- Enable Row Level Security
ALTER TABLE post_reactions ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view reactions
CREATE POLICY "Anyone can view reactions"
  ON post_reactions
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can add reactions
CREATE POLICY "Users can add reactions"
  ON post_reactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reactions
CREATE POLICY "Users can update own reactions"
  ON post_reactions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own reactions
CREATE POLICY "Users can delete own reactions"
  ON post_reactions
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_post_reactions_post_id ON post_reactions(post_id);
CREATE INDEX idx_post_reactions_user_id ON post_reactions(user_id);

-- ============================================
-- POST COMMENTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view comments
CREATE POLICY "Anyone can view comments"
  ON post_comments
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can add comments
CREATE POLICY "Users can add comments"
  ON post_comments
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own comments
CREATE POLICY "Users can update own comments"
  ON post_comments
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own comments
CREATE POLICY "Users can delete own comments"
  ON post_comments
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX idx_post_comments_created_at ON post_comments(created_at DESC);

-- Trigger for updated_at
CREATE TRIGGER update_post_comments_updated_at
  BEFORE UPDATE ON post_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE BUCKET FOR COMMUNITY POST IMAGES
-- ============================================

-- Create storage bucket for post images
INSERT INTO storage.buckets (id, name, public)
VALUES ('community_posts', 'community_posts', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Anyone can view post images
CREATE POLICY "Community post images are publicly accessible"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'community_posts');

-- Policy: Authenticated users can upload images
CREATE POLICY "Users can upload community post images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'community_posts' 
    AND auth.role() = 'authenticated'
  );

-- Policy: Users can update their images
CREATE POLICY "Users can update community post images"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'community_posts' 
    AND auth.role() = 'authenticated'
  );

-- Policy: Users can delete their images
CREATE POLICY "Users can delete community post images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'community_posts' 
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- VIEWS FOR EASIER QUERIES
-- ============================================

-- View: Posts with user info and counts
CREATE OR REPLACE VIEW community_posts_with_details AS
SELECT 
  p.*,
  pr.name as user_name,
  pr.avatar_url as user_avatar_url,
  pr.email as user_email,
  (SELECT COUNT(*) FROM post_reactions WHERE post_id = p.id) as reaction_count,
  (SELECT COUNT(*) FROM post_comments WHERE post_id = p.id) as comment_count,
  (
    SELECT json_agg(json_build_object(
      'reaction_type', reaction_type,
      'count', count
    ))
    FROM (
      SELECT reaction_type, COUNT(*) as count
      FROM post_reactions
      WHERE post_id = p.id
      GROUP BY reaction_type
    ) reaction_summary
  ) as reactions_summary
FROM community_posts p
JOIN profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC;

-- View: Comments with user info
CREATE OR REPLACE VIEW post_comments_with_users AS
SELECT 
  c.*,
  pr.name as user_name,
  pr.avatar_url as user_avatar_url
FROM post_comments c
JOIN profiles pr ON c.user_id = pr.id
ORDER BY c.created_at ASC;

-- View: User transactions (listings they've created)
CREATE OR REPLACE VIEW user_transactions AS
SELECT 
  l.user_id,
  l.id as listing_id,
  l.listing_type,
  l.title,
  l.price,
  l.status,
  l.created_at,
  CASE 
    WHEN l.image_urls IS NOT NULL AND array_length(l.image_urls, 1) > 0 
    THEN l.image_urls[1]
    ELSE NULL
  END as first_image_url
FROM listings l
ORDER BY l.created_at DESC;

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to get reaction count for a post
CREATE OR REPLACE FUNCTION get_post_reaction_count(post_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM post_reactions WHERE post_id = post_uuid);
END;
$$ LANGUAGE plpgsql;

-- Function to get comment count for a post
CREATE OR REPLACE FUNCTION get_post_comment_count(post_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM post_comments WHERE post_id = post_uuid);
END;
$$ LANGUAGE plpgsql;

-- Function to check if user has reacted to a post
CREATE OR REPLACE FUNCTION user_has_reacted(post_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS(
    SELECT 1 FROM post_reactions 
    WHERE post_id = post_uuid AND user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql;

-- Function to get user's reaction type on a post
CREATE OR REPLACE FUNCTION get_user_reaction(post_uuid UUID, user_uuid UUID)
RETURNS TEXT AS $$
BEGIN
  RETURN (
    SELECT reaction_type FROM post_reactions 
    WHERE post_id = post_uuid AND user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql;

