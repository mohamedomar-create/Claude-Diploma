-- Sample data for the medical devices catalog (illustrative prices, not real quotes)

insert into public.manufacturers (name, country, website) values
  ('Philips Healthcare', 'Netherlands', 'https://www.philips.com/healthcare'),
  ('GE HealthCare',      'United States', 'https://www.gehealthcare.com'),
  ('Medtronic',          'Ireland', 'https://www.medtronic.com'),
  ('Mindray',            'China', 'https://www.mindray.com'),
  ('Omron Healthcare',   'Japan', 'https://www.omronhealthcare.com');

insert into public.devices
  (category_id, manufacturer_id, name, model_number, sku, risk_class, unit_price, specifications)
select c.id, m.id, d.name, d.model_number, d.sku, d.risk_class::public.risk_class, d.unit_price, d.specifications::jsonb
from (values
  -- Diagnostic
  ('DIAG', 'GE HealthCare',      'Portable Ultrasound System',    'Vscan Air',    'DIAG-001', 'IIa', 450000.00, '{"probe": "dual-head", "battery_hours": 1}'),
  ('DIAG', 'Philips Healthcare', '12-Lead ECG Machine',           'PageWriter TC20', 'DIAG-002', 'IIa', 180000.00, '{"leads": 12, "display_in": 8}'),
  ('DIAG', 'Mindray',            'Hematology Analyzer',           'BC-5150',      'DIAG-003', 'I',   320000.00, '{"parameters": 25, "throughput_per_hour": 60}'),
  -- Therapeutic
  ('THER', 'Medtronic',          'Insulin Pump',                  'MiniMed 780G', 'THER-001', 'IIb', 210000.00, '{"reservoir_units": 300}'),
  ('THER', 'Mindray',            'Volumetric Infusion Pump',      'BeneFusion VP5', 'THER-002', 'IIb', 65000.00, '{"flow_rate_ml_h": "0.1-1200"}'),
  ('THER', 'Philips Healthcare', 'ICU Ventilator',                'V60 Plus',     'THER-003', 'IIb', 900000.00, '{"modes": ["CPAP", "S/T", "AVAPS"]}'),
  -- Monitoring
  ('MON',  'Philips Healthcare', 'Patient Monitor',               'IntelliVue MX450', 'MON-001', 'IIb', 250000.00, '{"screen_in": 12, "parameters": ["ECG", "SpO2", "NIBP", "Temp"]}'),
  ('MON',  'Omron Healthcare',   'Digital Blood Pressure Monitor', 'M7 Intelli IT', 'MON-002', 'IIa', 3500.00, '{"memory_readings": 100, "bluetooth": true}'),
  ('MON',  'Mindray',            'Pulse Oximeter',                'PM-60',        'MON-003', 'IIb', 12000.00, '{"spo2_range": "0-100%"}')
) as d(cat, mfr, name, model_number, sku, risk_class, unit_price, specifications)
join public.device_categories c on c.code = d.cat
join public.manufacturers m on m.name = d.mfr;

insert into public.inventory (device_id, lot_number, location, quantity, expiry_date)
select id, 'LOT-' || sku, 'Main Warehouse - Cairo', (5 + id % 20)::int, null
from public.devices;
