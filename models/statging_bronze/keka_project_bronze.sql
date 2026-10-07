SELECT
  project_name,
  COALESCE(
    NULLIF(regexp_extract(project_name, r'([A-Z]{3}\d{4})', 1), ''),
    project_code
  ) AS project_id,
  project_managers,
  client_code,
  try_to_date(start_date, "dd-MMM-yyyy") as start_date,
  try_to_date(end_date, "dd-MMM-yyyy") as end_date,
  task_billable_hours,
  task_non_billable_hours,
  total_hours,
  client_managers,
  est_billing_amount,
  budgeted_time,
  project_income,
  overall_budget
FROM 
   {{source('keka_project_source','dim_project_billing_bronze')}}