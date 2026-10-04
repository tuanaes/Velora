-- Velora database v0.1
-- Run this entire file in Supabase SQL Editor.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.characters (
  id text primary key,
  owner_id uuid references public.profiles(id) on delete set null,
  name text not null,
  avatar_url text,
  description text not null default '',
  greeting text not null default '',
  tags text[] not null default '{}',
  category text not null default 'roleplay',
  message_count bigint not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  character_id text not null references public.characters(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, character_id)
);

create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  character_id text not null references public.characters(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id bigint generated always as identity primary key,
  chat_id uuid not null references public.chats(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user','assistant','system')),
  content text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.characters enable row level security;
alter table public.favorites enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;

create policy "profiles are viewable by everyone"
on public.profiles for select using (true);

create policy "users create own profile"
on public.profiles for insert with check (auth.uid() = id);

create policy "users update own profile"
on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "characters are viewable by everyone"
on public.characters for select using (true);

create policy "users create own characters"
on public.characters for insert with check (auth.uid() = owner_id);

create policy "owners update own characters"
on public.characters for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "owners delete own characters"
on public.characters for delete using (auth.uid() = owner_id);

create policy "users view own favorites"
on public.favorites for select using (auth.uid() = user_id);

create policy "users add own favorites"
on public.favorites for insert with check (auth.uid() = user_id);

create policy "users remove own favorites"
on public.favorites for delete using (auth.uid() = user_id);

create policy "users view own chats"
on public.chats for select using (auth.uid() = user_id);

create policy "users create own chats"
on public.chats for insert with check (auth.uid() = user_id);

create policy "users update own chats"
on public.chats for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "users view own messages"
on public.messages for select using (auth.uid() = user_id);

create policy "users send own messages"
on public.messages for insert with check (auth.uid() = user_id);

-- Starter characters for the current prototype.
insert into public.characters (id,name,description,greeting,tags,category,message_count)
values
('луна','Луна','Загадочная собеседница с мягким характером.','Привет. Давай начнём нашу историю.','{"Mystery","Calm","Story"}','roleplay',3769200),
('каэль','Каэль','Странник из мира, где магия стала частью жизни.','Ты готов отправиться со мной?','{"Fantasy","Adventure"}','fantasy',464300),
('ария','Ария','Музыкантка, которая всегда найдёт тему для разговора.','Какую музыку ты слушаешь?','{"Music","Calm","Friendly"}','roleplay',335400),
('нова','Нова','Навигатор космического корабля с острым умом.','Система готова. Куда летим?','{"Sci-Fi","Smart","Story"}','scifi',671100)
on conflict (id) do nothing;

-- Create a profile automatically after signup.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email,'@',1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
