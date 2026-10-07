SELECT 
 employee_number,
 employee_name,
 hourly_rate,
 effective_date,
 LEAD (effective_date) OVER (PARTITION BY employee_number ORDER BY effective_date) AS next_effective_date,
 mock_salary,
round((mock_salary/12)) AS mock_monthly_salary
from {{source('rates_source','dim_rates')}}