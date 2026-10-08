WITH payment_schedule AS (

    SELECT
        project_id,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(
                CONCAT_WS(
                    '-',
                    payment_terms,
                    expected_payment_date
                )
            )
        ) AS payment_terms_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(address)
        ) AS address_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(pan_tin)
        ) AS pan_tin_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(gst_number)
        ) AS gst_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(industry)
        ) AS industry_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(founder)
        ) AS founder_,

        CONCAT_WS(
            ' || ',
            COLLECT_LIST(poc)
        ) AS poc_

    FROM {{ ref('payment_schedule_bronze') }}

    GROUP BY project_id
)

SELECT
    o2d.onboarded,
    o2d.project_id,
    o2d.lead_name,
    o2d.client_email,
    o2d.client_phone,
    o2d.group,
    o2d.city,
    o2d.sow,
    o2d.attached_proposal,

    kcl.billing_name,
    kcl.client_code,

    ps.payment_terms_,
    ps.address_,
    ps.pan_tin_,
    ps.gst_,
    ps.industry_,
    ps.founder_,
    ps.poc_

FROM {{ ref('o2d_bronze') }} AS o2d

LEFT JOIN payment_schedule AS ps
    ON o2d.project_id = ps.project_id
LEFT JOIN {{ ref('keka_project_bronze') }} as kpj
  ON o2d.project_id = kpj.project_id
LEFT JOIN {{ ref('keka_client_bronze') }} as kcl
on kpj.client_code = kcl.client_code