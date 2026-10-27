-- Run this ONCE in Supabase > SQL Editor.
-- Counts every visit since the very beginning (lifetime), with no row limit. Only the admin can use it.

create or replace function visit_stats(p_since timestamptz default null)
returns json
language plpgsql stable security definer set search_path = public as
$$
declare res json;
begin
  if not is_admin() then raise exception 'not allowed'; end if;
  select json_build_object(
    'visits',       (select count(*) from visits where event = 'visit'         and (p_since is null or created_at >= p_since)),
    'unique',       (select count(distinct visitor) from visits where event = 'visit' and (p_since is null or created_at >= p_since)),
    'game_taps',    (select count(*) from visits where event = 'game_click'    and (p_since is null or created_at >= p_since)),
    'contact_taps', (select count(*) from visits where event = 'contact_click' and (p_since is null or created_at >= p_since)),
    'first',        (select min(created_at) from visits),
    'games',    (select coalesce(json_agg(t), '[]'::json) from (select detail as label, count(*) as n from visits where event = 'game_click'    and detail <> '' and (p_since is null or created_at >= p_since) group by detail order by n desc limit 8) t),
    'contacts', (select coalesce(json_agg(t), '[]'::json) from (select detail as label, count(*) as n from visits where event = 'contact_click' and detail <> '' and (p_since is null or created_at >= p_since) group by detail order by n desc limit 8) t),
    'sources',  (select coalesce(json_agg(t), '[]'::json) from (select source as label, count(*) as n from visits where event = 'visit' and source <> '' and (p_since is null or created_at >= p_since) group by source order by n desc limit 8) t),
    'devices',  (select coalesce(json_agg(t), '[]'::json) from (select device as label, count(*) as n from visits where event = 'visit' and device <> '' and (p_since is null or created_at >= p_since) group by device order by n desc limit 8) t),
    'zones',    (select coalesce(json_agg(t), '[]'::json) from (select tz as label, count(*) as n from visits where event = 'visit' and tz <> '' and (p_since is null or created_at >= p_since) group by tz order by n desc limit 8) t)
  ) into res;
  return res;
end;
$$;

revoke all on function visit_stats(timestamptz) from public, anon;
grant execute on function visit_stats(timestamptz) to authenticated;
