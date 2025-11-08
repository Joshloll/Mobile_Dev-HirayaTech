-- Core transaction tables

create table if not exists public.market_transactions (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete cascade,
  type text not null check (type in ('sell','trade','donate')),
  status text not null default 'pending' check (status in ('pending','confirmed','completed','cancelled')),
  seller_id uuid not null references auth.users(id),
  buyer_id uuid references auth.users(id), -- for sell/donate
  trade_partner_listing_id uuid references public.listings(id), -- for trade
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.points_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  points int not null,
  reason text not null,
  related_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  title text not null,
  body text,
  listing_id uuid, -- <-- MODIFICATION: Added column
  created_at timestamptz not null default now(),
  read_at timestamptz
);

-- RLS
alter table public.market_transactions enable row level security;
alter table public.points_ledger enable row level security;
alter table public.notifications enable row level security;

create policy "read own transactions" on public.market_transactions for select using (
  auth.uid() in (seller_id, coalesce(buyer_id, '00000000-0000-0000-0000-000000000000'::uuid))
);
create policy "insert transactions" on public.market_transactions for insert with check ( true );
create policy "update own transactions" on public.market_transactions for update using (
  auth.uid() in (seller_id, coalesce(buyer_id, '00000000-0000-0000-0000-000000000000'::uuid))
);

create policy "read own points" on public.points_ledger for select using ( auth.uid() = user_id );
create policy "insert own points" on public.points_ledger for insert with check ( auth.uid() = user_id );

create policy "read own notifications" on public.notifications for select using ( auth.uid() = user_id );
create policy "insert notifications" on public.notifications for insert with check ( true );
create policy "update own notifications" on public.notifications for update using ( auth.uid() = user_id );

-- RPC functions for flows

-- Request to buy
create or replace function public.request_buy(p_listing_id uuid)
returns uuid as $$
declare
  v_listing record;
  v_tx_id uuid;
begin
  select * into v_listing from public.listings where id = p_listing_id for update;
  if v_listing is null or v_listing.status <> 'active' or v_listing.listing_type <> 'sell' then
    raise exception 'Listing not available';
  end if;

  -- Keep listing active until seller confirmation
  insert into public.market_transactions(listing_id, type, status, seller_id, buyer_id)
  values (p_listing_id, 'sell', 'pending', v_listing.user_id, auth.uid()) returning id into v_tx_id;

  return v_tx_id;
end; $$ language plpgsql security definer;

-- Confirm sale (seller)
create or replace function public.confirm_sale(p_tx_id uuid)
returns void as $$
declare
  v_tx record;
begin
  select * into v_tx from public.market_transactions where id = p_tx_id for update;
  if v_tx is null or v_tx.type <> 'sell' then raise exception 'Invalid transaction'; end if;
  if v_tx.seller_id <> auth.uid() then raise exception 'Only seller can confirm'; end if;

  update public.market_transactions set status = 'completed', updated_at = now() where id = p_tx_id;
  update public.listings set status = 'sold' where id = v_tx.listing_id;

  -- Points: seller 75, buyer 75
  insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.seller_id, 75, 'sell_completed', v_tx.listing_id);
  if v_tx.buyer_id is not null then
    insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.buyer_id, 75, 'buy_completed', v_tx.listing_id);
  end if;
end; $$ language plpgsql security definer;

-- Propose trade
create or replace function public.propose_trade(p_listing_id uuid, p_partner_listing_id uuid)
returns uuid as $$
declare 
  v_listing record; 
  v_partner record; 
  v_tx_id uuid; 
begin
  select * into v_listing from public.listings where id = p_listing_id for update;
  select * into v_partner from public.listings where id = p_partner_listing_id for update;
  if v_listing is null or v_partner is null then raise exception 'Listings not found'; end if;
  if v_listing.listing_type <> 'trade' then raise exception 'Target is not trade'; end if;
  if v_listing.status <> 'active' or v_partner.status <> 'active' then raise exception 'One listing not available'; end if;

  -- Keep both listings active until confirmation
  insert into public.market_transactions(listing_id, type, status, seller_id, buyer_id, trade_partner_listing_id)
  values (p_listing_id, 'trade', 'pending', v_listing.user_id, v_partner.user_id, p_partner_listing_id) returning id into v_tx_id;
  return v_tx_id;
