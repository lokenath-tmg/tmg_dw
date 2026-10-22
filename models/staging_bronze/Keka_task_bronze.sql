-- SELECT
--   tsk.client_name,
--   tsk.project_name,
--   COALESCE(
--     NULLIF(regexp_extract(tsk.project_name, r'([A-Z]{3}\d{4})', 1), ''),
--     tsk.project_code
--   ) AS project_id,
--   tsk.task,
--   tsk.task_id,
--   tsk.billing_type,
--   tsk.currently_assigned_to AS spoc_doer,
--   try_to_date(tsk.start_date, 'dd-MMM-yyyy') AS start_date,
--   try_to_date(tsk.end_date, 'dd-MMM-yyyy') AS end_date,
--   tsk.task_stage AS task_status,
--   -- Fix 1 & 2: Use TRY_CAST and match the decimal fallback (0.0)
--   COALESCE(TRY_CAST(tsk.estimated_hours AS FLOAT), 0.0) AS estimated_hours
-- FROM {{source("keka_task_source","task_info_stage")}} as tsk






-----function-----
WITH cte1 AS (
    SELECT DISTINCT employee_number, employee_name 
    FROM {{ source("timesheet_source", "fact_timesheet_bronze") }}
),
cte2 AS (
    SELECT 
        tsk.client_name,
        tsk.project_name,
        COALESCE(
            NULLIF(regexp_extract(tsk.project_name, r'([A-Z]{4}\d{4})', 1), ''),
            tsk.project_code
        ) AS project_id,
        tsk.task,
        tsk.task_id,
        tsk.billing_type,
        spoc,
        try_to_date(tsk.start_date, 'dd-MMM-yyyy') AS start_date,
        try_to_date(tsk.end_date, 'dd-MMM-yyyy') AS end_date,
        tsk.task_stage AS task_status,
        COALESCE(TRY_CAST(tsk.estimated_hours AS FLOAT), 0.0) AS estimated_hours
    FROM {{ source("keka_task_source", "task_info_stage") }} AS tsk
    LATERAL VIEW EXPLODE(SPLIT(currently_assigned_to, ',')) AS spoc
),
cte3 AS (
    SELECT
        client_name,  
        project_name,
        project_id,
        employee_number, 
        employee_name,
        task_id,
        task,
        billing_type,
        start_date,
        end_date,
        task_status,
        estimated_hours
    FROM cte2 
    LEFT JOIN cte1 
      ON LOWER(REPLACE(spoc, ' ', '')) = LOWER(REPLACE(employee_name, ' ', ''))
),
cte4 AS (
    SELECT 
        task_id, 
        COUNT(employee_number) AS cnt 
    FROM cte3
    GROUP BY task_id
)
SELECT 
    cte3.client_name,  
    cte3.project_name,
    cte3.project_id,
    cte3.employee_number, 
    cte3.employee_name,
    cte3.task_id,
    cte3.task,
    cte3.billing_type,
    cte3.start_date,
    cte3.end_date, 
    ROUND(TRY_DIVIDE(cte3.estimated_hours, cte4.cnt), 2) AS estimated_hours,
    cte3.task_status
FROM cte3 
LEFT JOIN cte4 
  ON cte3.task_id = cte4.task_id