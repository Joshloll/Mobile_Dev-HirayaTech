-- Storage bucket policies (execute in SQL editor). Requires buckets exist: avatars, listing_images, community_posts

-- Allow public read for avatars, listing images, community posts
create policy "public read avatars" on storage.objects for select using ( bucket_id = 'avatars' );
create policy "public read listing images" on storage.objects for select using ( bucket_id = 'listing_images' );
create policy "public read community posts images" on storage.objects for select using ( bucket_id = 'community_posts' );

-- Allow authenticated users to upload/manage their own files
create policy "users upload avatars" on storage.objects for insert with check (
  bucket_id = 'avatars' and owner = auth.uid()
);
create policy "users manage their avatars" on storage.objects for update using (
  bucket_id = 'avatars' and owner = auth.uid()
);

create policy "users upload listing images" on storage.objects for insert with check (
  bucket_id = 'listing_images' and owner = auth.uid()
);
create policy "users manage listing images" on storage.objects for update using (
  bucket_id = 'listing_images' and owner = auth.uid()
);

create policy "users upload community images" on storage.objects for insert with check (
  bucket_id = 'community_posts' and owner = auth.uid()
);
create policy "users manage community images" on storage.objects for update using (
  bucket_id = 'community_posts' and owner = auth.uid()
);


