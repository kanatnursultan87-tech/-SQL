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

age_quarter AS (
    SELECT
        CONCAT(YEAR(c.date_new), '-Q', QUARTER(c.date_new)) AS quarter_name,
        CASE
            WHEN cf.Age IS NULL OR cf.Age = 0 THEN 'NA'
            WHEN cf.Age < 20 THEN '0-19'
            WHEN cf.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN cf.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN cf.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN cf.Age BETWEEN 50 AND 59 THEN '50-59'
            WHEN cf.Age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_group,
        SUM(c.check_sum) AS total_sum,
        COUNT(DISTINCT c.Id_check) AS operations_count,
        AVG(c.check_sum) AS avg_check
    FROM checks c
    LEFT JOIN customers cf
        ON c.ID_client = cf.Id_client
    GROUP BY quarter_name, age_group
)

SELECT
    quarter_name,
    age_group,
    ROUND(total_sum, 2) AS total_sum,
    operations_count,
    ROUND(avg_check, 2) AS avg_check,
    ROUND(total_sum * 100 / SUM(total_sum) OVER(PARTITION BY quarter_name), 2) AS sum_percent,
    ROUND(operations_count * 100 / SUM(operations_count) OVER(PARTITION BY quarter_name), 2) AS operations_percent
FROM age_quarter
ORDER BY quarter_name, age_group;