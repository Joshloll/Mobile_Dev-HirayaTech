-- Enable RLS on core tables
alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.community_posts enable row level security;
alter table public.post_comments enable row level security;
alter table public.post_reactions enable row level security;
alter table public.messages enable row level security;
alter table public.conversations enable row level security;

-- Profiles: users can read all public profiles, update only their own
create policy "read profiles" on public.profiles for select using ( true );
create policy "insert own profile" on public.profiles for insert with check ( auth.uid() = id );
create policy "update own profile" on public.profiles for update using ( auth.uid() = id );

-- Listings: anyone can read active listings, owners can manage their own
create policy "read active listings" on public.listings for select using ( status = 'active' );
create policy "insert own listings" on public.listings for insert with check ( auth.uid() = user_id );
create policy "update own listings" on public.listings for update using ( auth.uid() = user_id );
create policy "delete own listings" on public.listings for delete using ( auth.uid() = user_id );

-- Community posts: readable by all, authors manage their own
create policy "read posts" on public.community_posts for select using ( true );
create policy "insert own posts" on public.community_posts for insert with check ( auth.uid() = user_id );
create policy "update own posts" on public.community_posts for update using ( auth.uid() = user_id );
create policy "delete own posts" on public.community_posts for delete using ( auth.uid() = user_id );

-- Post comments: readable by all, authors manage their own
create policy "read comments" on public.post_comments for select using ( true );
create policy "insert own comments" on public.post_comments for insert with check ( auth.uid() = user_id );
create policy "update own comments" on public.post_comments for update using ( auth.uid() = user_id );
create policy "delete own comments" on public.post_comments for delete using ( auth.uid() = user_id );

-- Post reactions: readable by all, users can upsert/delete their own
create policy "read reactions" on public.post_reactions for select using ( true );
create policy "insert own reactions" on public.post_reactions for insert with check ( auth.uid() = user_id );
create policy "update own reactions" on public.post_reactions for update using ( auth.uid() = user_id );
create policy "delete own reactions" on public.post_reactions for delete using ( auth.uid() = user_id );

-- Conversations: participants can read; creation via RPC or insert with check
create policy "read participant conversations" on public.conversations for select using (
  auth.uid() = user1_id or auth.uid() = user2_id
);
create policy "insert participant conversations" on public.conversations for insert with check (
  auth.uid() = user1_id or auth.uid() = user2_id
);
create policy "update participant conversations" on public.conversations for update using (
  auth.uid() = user1_id or auth.uid() = user2_id
);

-- Messages: participants of conversation can read/insert their own
create policy "read conversation messages" on public.messages for select using (
  exists(
    select 1 from public.conversations c
    where c.id = messages.conversation_id
      and (auth.uid() = c.user1_id or auth.uid() = c.user2_id)
  )
);
create policy "insert own messages" on public.messages for insert with check (
  auth.uid() = sender_id and exists(
    select 1 from public.conversations c
    where c.id = messages.conversation_id
      and (auth.uid() = c.user1_id or auth.uid() = c.user2_id)
  )
);

-- Storage buckets: create policies in SQL for 'avatars', 'listing_images', 'community_posts'
-- Note: Requires using storage policies via pg functions (supabase v2 storage policies)
-- Example policies (run in SQL editor):
--
--  create policy "Public read avatars" on storage.objects for select
--    using ( bucket_id = 'avatars' );
--  create policy "Users upload their avatars" on storage.objects for insert
--    with check ( bucket_id = 'avatars' and owner = auth.uid() );
--
--  create policy "Public read listings images" on storage.objects for select
--    using ( bucket_id = 'listing_images' );
--  create policy "Users upload listing images" on storage.objects for insert
--    with check ( bucket_id = 'listing_images' and owner = auth.uid() );
--
--  create policy "Public read community images" on storage.objects for select
--    using ( bucket_id = 'community_posts' );
--  create policy "Users upload community images" on storage.objects for insert
--    with check ( bucket_id = 'community_posts' and owner = auth.uid() );


