SELECT 
 employee_name,
 hourly_rate,
 employee_number,
 effective_date,
 mock_salary,
round((mock_salary/12)) AS monthly_salary
from {{source('rates_source','dim_rates')}}