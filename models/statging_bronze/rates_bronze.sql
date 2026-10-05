SELECT 
 employee_number,
 employee_name,
 hourly_rate,
 effective_date,
 LEAD (effective_date) OVER (PARTITION BY employee_number) AS 
 mock_salary,
round((mock_salary/12)) AS monthly_salary
from {{source('rates_source','dim_rates')}}