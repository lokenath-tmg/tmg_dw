--timesheet model
SELECT 
    tms.employee_number,
    tms.employee_name,
    tms.business_unit,
    tms.department,
    tms.client_name,
    tms.client_code,
    tms.project_name,
    COALESCE(
        NULLIF(REGEXP_EXTRACT(tms.project_name, r'([A-Z]{3}\d{4})', 1), ''), 
        tms.project_code
    ) AS project_id,
    tms.task,
    tms.task_id,
    TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy') AS `entry_date`, -- Fixed: Changed single quotes to backticks
    tms.status,
    tms.task_billing_type,
    tms.total_hours,
    tms.comments,
    CONCAT_WS('-', MONTHNAME(TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy')), YEAR(TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy'))) AS month_year,
    CONCAT_WS("-", "W", weekofyear(TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy')), year(TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy'))) as week_year
FROM {{ source('timesheet_source', 'fact_timesheet_bronze') }} AS tms