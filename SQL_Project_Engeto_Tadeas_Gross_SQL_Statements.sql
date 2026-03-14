--tvorba primary tabulky

CREATE TABLE t_tadeas_gross_project_sql_primary_final (
    sequence_number BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    record_year INT NOT NULL,
    value_average NUMERIC(12,2) NOT NULL,
    name TEXT NOT NULL,
    source_type TEXT NOT NULL,
    price_per TEXT
);

--insert do primary tabulky

INSERT INTO t_tadeas_gross_project_sql_primary_final
    (record_year, value_average, name, source_type, price_per)
SELECT 
    record_year,
    value_average,
    name,
    source_type,
    price_per
FROM (
    SELECT 
        cpay.payroll_year AS record_year, 
        ROUND(AVG(cpay.value)::numeric, 2) AS value_average,
        cpib.name AS name,
        'wage' AS source_type,
        NULL as price_per
    FROM czechia_payroll AS cpay
    JOIN czechia_payroll_industry_branch AS cpib
        ON cpay.industry_branch_code = cpib.code
    WHERE 
        cpay.value_type_code = 5958
        AND cpay.payroll_year IN (
            SELECT DISTINCT DATE_PART('year', date_from)::int
            FROM czechia_price
            WHERE region_code IS NULL
        )
    GROUP BY 
        cpay.payroll_year,
        cpay.industry_branch_code,
        cpib.name
    UNION ALL
    SELECT
        DATE_PART('year', cp.date_from)::int AS record_year,
        ROUND(AVG(cp.value)::numeric, 2) AS value_average,
        cpc.name AS name,
        'food' AS source_type,
        cpc.price_value::text || ' ' || cpc.price_unit as price_per
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE 
        cp.region_code IS NULL
        AND DATE_PART('year', cp.date_from)::int IN (
            SELECT DISTINCT payroll_year
            FROM czechia_payroll
            WHERE value_type_code = 5958
        )
    GROUP BY 
        DATE_PART('year', cp.date_from)::int,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
) t
ORDER BY source_type, record_year, name;

--tvorba secondary tabulky

CREATE TABLE t_tadeas_gross_project_sql_secondary_final (
    sequence_number BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country TEXT NOT NULL,
    year INT NOT NULL,
    gdp NUMERIC(20,2),
    gini NUMERIC(20,2),
    population INT
);

--insert do secondary tabulky

INSERT INTO t_tadeas_gross_project_sql_secondary_final
    (country, year, gdp, gini, population)
SELECT
    c.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM countries c
JOIN economies e
    ON c.country = e.country
WHERE
    c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018
ORDER BY
    c.country,
    e.year;

--select pro 1. otazku

SELECT
    record_year, 
    value_average, 
    (value_average - LAG(value_average) OVER (PARTITION BY name ORDER BY record_year)) 
    / LAG(value_average) OVER (PARTITION BY name ORDER BY record_year) * 100
    AS wage_yoy_change_pct, name, source_type
FROM t_tadeas_gross_project_sql_primary_final
WHERE source_type = 'wage'
ORDER BY name, record_year;

--select pro 2. otazku

SELECT 
    record_year,
    name,
    value_average,
    value_average /
    MAX(CASE WHEN name = 'Mléko polotučné pasterované' 
    THEN value_average END) OVER (PARTITION BY record_year)
    AS milk_liters_affordable,
    value_average /
    MAX(CASE WHEN name = 'Chléb konzumní kmínový' 
    THEN value_average END) OVER (PARTITION BY record_year) 
    AS bread_kg_affordable,
    source_type
FROM t_tadeas_gross_project_sql_primary_final
WHERE
    record_year IN (2006, 2018) AND (name IN ('Chléb konzumní kmínový','Mléko polotučné pasterované') OR source_type = 'wage')
UNION ALL
SELECT
    record_year,
    'Average wage' AS name,
    AVG(CASE WHEN source_type = 'wage' THEN value_average END) AS value_average,
    AVG(CASE WHEN source_type = 'wage' THEN value_average END) /
    MAX(CASE WHEN name = 'Mléko polotučné pasterované' THEN value_average END) 
    AS milk_liters_affordable,
    AVG(CASE WHEN source_type = 'wage' THEN value_average END) /
    MAX(CASE WHEN name = 'Chléb konzumní kmínový' THEN value_average END) 
    AS bread_kg_affordable,
    'wage_avg' AS source_type
FROM t_tadeas_gross_project_sql_primary_final
WHERE record_year IN (2006, 2018)
GROUP BY record_year
ORDER BY source_type, record_year;

--2 selecty pro 3. otazku

SELECT
    curr.name,
    curr.record_year AS current_year,
    prev.record_year AS previous_year,
    curr.value_average AS price_current_year,
    prev.value_average AS price_previous_year,
    curr.value_average - prev.value_average AS price_difference_yoy,
    ROUND((curr.value_average / prev.value_average - 1) * 100, 2) 
    AS price_change_percent
FROM t_tadeas_gross_project_sql_primary_final curr
JOIN t_tadeas_gross_project_sql_primary_final prev
    ON curr.name = prev.name
    AND curr.record_year = prev.record_year + 1
WHERE curr.source_type = 'food'
ORDER BY curr.name, curr.record_year;

SELECT
    curr.name,
    ROUND(AVG((curr.value_average / prev.value_average - 1) * 100), 2) 
    AS avg_yoy_price_growth
FROM t_tadeas_gross_project_sql_primary_final curr
JOIN t_tadeas_gross_project_sql_primary_final prev
    ON curr.name = prev.name
    AND curr.record_year = prev.record_year + 1
WHERE curr.source_type = 'food'
GROUP BY curr.name
ORDER BY avg_yoy_price_growth
LIMIT 3;

--select pro 4. otazku

SELECT
    curr.record_year AS year,
    AVG(CASE WHEN curr.source_type = 'food'
    THEN (curr.value_average / prev.value_average - 1) * 100 END
    ) AS avg_yoy_food_change,
    AVG(CASE WHEN curr.source_type = 'wage'
    THEN (curr.value_average / prev.value_average - 1) * 100 END
    ) AS avg_yoy_wage_change
FROM t_tadeas_gross_project_sql_primary_final curr
JOIN t_tadeas_gross_project_sql_primary_final prev
    ON curr.name = prev.name
    AND curr.record_year = prev.record_year + 1
GROUP BY curr.record_year
ORDER BY curr.record_year;

--select pro 5. otazku

SELECT
    curr1.record_year AS year,
    AVG(CASE WHEN curr1.source_type = 'food'
        THEN (curr1.value_average / prev1.value_average - 1) * 100 END
    ) AS avg_yoy_food_change,
    AVG(CASE WHEN curr1.source_type = 'wage'
        THEN (curr1.value_average / prev1.value_average - 1) * 100 END
    ) AS avg_yoy_wage_change,
    AVG(case when curr2.country = 'Czech Republic'
    then (curr2.gdp / prev2.gdp - 1) * 100 END
    ) AS avg_gdp_change
FROM t_tadeas_gross_project_sql_primary_final curr1
JOIN t_tadeas_gross_project_sql_primary_final prev1
    ON curr1.name = prev1.name
    AND curr1.record_year = prev1.record_year + 1
JOIN t_tadeas_gross_project_sql_secondary_final curr2
    ON curr1.record_year = curr2.year
JOIN t_tadeas_gross_project_sql_secondary_final prev2
    ON curr2.country = prev2.country
    AND curr2.year = prev2.year + 1
GROUP BY curr1.record_year
ORDER BY curr1.record_year;


