-- Run this ONCE in Supabase > SQL Editor (a public folder for the slider pictures)
-- Without it the admin panel still works, but pictures are stored inside the database and the site loads slower.

insert into storage.buckets (id, name, public) values ('slides', 'slides', true) on conflict (id) do nothing;

drop policy if exists "public read slides"   on storage.objects;
drop policy if exists "admin add slides"     on storage.objects;
drop policy if exists "admin change slides"  on storage.objects;
drop policy if exists "admin delete slides"  on storage.objects;

create policy "public read slides"  on storage.objects for select using (bucket_id = 'slides');
create policy "admin add slides"    on storage.objects for insert to authenticated with check (bucket_id = 'slides' and is_admin());
create policy "admin change slides" on storage.objects for update to authenticated using (bucket_id = 'slides' and is_admin()) with check (bucket_id = 'slides' and is_admin());
create policy "admin delete slides" on storage.objects for delete to authenticated using (bucket_id = 'slides' and is_admin());
