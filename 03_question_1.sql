--select pro 1. otazku

WITH base AS (
    SELECT
        record_year,
        name,
        source_type,
        value_average,
        LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) AS prev_value
    FROM t_tadeas_gross_project_sql_primary_final
    WHERE source_type = 'wage'
)
SELECT
    record_year,
    value_average,
    ROUND((value_average - prev_value) / prev_value * 100, 2) AS wage_yoy_change_pct,
    name,
    source_type
FROM base
ORDER BY name, record_year;