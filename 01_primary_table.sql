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

--indexy primarni tabulky (FK pouzity nebyly kvuli absenci ID a agregovanych dat v tabulkach)

CREATE INDEX idx_primary_name_year
ON t_tadeas_gross_project_sql_primary_final (name, record_year);

CREATE INDEX idx_primary_type
ON t_tadeas_gross_project_sql_primary_final (source_type);
