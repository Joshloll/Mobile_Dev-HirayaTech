-- View: listings_with_users (join listings with profile basics and first image)
create or replace view public.listings_with_users as
select 
  l.*, 
  p.name as user_name, 
  p.avatar_url as user_avatar_url,
  l.image_urls[1] as first_image_url -- text[] arrays are 1-based
from public.listings l
left join public.profiles p on p.id = l.user_id;


create or replace view public.community_posts_with_details as
select 
  cp.*, 
  p.name as user_name, 
  p.avatar_url as user_avatar_url,
  coalesce(r.reaction_count, 0) as reaction_count,
  coalesce(c.comment_count, 0) as comment_count
from public.community_posts cp
left join public.profiles p on p.id = cp.user_id
left join (
  select post_id, count(*)::int as reaction_count
  from public.post_reactions
  group by post_id
) r on r.post_id = cp.id
left join (
  select post_id, count(*)::int as comment_count
  from public.post_comments
  group by post_id
) c on c.post_id = cp.id;

-- View: post_comments_with_users (join comments with commenter profile)
create or replace view public.post_comments_with_users as
select 
  pc.*, 
  p.name as user_name, 
  p.avatar_url as user_avatar_url
from public.post_comments pc
left join public.profiles p on p.id = pc.user_id;

-- View: conversations_with_details (basic conversation summary)
drop view if exists public.conversations_with_details;
create view public.conversations_with_details as
with last_msg as (
  select distinct on (conversation_id)
    conversation_id,
    id as message_id,
    content as last_message_content,
    created_at as last_message_at
  from public.messages
  order by conversation_id, created_at desc
)
select 
  c.id,
  c.user1_id,
  u1.name as user1_name,
  u1.avatar_url as user1_avatar_url,
  c.user2_id,
  u2.name as user2_name,
  u2.avatar_url as user2_avatar_url,
  coalesce(lm.last_message_at, c.created_at) as last_message_at,
  lm.last_message_content,
  c.created_at
from public.conversations c
left join public.profiles u1 on u1.id = c.user1_id
left join public.profiles u2 on u2.id = c.user2_id
left join last_msg lm on lm.conversation_id = c.id;

-- User points from listings (trade=150, sell=75, donate=230)
create or replace view public.user_points as
select 
  l.user_id,
  sum(
    case 
      when l.listing_type = 'trade' then 150
      when l.listing_type = 'sell' then 75
      when l.listing_type = 'donate' then 230
      else 0
    end
  )::int as points,
  count(*)::int as devices
from public.listings l
where coalesce(l.status, 'active') in ('sold','traded','donated','completed','active')
group by l.user_id;

create or replace view public.user_points_with_profiles as
select up.*, p.name as user_name, p.avatar_url as user_avatar_url
from public.user_points up
left join public.profiles p on p.id = up.user_id;


