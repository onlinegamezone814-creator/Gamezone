-- Run this ONCE in Supabase > SQL Editor (visitor statistics for the admin panel)
-- Anyone can ADD a visit record from the website; only the admin can READ or delete them.

create table if not exists visits (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  visitor text not null,
  event text not null,
  detail text not null default '',
  source text not null default '',
  device text not null default '',
  tz text not null default '',
  lang text not null default ''
);

create index if not exists visits_created_idx on visits (created_at desc);

alter table visits enable row level security;

drop policy if exists "anyone can log" on visits;
drop policy if exists "admin read" on visits;
drop policy if exists "admin delete" on visits;

create policy "anyone can log" on visits for insert to anon, authenticated
  with check (
    event in ('visit', 'game_click', 'contact_click')
    and length(visitor) <= 40 and length(detail) <= 80 and length(source) <= 80
    and length(device) <= 60 and length(tz) <= 60 and length(lang) <= 20
  );
create policy "admin read"   on visits for select to authenticated using (is_admin());
create policy "admin delete" on visits for delete to authenticated using (is_admin());
