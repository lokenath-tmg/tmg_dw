SELECT
  try_to_date(timestamp, 'dd/mm/yyyy') as `timestamp`,
  project_id,
  payment_terms,
  try_to_date(`date`, 'dd/mm/yyyy') as expected_payment_date,
  concat_ws(" ", currency, amount) as amount,
  address,
  pan_tin,
  gst_number,
  industry,
  founder,
  poc
  from {{source("payment_schedule_source","payment_schedule")}}