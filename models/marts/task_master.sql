-- =====================================================================
-- CTE 1: Keka tasks (task_gold)
--   task_gold -> keka_project_bronze (project_id) -> keka_client_bronze (client_code)
--   client_project_master joined only to pick up o2d client name and group
-- =====================================================================
WITH keka_tasks AS (

    SELECT
        CAST(tg.task_id AS STRING)                         AS task_id,
        tg.project_id                                      AS project_id,
        kpj.client_code                                    AS client_id,
        kcl.client_name                                    AS client,
        cpm.client_name                                    AS o2d_client,
        kcl.billing_name                                   AS keka_client,
        cpm.`group`                                        AS `group`,
        CAST(NULL AS STRING)                               AS task,
        tg.spoc_doer                                       AS spoc_doer,
        CAST(tg.end_date AS DATE)                          AS planned,
        CAST(tg.end_date AS DATE)                          AS actual,
        CAST(NULL AS STRING)                               AS mdo,
        CAST(NULL AS STRING)                               AS completion_attachment,
        tg.estimated_hours                                 AS estimated_hours,
        tg.Actual_Hours                                    AS Actual_Hours,
        tg.`180hrs_estimated_budget_mock`                  AS `180hrs_estimated_budget_mock`,
        tg.fixed_rate_estimated_budget                     AS fixed_rate_estimated_budget,
        tg.actual_cost                                     AS actual_cost,
        tg.mock_actual_cost                                AS mock_actual_cost,
        tg.mock_180hrs_cost                                AS mock_180hrs_cost,
        CONCAT_WS('-', 'W', WEEKOFYEAR(CAST(tg.end_date AS DATE)), YEAR(CAST(tg.end_date AS DATE)))  AS week_year,
        CONCAT_WS('-', MONTHNAME(CAST(tg.end_date AS DATE)), YEAR(CAST(tg.end_date AS DATE)))        AS month_year,
        CONCAT_WS('-', 'Q', QUARTER(CAST(tg.end_date AS DATE)), YEAR(CAST(tg.end_date AS DATE)))     AS quarter_year,
        'keka'                                             AS task_source

    FROM {{ ref('task_gold') }} AS tg

    LEFT JOIN {{ ref('keka_project_bronze') }} AS kpj
        ON tg.project_id = kpj.project_id

    LEFT JOIN {{ ref('keka_client_bronze') }} AS kcl
        ON kpj.client_code = kcl.client_code

    LEFT JOIN {{ ref('client_project_master') }} AS cpm
        ON tg.project_id = cpm.project_id
),

-- =====================================================================
-- CTE 2: Internal tasks (internal_task_bronze)
--   client name comes from the internal sheet itself
--   client_project_master gives billing_name (as keka_client), o2d client, group
-- =====================================================================
internal_tasks AS (

    SELECT
        CAST(itb.task_id AS STRING)                        AS task_id,
        itb.project_id                                     AS project_id,
        cpm.client_code                                    AS client_id,
        itb.client                                         AS client,
        cpm.client_name                                    AS o2d_client,
        cpm.billing_name                                   AS keka_client,
        cpm.`group`                                        AS `group`,
        itb.task                                           AS task,
        itb.name                                           AS spoc_doer,
        itb.planned                                        AS planned,
        itb.actual                                         AS actual,
        itb.mdo                                            AS mdo,
        itb.completion_attachment                          AS completion_attachment,
        CAST(NULL AS DOUBLE)                               AS estimated_hours,
        CAST(NULL AS DOUBLE)                               AS Actual_Hours,
        CAST(NULL AS DOUBLE)                               AS `180hrs_estimated_budget_mock`,
        CAST(NULL AS DOUBLE)                               AS fixed_rate_estimated_budget,
        CAST(NULL AS DOUBLE)                               AS actual_cost,
        CAST(NULL AS DOUBLE)                               AS mock_actual_cost,
        CAST(NULL AS DOUBLE)                               AS mock_180hrs_cost,
        itb.week_year                                      AS week_year,
        itb.month_year                                     AS month_year,
        itb.quarter_year                                   AS quarter_year,
        'internal'                                         AS task_source

    FROM {{ ref('internal_task_bronze') }} AS itb

    LEFT JOIN {{ ref('client_project_master') }} AS cpm
        ON itb.project_id = cpm.project_id
)

-- =====================================================================
-- Append both
-- =====================================================================
SELECT * FROM keka_tasks

UNION ALL

SELECT * FROM internal_tasks