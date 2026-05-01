--select pro 5. otazku

WITH primary_base AS (
    SELECT 
        record_year,
        name,
        source_type,
        value_average,
        LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) AS prev_value
    FROM t_tadeas_gross_project_sql_primary_final),
secondary_base AS (
    SELECT
        year,
        country,
        gdp,
        LAG(gdp) OVER (PARTITION BY country ORDER BY year) AS prev_gdp
    FROM t_tadeas_gross_project_sql_secondary_final
    WHERE country = 'Czech Republic')
SELECT
    prim.record_year AS year,
    ROUND(AVG(CASE 
        WHEN prim.source_type = 'food' THEN
            (prim.value_average / prim.prev_value - 1) * 100
    END), 2) AS avg_yoy_food_change,
    ROUND(AVG(CASE 
        WHEN prim.source_type = 'wage' THEN
            (prim.value_average / prim.prev_value - 1) * 100
    END), 2) AS avg_yoy_wage_change,
    ROUND((sec.gdp / sec.prev_gdp - 1) * 100, 2) AS avg_gdp_change
FROM primary_base prim
JOIN secondary_base sec
    ON prim.record_year = sec.year
WHERE 
    prim.prev_value IS NOT NULL
    AND sec.prev_gdp IS NOT NULL
GROUP BY prim.record_year, sec.gdp, sec.prev_gdp
ORDER BY prim.record_year;
