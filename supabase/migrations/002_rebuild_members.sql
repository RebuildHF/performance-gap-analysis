-- Rebuild member access, and the weekly class programming used for member extras.

-- Private settings (for example the member access code). RLS is on with no policies,
-- so the API cannot read it. Only the service role, the dashboard and the functions below can.
create table if not exists public.app_settings (
  key text primary key,
  value text not null
);
alter table public.app_settings enable row level security;

create table if not exists public.members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('member', 'admin')),
  created_at timestamptz not null default now()
);
alter table public.members enable row level security;
drop policy if exists "members read own row" on public.members;
create policy "members read own row" on public.members for select using (user_id = auth.uid());

create table if not exists public.weekly_programming (
  week_start date primary key,
  content text not null default '',
  updated_by uuid default auth.uid(),
  updated_at timestamptz not null default now()
);
alter table public.weekly_programming enable row level security;

create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.members where user_id = auth.uid()) $$;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.members where user_id = auth.uid() and role = 'admin') $$;

drop policy if exists "members read programming" on public.weekly_programming;
create policy "members read programming" on public.weekly_programming for select using (public.is_member());
drop policy if exists "admins write programming" on public.weekly_programming;
create policy "admins write programming" on public.weekly_programming for all using (public.is_admin()) with check (public.is_admin());

-- Redeem the member access code. Returns true when the code is right.
create or replace function public.redeem_member_code(code text) returns boolean
language plpgsql security definer set search_path = public as
$$
declare good text;
begin
  if auth.uid() is null then return false; end if;
  select value into good from public.app_settings where key = 'member_code';
  if good is null or lower(trim(code)) <> lower(trim(good)) then return false; end if;
  insert into public.members (user_id) values (auth.uid()) on conflict do nothing;
  return true;
end;
$$;
revoke all on function public.redeem_member_code(text) from public, anon;
grant execute on function public.redeem_member_code(text) to authenticated;
grant execute on function public.is_member() to authenticated;
grant execute on function public.is_admin() to authenticated;
