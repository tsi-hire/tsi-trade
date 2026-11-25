-- TSI Trade project: per-user starting capital and simulation settings
-- Run this in Supabase SQL Editor for project sxdyrmvfizjmpmubjmwo.

create table if not exists public.account_config (
  user_id uuid primary key references auth.users(id) on delete cascade,
  initial_capital numeric(14,2) not null default 0 check (initial_capital >= 0),
  daily_target_percent numeric(5,2) not null default 15 check (daily_target_percent > 0 and daily_target_percent <= 100),
  bot_enabled boolean not null default false,
  symbol text not null default 'OANDA:XAUUSD',
  updated_at timestamptz not null default now()
);

alter table public.account_config enable row level security;

drop policy if exists "Read own account config" on public.account_config;
create policy "Read own account config"
on public.account_config for select
to authenticated
using (auth.uid() = user_id);

-- Allow the website to create only a zero-capital default row for the signed-in user.
-- The owner/admin sets initial_capital later from Supabase Table Editor.
drop policy if exists "Create own zero capital config" on public.account_config;
create policy "Create own zero capital config"
on public.account_config for insert
to authenticated
with check (
  auth.uid() = user_id
  and initial_capital = 0
  and daily_target_percent = 15
  and bot_enabled = false
  and symbol = 'OANDA:XAUUSD'
);

-- Intentionally no client UPDATE/DELETE policy.
-- To set a user's capital, open Table Editor > account_config and edit initial_capital.
