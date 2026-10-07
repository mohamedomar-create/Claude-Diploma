-- Medical devices catalog: 3 categories, manufacturers, devices, inventory

create type public.risk_class as enum ('I', 'IIa', 'IIb', 'III');
create type public.device_status as enum ('active', 'discontinued', 'pending_approval');

-- updated_at helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Categories
create table public.device_categories (
  id          smallint generated always as identity primary key,
  code        text not null unique,
  name        text not null unique,
  description text,
  created_at  timestamptz not null default now()
);

-- Manufacturers
create table public.manufacturers (
  id         bigint generated always as identity primary key,
  name       text not null unique,
  country    text,
  website    text,
  email      text,
  phone      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Devices
create table public.devices (
  id                  bigint generated always as identity primary key,
  category_id         smallint not null references public.device_categories (id) on delete restrict,
  manufacturer_id     bigint references public.manufacturers (id) on delete set null,
  name                text not null,
  model_number        text,
  sku                 text unique,
  description         text,
  risk_class          public.risk_class not null,
  regulatory_approval text,
  unit_price          numeric(12, 2) check (unit_price >= 0),
  currency            char(3) not null default 'EGP',
  status              public.device_status not null default 'active',
  specifications      jsonb not null default '{}'::jsonb,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index devices_category_id_idx on public.devices (category_id);
create index devices_manufacturer_id_idx on public.devices (manufacturer_id);

-- Inventory (stock per lot / location)
create table public.inventory (
  id          bigint generated always as identity primary key,
  device_id   bigint not null references public.devices (id) on delete cascade,
  lot_number  text,
  location    text not null default 'Main Warehouse',
  quantity    integer not null default 0 check (quantity >= 0),
  expiry_date date,
  received_at date not null default current_date,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index inventory_device_id_idx on public.inventory (device_id);

create trigger manufacturers_set_updated_at before update on public.manufacturers
  for each row execute function public.set_updated_at();
create trigger devices_set_updated_at before update on public.devices
  for each row execute function public.set_updated_at();
create trigger inventory_set_updated_at before update on public.inventory
  for each row execute function public.set_updated_at();

-- Row level security: catalog is publicly readable, writes need a signed-in user;
-- inventory is visible to signed-in users only.
alter table public.device_categories enable row level security;
alter table public.manufacturers     enable row level security;
alter table public.devices           enable row level security;
alter table public.inventory         enable row level security;

create policy "Catalog read" on public.device_categories for select to anon, authenticated using (true);
create policy "Catalog read" on public.manufacturers     for select to anon, authenticated using (true);
create policy "Catalog read" on public.devices           for select to anon, authenticated using (true);

create policy "Authenticated write" on public.manufacturers for all to authenticated using (true) with check (true);
create policy "Authenticated write" on public.devices       for all to authenticated using (true) with check (true);
create policy "Authenticated access" on public.inventory    for all to authenticated using (true) with check (true);

-- Seed the 3 categories
insert into public.device_categories (code, name, description) values
  ('DIAG', 'Diagnostic',  'Devices used to detect or diagnose conditions (imaging, analyzers, tests).'),
  ('THER', 'Therapeutic', 'Devices used to treat patients or deliver therapy (infusion, ventilation, surgery).'),
  ('MON',  'Monitoring',  'Devices that continuously or periodically track patient vital signs.');
