--select pro 2. otazku

SELECT 
    record_year,
    name,
    value_average,
    ROUND(value_average /
    MAX(CASE WHEN name = 'Mléko polotučné pasterované' 
    THEN value_average END) OVER (PARTITION BY record_year), 2)
    AS milk_liters_affordable,
    ROUND(value_average /
    MAX(CASE WHEN name = 'Chléb konzumní kmínový' 
    THEN value_average END) OVER (PARTITION BY record_year), 2)
    AS bread_kg_affordable,
    source_type
FROM t_tadeas_gross_project_sql_primary_final
WHERE
    record_year IN (2006, 2018) AND (name IN ('Chléb konzumní kmínový','Mléko polotučné pasterované') OR source_type = 'wage')
UNION ALL
SELECT
    record_year,
    'Average wage' AS name,
    ROUND(AVG(CASE WHEN source_type = 'wage' THEN value_average END), 2) AS value_average,
    ROUND(AVG(CASE WHEN source_type = 'wage' THEN value_average END) /
    MAX(CASE WHEN name = 'Mléko polotučné pasterované' THEN value_average END), 2) 
    AS milk_liters_affordable,
    ROUND(AVG(CASE WHEN source_type = 'wage' THEN value_average END) /
    MAX(CASE WHEN name = 'Chléb konzumní kmínový' THEN value_average END), 2) 
    AS bread_kg_affordable,
    'wage_avg' AS source_type
FROM t_tadeas_gross_project_sql_primary_final
WHERE record_year IN (2006, 2018)
GROUP BY record_year
ORDER BY source_type, record_year;
