WITH timesheet_hrs AS (
  SELECT
    employee_number,
    CONCAT_WS('-', MONTHNAME(TRY_TO_DATE(entry_date, 'dd-MMM-yyyy')), YEAR(TRY_TO_DATE(entry_date, 'dd-MMM-yyyy'))) AS month_year,
    SUM(total_hours) AS total_timesheet_hrs
  FROM {{ ref('timesheet_bronze') }}
  GROUP BY 
    employee_number,
    CONCAT_WS('-', MONTHNAME(TRY_TO_DATE(entry_date, 'dd-MMM-yyyy')), YEAR(TRY_TO_DATE(entry_date, 'dd-MMM-yyyy')))
)

SELECT 
  tms.employee_number,
  tms.employee_name,
  tms.business_unit,
  tms.department,
  tms.client_code,
  tms.project_id,
  tms.task_id,
  tms.entry_date,
  tms.status,
  tms.task_billing_type,
  tms.total_hours,
  tms.comments,
  r.hourly_rate,
  tmhrs.total_timesheet_hrs,
  
  COALESCE(
    (
      TRY_DIVIDE(
        r.monthly_salary,
        COALESCE(wrkhrs.total_days_worked, 0) 
        + COALESCE(wrkhrs.total_leave, 0)
        + COALESCE(wrkhrs.total_days_absent, 0)
      ) * (COALESCE(wrkhrs.total_days_worked, 0) + COALESCE(wrkhrs.total_leave, 0))
    ) / NULLIF(tmhrs.total_timesheet_hrs, 0),
    0
  ) AS hourly_payable_rate,
(r.monthly_salary/180) as 180hrs_rate
FROM {{ ref('timesheet_bronze') }} AS tms

LEFT JOIN {{ ref('rates_bronze') }} AS r
  ON tms.employee_number = r.employee_number 
 AND TRY_TO_DATE(tms.entry_date, 'dd-MMM-yyyy') >= r.effective_date
 AND (tms.entry_date < r.next_effective_date OR r.next_effective_date IS NULL)

LEFT JOIN timesheet_hrs AS tmhrs 
  ON tms.employee_number = tmhrs.employee_number 
 AND tms.month_year = tmhrs.month_year

LEFT JOIN {{ ref('workhours_bronze') }} AS wrkhrs 
  ON tms.employee_number = wrkhrs.employee_number
 AND tms.month_year = wrkhrs.month_year