WITH checks AS (
    SELECT
        ID_client,
        Id_check,
        date_new,
        SUM(Sum_payment) AS check_sum
    FROM transactions
    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'
    GROUP BY ID_client, Id_check, date_new
),

year_total AS (
    SELECT
        COUNT(DISTINCT Id_check) AS total_operations_year,
        SUM(check_sum) AS total_sum_year
    FROM checks
)

SELECT
    DATE_FORMAT(c.date_new, '%Y-%m') AS month_name,
    ROUND(AVG(c.check_sum), 2) AS avg_check_month,
    ROUND(COUNT(DISTINCT c.Id_check) / COUNT(DISTINCT c.ID_client), 2) AS avg_operations_per_client,
    COUNT(DISTINCT c.ID_client) AS active_clients,
    ROUND(COUNT(DISTINCT c.Id_check) * 100 / y.total_operations_year, 2) AS operations_share_percent,
    ROUND(SUM(c.check_sum) * 100 / y.total_sum_year, 2) AS sum_share_percent
FROM checks c
CROSS JOIN year_total y
GROUP BY
    DATE_FORMAT(c.date_new, '%Y-%m'),
    y.total_operations_year,
    y.total_sum_year
ORDER BY month_name;