-- Run this ONCE in Supabase > SQL Editor (Payment methods, including Zangi and its number).
-- Safe to run even if you already ran the earlier payments script.

create table if not exists payments (
  id bigint generated always as identity primary key,
  name text not null,
  link text not null default '',
  detail text not null default '',
  icon_url text,
  sort int not null default 0,
  active boolean not null default true
);

-- for a table created by the earlier script:
alter table payments add column if not exists detail text not null default '';

alter table payments enable row level security;

drop policy if exists "public read" on payments;
drop policy if exists "admin write" on payments;
create policy "public read" on payments for select using (true);
create policy "admin write" on payments for all to authenticated using (is_admin()) with check (is_admin());

insert into payments (name, sort)
select n, i * 10 from unnest(array['Chime','Cash App','PayPal','Venmo','Zelle','Debit Card','Google Pay','Apple Pay','Zangi']) with ordinality as t(n, i)
where not exists (select 1 from payments);

-- Zangi number
update payments set detail = '3101106919' where name = 'Zangi' and detail = '';

-- Google Pay and Apple Pay for a table that already exists (placed just before Zangi)
insert into payments (name, sort)
select 'Google Pay', 65 where not exists (select 1 from payments where name = 'Google Pay');
insert into payments (name, sort)
select 'Apple Pay', 66 where not exists (select 1 from payments where name = 'Apple Pay');
