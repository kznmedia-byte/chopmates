-- Supabase Schema for Chopmates (complete MVP)
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- USERS
create table if not exists public.users (
  id uuid primary key default uuid_generate_v4(),
  phone text unique not null,
  name text not null,
  screen_name text,
  age int not null check (age between 12 and 120),
  address text not null,
  state text,
  city text,
  town text,
  village text,
  avatar_url text,
  verified boolean not null default false,
  role text not null default 'member', -- member|ambassador|admin
  created_at timestamptz not null default now()
);

-- POSTS
create table if not exists public.posts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  type text check (type in ('give','need')) not null,
  title text not null,
  description text,
  quantity text,
  photo_url text,
  state text,
  city text,
  town text,
  village text,
  status text not null default 'active', -- active|matched|fulfilled|expired
  expiry_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- MATCHES
create table if not exists public.matches (
  id uuid primary key default uuid_generate_v4(),
  giver_id uuid references public.users(id) on delete set null,
  receiver_id uuid references public.users(id) on delete set null,
  post_id uuid references public.posts(id) on delete cascade,
  status text not null default 'pending', -- pending|confirmed|done|cancelled
  confirmed_by_giver boolean not null default false,
  confirmed_by_receiver boolean not null default false,
  disputed boolean not null default false,
  created_at timestamptz not null default now()
);

-- EVENTS / FOOD DRIVES
create table if not exists public.events (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  partner text,
  state text,
  city text,
  town text,
  venue text,
  date_start timestamptz,
  date_end timestamptz,
  total_slots int not null default 0,
  claimed_slots int not null default 0,
  status text not null default 'upcoming', -- upcoming|live|ended|cancelled
  created_at timestamptz not null default now()
);

-- EVENT CLAIMS
create table if not exists public.event_claims (
  id uuid primary key default uuid_generate_v4(),
  event_id uuid references public.events(id) on delete cascade,
  user_id uuid references public.users(id) on delete cascade,
  claim_code text unique not null,
  redeemed boolean not null default false,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);

-- NOTIFICATIONS
create table if not exists public.notifications (
  id uuid primary key default uuid_generate_v4(),
  type text not null,                 -- 'post', 'request', 'event', 'match'
  title text not null,
  message text not null,
  target_area text,                   -- e.g., 'Ikeja' or 'Lagos/Ikeja'
  sent boolean not null default false,
  created_at timestamptz not null default now()
);

-- AMBASSADORS
create table if not exists public.ambassadors (
  user_id uuid primary key references public.users(id) on delete cascade,
  coverage_states text[] not null default '{}'::text[],
  bio text,
  hero_points int not null default 0,
  public_recognition boolean not null default true,
  headshot_url text
);

-- BASIC INDEXES
create index if not exists idx_users_phone on public.users(phone);
create index if not exists idx_posts_locale on public.posts(state, city, town, status);
create index if not exists idx_events_locale on public.events(state, status, date_start);

-- RLS
alter table public.users enable row level security;
alter table public.posts enable row level security;
alter table public.matches enable row level security;
alter table public.events enable row level security;
alter table public.event_claims enable row level security;
alter table public.notifications enable row level security;
alter table public.ambassadors enable row level security;

-- Policies (minimal safe defaults)
create policy "users_self_read" on public.users
for select using (auth.uid()::uuid = id);
create policy "users_self_update" on public.users
for update using (auth.uid()::uuid = id);

create policy "posts_public_read" on public.posts
for select using (status in ('active','matched'));

create policy "posts_owner_crud" on public.posts
for all using (auth.uid()::uuid = user_id) with check (auth.uid()::uuid = user_id);

create policy "events_public_read" on public.events
for select using (status in ('upcoming','live'));

create policy "claims_by_owner" on public.event_claims
for select using (auth.uid()::uuid = user_id);
create policy "claims_insert_by_owner" on public.event_claims
for insert with check (auth.uid()::uuid = user_id);

-- Trigger to create notifications on new posts
create or replace function public.notify_new_post()
returns trigger as $$
begin
  if NEW.type = 'give' then
    insert into public.notifications (type, title, message, target_area)
    values ('post', 'New food available nearby!',
            'Someone just shared ' || coalesce(NEW.title,'an item'),
            coalesce(NEW.town, NEW.city));
  elsif NEW.type = 'need' then
    insert into public.notifications (type, title, message, target_area)
    values ('request', 'Someone needs help nearby!',
            'A user needs ' || coalesce(NEW.title,'an item'),
            coalesce(NEW.town, NEW.city));
  end if;
  return NEW;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_notify_post on public.posts;
create trigger trg_notify_post
after insert on public.posts
for each row execute function public.notify_new_post();
