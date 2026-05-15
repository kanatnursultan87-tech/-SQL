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

gender_month AS (
    SELECT
        DATE_FORMAT(c.date_new, '%Y-%m') AS month_name,
        COALESCE(NULLIF(cf.Gender, ''), 'NA') AS gender,
        COUNT(DISTINCT c.ID_client) AS clients_count,
        SUM(c.check_sum) AS total_sum
    FROM checks c
    LEFT JOIN customers cf
        ON c.ID_client = cf.Id_client
    GROUP BY
        DATE_FORMAT(c.date_new, '%Y-%m'),
        COALESCE(NULLIF(cf.Gender, ''), 'NA')
)

SELECT
    month_name,
    gender,
    clients_count,
    ROUND(clients_count * 100 / SUM(clients_count) OVER(PARTITION BY month_name), 2) AS gender_percent,
    ROUND(total_sum, 2) AS total_sum,
    ROUND(total_sum * 100 / SUM(total_sum) OVER(PARTITION BY month_name), 2) AS spending_percent
FROM gender_month
ORDER BY month_name, gender;