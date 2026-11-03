create table if not exists public.hal_site_visit_counter (
  id boolean primary key default true check (id = true),
  total bigint not null default 0 check (total >= 0),
  updated_at timestamptz not null default now()
);

insert into public.hal_site_visit_counter (id, total)
values (true, 0)
on conflict (id) do nothing;

alter table public.hal_site_visit_counter enable row level security;
revoke all on table public.hal_site_visit_counter from anon, authenticated;

create or replace function public.register_hal_site_visit()
returns bigint
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_total bigint;
begin
  update public.hal_site_visit_counter
     set total = total + 1,
         updated_at = pg_catalog.now()
   where id = true
   returning total into v_total;

  if v_total is null then
    raise exception 'No se pudo actualizar el contador de visitas';
  end if;

  return v_total;
end;
$function$;

revoke all on function public.register_hal_site_visit() from public;
grant execute on function public.register_hal_site_visit() to anon;

create or replace function public.get_hal_site_visit_total()
returns bigint
language sql
security definer
set search_path = ''
as $function$
  select total from public.hal_site_visit_counter where id = true;
$function$;

revoke all on function public.get_hal_site_visit_total() from public;
grant execute on function public.get_hal_site_visit_total() to anon;
