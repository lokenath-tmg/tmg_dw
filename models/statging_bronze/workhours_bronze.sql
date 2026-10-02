SELECT
  TRY_TO_DATE(`month`, 'MMMM,yyyy') AS month_date,
  employee_number,
  employee_name,
  -- Days & Absences (Casted to DOUBLE)
  TRY_CAST(total_days_worked AS DOUBLE) AS total_days_worked,
  TRY_CAST(total_days_absent AS DOUBLE) AS total_days_absent,
  TRY_CAST(total_leave_taken AS DOUBLE) AS total_leave_taken,
  TRY_CAST(total_penalized_leave AS DOUBLE) AS total_penalized_leave,
  TRY_CAST(total_leave AS DOUBLE) AS total_leave,
  TRY_CAST(total_weeklyoffs AS INT) AS total_weeklyoffs,
  TRY_CAST(total_holidays AS INT) AS total_holidays,
  TRY_CAST(week_offs_holidays_worked AS INT) AS week_offs_holidays_worked,
  -- Hours Normalization to "00.00" Format
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_effective_hours, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_effective_hours,
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_shift_duration, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_shift_duration,
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_gross_hours, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_gross_hours,
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_overtime_hours, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_overtime_hours,
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_short_hours_effective, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_short_hours_effective,
CAST(COALESCE(TRY_CAST(REGEXP_REPLACE(total_short_hours_gross, '^([0-9]+)\\.([0-9]{2})\\.[0-9]{2}$', '$1.$2') AS DOUBLE), 0.0) AS DECIMAL(10,2)) AS total_short_hours_gross,
CONCAT_WS('-', MONTHNAME(TRY_TO_DATE(`month`, 'MMMM,yyyy')), YEAR(TRY_TO_DATE(`month`, 'MMMM,yyyy'))) AS month_year,
concat_ws("-", "W", weekofyear(TRY_TO_DATE(`month`, 'MMMM,yyyy')), year(TRY_TO_DATE(`month`, 'MMMM,yyyy'))) AS week_year
FROM
  {{source('workhours_source','working_hours_bronze')}}