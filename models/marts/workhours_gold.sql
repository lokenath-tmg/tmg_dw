select month_date,
employee_number,
employee_name,
total_days_worked,
total_effective_hours,
month_year,
week_year
from {{ ref('workhours_bronze') }} as wrkhrs
join {{ ref('timesheet_bronze') }} as tms ON 
