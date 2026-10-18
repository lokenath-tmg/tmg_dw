SELECT 
    tsk.project_id,
    tsk.task_id,
    tsk.employee_number,
    tsk.employee_name,
    tsk.start_date,
    tsk.end_date,
    tsk.billing_type,
    tsk.estimated_hours,
    tsk.task_status,
    SUM(tms.total_hours) as Actual_Hours,
    r.monthly_salary,
    (r.monthly_salary / 180) * tsk.estimated_hours AS 180hrs_estimated_budget_mock,

    r.hourly_rate * tsk.estimated_hours AS fixed_rate_estimated_budget,

    r.hourly_rate * SUM(tms.total_hours) AS actual_cost,

    SUM(tms.hourly_payable_rate * tms.total_hours) AS mock_actual_cost,

    SUM(tms.`180hrs_rate` * tms.total_hours) AS mock_180hrs_cost

FROM {{ ref('Keka_task_bronze') }} AS tsk

LEFT JOIN {{ ref('rates_bronze') }} AS r
    ON tsk.employee_number = r.employee_number
    AND tsk.start_date >= r.effective_date
    AND (
        tsk.start_date < r.next_effective_date
        OR r.next_effective_date IS NULL
    )

LEFT JOIN {{ ref('timesheet_gold') }} AS tms 
    ON tsk.task_id = tms.task_id

GROUP BY
    tsk.project_id,
    tsk.task_id,
    tsk.employee_name,
    tsk.employee_number,
    tsk.start_date,
    tsk.end_date,
    tsk.billing_type,
    tsk.estimated_hours,
    r.monthly_salary,
    r.hourly_rate,
    tsk.task_status