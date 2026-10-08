WITH timesheet AS (

    SELECT
        project_id,

        SUM(
            CASE
                WHEN task_billing_type = 'Billable'
                THEN total_hours
                ELSE 0
            END
        ) AS Billable_Hours,

        SUM(
            CASE
                WHEN task_billing_type = 'NonBillable'
                THEN total_hours
                ELSE 0
            END
        ) AS Non_Billable_Hours,

        SUM(hourly_payable_rate * total_hours) AS workhours_adjusted_cost,

        SUM(hourly_rate * total_hours) AS fixed_assigned_rate_cost,

        SUM(180hrs_rate * total_hours) AS 180hrs_rate_cost

    FROM {{ ref('timesheet_gold') }}

    GROUP BY project_id
),

tasks AS (

    SELECT
        project_id,

        SUM(estimated_hours) AS estimated_hours,

        SUM(180hrs_estimated_budget_mock) 
            AS 180hrs_estimated_budget_mock,

        SUM(fixed_rate_estimated_budget) 
            AS fixed_rate_estimated_budget

    FROM {{ ref('task_gold') }}

    GROUP BY project_id
),

internal_tasks AS (

    SELECT
        project_id,

        COUNT(
            CASE
                WHEN actual_status = 'Completed with delay'
                THEN task_id
            END
        ) AS Delayed_task,

        COUNT(
            CASE
                WHEN actual_status = 'Completed on time'
                THEN task_id
            END
        ) AS Ontime_task,

        COUNT(
            CASE
                WHEN actual_status = 'Upcoming'
                THEN task_id
            END
        ) AS Pending,

        COUNT(
            CASE
                WHEN actual_status = 'Overdue'
                THEN task_id
            END
        ) AS Overdue

    FROM {{ ref('internal_task_bronze') }}

    GROUP BY project_id
)

SELECT
    o2d.onboarded,
    o2d.project_id,
    o2d.client_name,
    kcl.billing_name,
    o2d.group,
    kcl.client_code,
    o2d.project_name,
    o2d.category,
    o2d.vendor,
    o2d.spoc_doer,
    o2d.project_managers,
    o2d.project_type,
    o2d.first_tranch,
    o2d.planned_completion,
    o2d.actual_completion,
    o2d.status,
    o2d.unit,
    o2d.first_tranch_date,
    o2d.source,
    o2d.practice,
    o2d.crm_update,
    o2d.pc_update,
    o2d.total_revenue as project_value,
    o2d.vendor_cost,

    tasks.estimated_hours,

    kpj.budgeted_time,

    timesheet.Billable_Hours,
    timesheet.Non_Billable_Hours,

    tasks.180hrs_estimated_budget_mock,
    tasks.fixed_rate_estimated_budget,

    timesheet.workhours_adjusted_cost,
    timesheet.fixed_assigned_rate_cost,
    timesheet.180hrs_rate_cost,

    internal_tasks.Delayed_task,
    internal_tasks.Ontime_task,
    internal_tasks.Pending,
    internal_tasks.Overdue

FROM {{ ref('o2d_bronze') }} AS o2d

LEFT JOIN timesheet
    ON o2d.project_id = timesheet.project_id

LEFT JOIN tasks
    ON o2d.project_id = tasks.project_id

LEFT JOIN {{ ref('keka_project_bronze') }} AS kpj
    ON o2d.project_id = kpj.project_id

LEFT JOIN {{ ref('keka_client_bronze') }} AS kcl
    ON kpj.client_code = kcl.client_code

LEFT JOIN internal_tasks
    ON o2d.project_id = internal_tasks.project_id