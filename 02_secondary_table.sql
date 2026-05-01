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

--indexy sekundarni tabulky (FK pouzity nebyly kvuli absenci ID a agregovanych dat v tabulkach)

CREATE INDEX idx_secondary_country_year
ON t_tadeas_gross_project_sql_secondary_final (country, year);