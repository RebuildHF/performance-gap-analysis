-- Applied to the "Performance Gap Analysis" Supabase project (ap-southeast-2).
create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  mode text not null check (mode in ('rx','scaled')),
  label text,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index assessments_user_id_idx on public.assessments(user_id, updated_at desc);
alter table public.assessments enable row level security;
create policy "own assessments select" on public.assessments for select to authenticated using ((select auth.uid()) = user_id);
create policy "own assessments insert" on public.assessments for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own assessments update" on public.assessments for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own assessments delete" on public.assessments for delete to authenticated using ((select auth.uid()) = user_id);

create table public.entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  tier2 boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table public.entitlements enable row level security;
create policy "own entitlement select" on public.entitlements for select to authenticated using ((select auth.uid()) = user_id);
-- No insert/update/delete policies: only the service role or the dashboard can grant Tier 2.

create or replace function public.touch_updated_at() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;
create trigger assessments_touch before update on public.assessments for each row execute function public.touch_updated_at();