end; $$ language plpgsql security definer;

-- Confirm trade (both users must confirm)
create or replace function public.confirm_trade(p_tx_id uuid)
returns void as $$
declare 
  v_tx record; 
begin
  select * into v_tx from public.market_transactions where id = p_tx_id for update;
  if v_tx is null or v_tx.type <> 'trade' then raise exception 'Invalid transaction'; end if;

  -- For simplicity, a single confirm completes; extend with additional state if needed
  update public.market_transactions set status = 'completed', updated_at = now() where id = p_tx_id;
  update public.listings set status = 'traded' where id in (v_tx.listing_id, v_tx.trade_partner_listing_id);

  -- Points: both 150
  insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.seller_id, 150, 'trade_completed', v_tx.listing_id);
  if v_tx.buyer_id is not null then
    insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.buyer_id, 150, 'trade_completed', v_tx.trade_partner_listing_id);
  end if;
end; $$ language plpgsql security definer;

-- Request donation
create or replace function public.request_donation(p_listing_id uuid)
returns uuid as $$
declare 
  v_listing record; 
  v_tx_id uuid; 
begin
  select * into v_listing from public.listings where id = p_listing_id for update;
  if v_listing is null or v_listing.listing_type <> 'donate' then raise exception 'Not a donation'; end if;
  if v_listing.status <> 'active' then raise exception 'Listing not available'; end if;
  insert into public.market_transactions(listing_id, type, status, seller_id, buyer_id)
  values (p_listing_id, 'donate', 'pending', v_listing.user_id, auth.uid()) returning id into v_tx_id;
  return v_tx_id;
end; $$ language plpgsql security definer;

-- Confirm donation (donor)
create or replace function public.confirm_donation(p_tx_id uuid)
returns void as $$
declare 
  v_tx record; 
begin
  select * into v_tx from public.market_transactions where id = p_tx_id for update;
  if v_tx is null or v_tx.type <> 'donate' then raise exception 'Invalid transaction'; end if;
  if v_tx.seller_id <> auth.uid() then raise exception 'Only donor can confirm'; end if;
  update public.market_transactions set status = 'completed', updated_at = now() where id = p_tx_id;
  update public.listings set status = 'donated' where id = v_tx.listing_id;
  -- Points donor 230, recipient 150 (slightly less)
  insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.seller_id, 230, 'donation_confirmed', v_tx.listing_id);
  if v_tx.buyer_id is not null then
    insert into public.points_ledger(user_id, points, reason, related_id) values (v_tx.buyer_id, 150, 'donation_received', v_tx.listing_id);
  end if;
end; $$ language plpgsql security definer;

-- NEW FUNCTION: Cancel Transaction
create or replace function public.cancel_transaction(p_tx_id uuid)
returns void as $$
declare
  v_tx record;
  v_other_user_id uuid;
  v_notification_title text;
  v_notification_body text;
begin
  -- Get the transaction and lock the row
  select * into v_tx from public.market_transactions where id = p_tx_id for update;

  -- Check if transaction exists and is pending
  if v_tx is null or v_tx.status <> 'pending' then
    raise exception 'Transaction not found or not pending';
  end if;

  -- Check if the current user is either the seller or the buyer
  if auth.uid() <> v_tx.seller_id and auth.uid() <> v_tx.buyer_id then
    raise exception 'You do not have permission to cancel this transaction';
  end if;

  -- Update the transaction status to 'cancelled'
  update public.market_transactions
  set status = 'cancelled', updated_at = now()
  where id = p_tx_id;

  -- Re-activate the listing(s)
  update public.listings set status = 'active' where id = v_tx.listing_id;
  if v_tx.type = 'trade' and v_tx.trade_partner_listing_id is not null then
    update public.listings set status = 'active' where id = v_tx.trade_partner_listing_id;
  end if;

end; $$ language plpgsql security definer;