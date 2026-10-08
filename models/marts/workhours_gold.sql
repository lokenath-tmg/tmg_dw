SELECT 
    workhrs.month_date,
    workhrs.employee_number,
    workhrs.employee_name,
    workhrs.total_days_worked,
    workhrs.total_leave,
    workhrs.total_days_absent,
    workhrs.total_effective_hours,
    workhrs.month_year,
    workhrs.quarter_year,

    SUM(tms.total_hours) AS timesheet_hours,

    r.monthly_salary AS total_monthly_salary,

    (
        COALESCE(workhrs.total_days_worked, 0)
        + COALESCE(workhrs.total_leave, 0)
    ) AS total_payable_days,

    COALESCE(
        TRY_DIVIDE(
            r.monthly_salary,
            COALESCE(workhrs.total_days_worked, 0)
            + COALESCE(workhrs.total_leave, 0)
            + COALESCE(workhrs.total_days_absent, 0)
        ),
        0
    ) AS total_monthly_rate,

    COALESCE(
        TRY_DIVIDE(
            r.monthly_salary,
            COALESCE(workhrs.total_days_worked, 0)
            + COALESCE(workhrs.total_leave, 0)
            + COALESCE(workhrs.total_days_absent, 0)
        )
        *
        (
            COALESCE(workhrs.total_days_worked, 0)
            + COALESCE(workhrs.total_leave, 0)
        ),
        0
    ) AS payable_salary,

    COALESCE(
        (
            TRY_DIVIDE(
                r.monthly_salary,
                COALESCE(workhrs.total_days_worked, 0)
                + COALESCE(workhrs.total_leave, 0)
                + COALESCE(workhrs.total_days_absent, 0)
            )
            *
            (
                COALESCE(workhrs.total_days_worked, 0)
                + COALESCE(workhrs.total_leave, 0)
            )
        )
        / NULLIF(SUM(tms.total_hours), 0),
        0
    ) AS hourly_payable_rate

FROM {{ ref('workhours_bronze') }} AS workhrs

LEFT JOIN {{ ref('timesheet_bronze') }} AS tms 
    ON workhrs.employee_number = tms.employee_number
    AND workhrs.month_year = tms.month_year

LEFT JOIN {{ ref('rates_bronze') }} AS r 
    ON workhrs.employee_number = r.employee_number 
    AND workhrs.month_date >= r.effective_date 
    AND (
        workhrs.month_date < r.next_effective_date 
        OR r.next_effective_date IS NULL
    )

GROUP BY 
    workhrs.month_date,
    workhrs.employee_number,
    workhrs.employee_name,
    workhrs.total_days_worked,
    workhrs.total_leave,
    workhrs.total_days_absent,
    workhrs.total_effective_hours,
    workhrs.month_year,
    workhrs.quarter_year,
    r.monthly_salary