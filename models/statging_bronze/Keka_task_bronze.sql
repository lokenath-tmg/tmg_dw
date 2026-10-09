
SELECT
  tsk.client_name,
  tsk.project_name,
  COALESCE(
    NULLIF(regexp_extract(tsk.project_name, r'([A-Z]{3}\d{4})', 1), ''),
    tsk.project_code
  ) AS project_id,
  tsk.task,
  tsk.task_id,
  tsk.billing_type,
  tsk.currently_assigned_to AS spoc_doer,
  try_to_date(tsk.start_date, 'dd-MMM-yyyy') AS start_date,
  try_to_date(tsk.end_date, 'dd-MMM-yyyy') AS end_date,
  -- Fix 1 & 2: Use TRY_CAST and match the decimal fallback (0.0)
  COALESCE(TRY_CAST(tsk.estimated_hours AS FLOAT), 0.0) AS estimated_hours
FROM {{source("keka_task_source","task_info_stage")}} as tsk
