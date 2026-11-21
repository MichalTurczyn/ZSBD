-- 1. 
SELECT employee_id, first_name, last_name, salary,
DENSE_RANK() OVER (ORDER BY salary DESC) AS ranking_pensji
FROM employees;

-- 2.
SELECT employee_id, first_name, last_name, salary,
SUM(salary) OVER () AS calkowita_suma_pensji
FROM employees;

-- 3.
SELECT e.last_name, p.product_name, SUM(s.quantity * s.price) OVER (
    PARTITION BY e.employee_id
    ORDER BY s.sale_date, s.sale_id
    ) AS skumulowana_sprzedaz_pracownika,
    DENSE_RANK() OVER (
        ORDER BY (s.quantity * s.price) DESC
    ) AS ranking_zamowienia
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN products p ON s.product_id = p.product_id;

-- 4.
SELECT 
    e.last_name,
    p.product_name,
    s.price AS cena_produktu,
    COUNT(*) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date)
    ) AS liczba_transakcji_dnia,
    SUM(s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date)
        ) AS suma_dnia_za_produkt,
    LAG(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date, s.sale_id
    ) AS poprzednia_cena,
    LEAD(s.price) OVER (
        PARTITION BY s.product_id
        ORDER BY s.sale_date, s.sale_id
    ) AS kolejna_cena
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id;

-- 5.
SELECT 
    p.product_name,
    s.price AS cena_produkt,
    SUM(s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
    ) AS suma_calkowita_miesiac,
    SUM(s.price) OVER (
        PARTITION BY s.product_id, TRUNC(s.sale_date, 'MM')
        ORDER BY s.sale_date, s.sale_id
    ) AS suma_rosnaca_miesiac
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- 6.
WITH porownanie_lat AS (
    SELECT 
        p.product_name,
        p.product_category, -- lub c.category_name w zależności od nazwy kolumny/tabeli
        EXTRACT(YEAR FROM s.sale_date) AS rok,
        TO_CHAR(s.sale_date, 'MM-DD') AS dzien_miesiac,
        s.price AS cena_2023,
        LAG(s.price) OVER (
            PARTITION BY s.product_id, TO_CHAR(s.sale_date, 'MM-DD')
            ORDER BY EXTRACT(YEAR FROM s.sale_date)
        ) AS cena_2022
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE EXTRACT(YEAR FROM s.sale_date) IN (2022, 2023)
)
SELECT 
    product_name,
    product_category,
    dzien_miesiac,
    cena_2022,
    cena_2023,
    (cena_2023 - cena_2022) AS roznica_cen
FROM porownanie_lat
WHERE rok = 2023 AND cena_2022 IS NOT NULL;

-- 7.
SELECT 
    p.product_category,
    p.product_name,
    s.price AS cena_produktu,
    MIN(s.price) OVER (
        PARTITION BY p.product_category
    ) AS min_cena_w_kategorii,
    MAX(s.price) OVER (
        PARTITION BY p.product_category
    ) AS max_cena_w_kategorii,
    MAX(s.price) OVER (PARTITION BY p.product_category) 
      - MIN(s.price) OVER (PARTITION BY p.product_category) AS roznica_max_min
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- 8.
SELECT 
    p.product_name,
    s.sale_date,
    s.price AS cena_biezaca,
    AVG(s.price) OVER (
        PARTITION BY s.product_id 
        ORDER BY s.sale_date, s.sale_id
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS srednia_kroczaca_ceny
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- 9.
SELECT 
    p.product_name,
    p.product_category,
    s.price,
    RANK() OVER (
        PARTITION BY p.product_category 
        ORDER BY s.price DESC
    ) AS ranking_zwykly,
    ROW_NUMBER() OVER (
        PARTITION BY p.product_category 
        ORDER BY s.price DESC
    ) AS numer_wiersza,
    DENSE_RANK() OVER (
        PARTITION BY p.product_category 
        ORDER BY s.price DESC
    ) AS ranking_gesty
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- 10.
SELECT 
    e.last_name,
    p.product_name,
    (s.price * s.quantity) AS wartosc_zamowienia,
    SUM(s.price * s.quantity) OVER (
        PARTITION BY e.employee_id 
        ORDER BY s.sale_date, s.sale_id
    ) AS wartosc_rosnaca_pracownika,
    DENSE_RANK() OVER (
        ORDER BY (s.price * s.quantity) DESC
    ) AS ranking_globalny_zamowienia
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id;

-- 11.
SELECT DISTINCT 
    e.first_name,
    e.last_name,
    j.job_title
FROM employees e
INNER JOIN sales s ON e.employee_id = s.employee_id
INNER JOIN jobs j ON e.job_id = j.job_id;