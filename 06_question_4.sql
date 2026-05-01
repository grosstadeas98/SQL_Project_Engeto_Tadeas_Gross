--select pro 4. otazku

WITH base AS (
    SELECT 
        record_year,
        name,
        source_type,
        value_average,
        LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) AS prev_value
    FROM t_tadeas_gross_project_sql_primary_final)
SELECT
    record_year AS year,
    ROUND(AVG(CASE WHEN source_type = 'food'
    THEN (value_average / prev_value - 1) * 100 END
    ), 2) AS avg_yoy_food_change,
    ROUND(AVG(CASE WHEN source_type = 'wage' 
    THEN (value_average / prev_value - 1) * 100 END
    ), 2) AS avg_yoy_wage_change
FROM base
WHERE prev_value IS NOT NULL
GROUP BY record_year
ORDER BY record_year;