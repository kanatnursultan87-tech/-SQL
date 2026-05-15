WITH checks AS (

    SELECT
        ID_client,
        Id_check,
        date_new,
        SUM(Sum_payment) AS check_sum

    FROM transactions

    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'

    GROUP BY
        ID_client,
        Id_check,
        date_new
),

client_months AS (

    SELECT
        ID_client,
        DATE_FORMAT(date_new, '%Y-%m') AS month_name

    FROM checks

    GROUP BY
        ID_client,
        DATE_FORMAT(date_new, '%Y-%m')
),

full_year_clients AS (

    SELECT ID_client

    FROM client_months

    GROUP BY ID_client

    HAVING COUNT(DISTINCT month_name) = 12
)

SELECT

    c.ID_client,

    ROUND(AVG(c.check_sum), 2) AS avg_check,

    ROUND(SUM(c.check_sum) / 12, 2) AS avg_month_sum,

    COUNT(DISTINCT c.Id_check) AS operations_count,

    ROUND(SUM(c.check_sum), 2) AS total_sum

FROM checks c

JOIN full_year_clients f
    ON c.ID_client = f.ID_client

GROUP BY c.ID_client

ORDER BY total_sum DESC;

