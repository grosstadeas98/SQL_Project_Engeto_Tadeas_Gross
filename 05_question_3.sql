--2 selecty pro 3. otazku

WITH base AS (
    SELECT
        name,
        record_year,
        value_average,
        LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) AS prev_value
    FROM t_tadeas_gross_project_sql_primary_final
    WHERE source_type = 'food'
)
SELECT
    name,
    record_year,
    value_average,
    prev_value AS previous_year,
    value_average - prev_value AS price_difference_yoy,
    ROUND((value_average / prev_value - 1) * 100, 2) AS price_change_percent
FROM base;

WITH base AS (
    SELECT
        name,
        record_year,
        value_average,
        LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) AS prev_value
    FROM t_tadeas_gross_project_sql_primary_final
    WHERE source_type = 'food'
)
SELECT
    name,
    ROUND(AVG((value_average / prev_value - 1) * 100), 2) AS avg_yoy_price_growth
FROM base
WHERE prev_value IS NOT NULL
GROUP BY name
ORDER BY avg_yoy_price_growth
LIMIT 3;





