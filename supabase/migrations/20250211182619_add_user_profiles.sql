-- New migration to create user_profiles, community posts, and lookbooks with enhanced features

-- Create the user_profiles table
create table public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  bio text,
  avatar_url text, -- Link to Supabase storage bucket
  social_links jsonb, -- Store social links like Instagram, Twitter, etc.
  is_public boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create the community_posts table
create table public.community_posts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.user_profiles(id) on delete cascade,
  content text not null,
  image_url text, -- Optional image link from Supabase storage
  is_public boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create the community_post_likes table
create table public.community_post_likes (
  id uuid primary key default uuid_generate_v4(),
  post_id uuid references public.community_posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create the community_post_comments table
create table public.community_post_comments (
  id uuid primary key default uuid_generate_v4(),
  post_id uuid references public.community_posts(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  comment text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create the lookbooks table
create table public.lookbooks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.user_profiles(id) on delete cascade,
  title text not null,
  description text,
  cover_image_url text, -- Link to Supabase storage bucket
  tags text[], -- Array of tags for categorization
  is_public boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create the lookbook_items table
create table public.lookbook_items (
  id uuid primary key default uuid_generate_v4(),
  lookbook_id uuid references public.lookbooks(id) on delete cascade,
  item_id uuid not null, -- This refers to the wardrobe item or post ID
  item_type text not null, -- 'wardrobe_item' or 'community_post'
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable Row Level Security (RLS) on all tables
alter table public.user_profiles enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_post_likes enable row level security;
alter table public.community_post_comments enable row level security;
alter table public.lookbooks enable row level security;
alter table public.lookbook_items enable row level security;

-- RLS Policies

-- Users can view public profiles
create policy "Public profiles are viewable by everyone"
  on public.user_profiles
  for select
  using (is_public);

-- Users can manage their own profiles
create policy "Users can view their own profile"
  on public.user_profiles
  for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.user_profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can delete their own profile"
  on public.user_profiles
  for delete
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.user_profiles
  for insert
  with check (auth.uid() = id);

-- Users can view public posts
create policy "Public posts are viewable by everyone"
  on public.community_posts
  for select
  using (is_public);

-- Users can manage their own posts
create policy "Users can view their own posts"
  on public.community_posts
  for select
  using (auth.uid() = user_id);

create policy "Users can update their own posts"
  on public.community_posts
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own posts"
  on public.community_posts
  for delete
  using (auth.uid() = user_id);

create policy "Users can insert their own posts"
  on public.community_posts
  for insert
  with check (auth.uid() = user_id);

-- Users can like posts
create policy "Users can like posts"
  on public.community_post_likes
  for insert
  with check (auth.uid() = user_id);

-- Users can remove their likes
create policy "Users can remove their likes"
  on public.community_post_likes
  for delete
  using (auth.uid() = user_id);

-- Users can comment on posts
create policy "Users can comment on posts"
  on public.community_post_comments
  for insert
  with check (auth.uid() = user_id);

-- Users can manage their own comments
create policy "Users can view their own comments"
  on public.community_post_comments
  for select
  using (auth.uid() = user_id);

create policy "Users can update their own comments"
  on public.community_post_comments
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own comments"
  on public.community_post_comments
  for delete
  using (auth.uid() = user_id);

-- Users can view public lookbooks
create policy "Public lookbooks are viewable by everyone"
  on public.lookbooks
  for select
  using (is_public);

-- Users can manage their own lookbooks
create policy "Users can view their own lookbooks"
  on public.lookbooks
  for select
  using (auth.uid() = user_id);

create policy "Users can update their own lookbooks"
  on public.lookbooks
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own lookbooks"
  on public.lookbooks
  for delete
  using (auth.uid() = user_id);

create policy "Users can insert their own lookbooks"
  on public.lookbooks
  for insert
  with check (auth.uid() = user_id);

-- Users can manage their own lookbook items
create policy "Users can view their own lookbook items"
  on public.lookbook_items
  for select
  using (auth.uid() = (select user_id from public.lookbooks where id = lookbook_id));

create policy "Users can update their own lookbook items"
  on public.lookbook_items
  for update
  using (auth.uid() = (select user_id from public.lookbooks where id = lookbook_id))
  with check (auth.uid() = (select user_id from public.lookbooks where id = lookbook_id));

create policy "Users can delete their own lookbook items"
  on public.lookbook_items
  for delete
  using (auth.uid() = (select user_id from public.lookbooks where id = lookbook_id));

create policy "Users can insert their own lookbook items"
  on public.lookbook_items
  for insert
  with check (auth.uid() = (select user_id from public.lookbooks where id = lookbook_id));