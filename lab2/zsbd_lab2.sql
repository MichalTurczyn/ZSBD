-- I
DROP TABLE job_history CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;
DROP TABLE locations CASCADE CONSTRAINTS;
DROP TABLE countries CASCADE CONSTRAINTS;
DROP TABLE regions CASCADE CONSTRAINTS;
DROP TABLE jobs CASCADE CONSTRAINTS;
DROP TABLE products CASCADE CONSTRAINTS;
DROP TABLE sales CASCADE CONSTRAINTS;
DROP TABLE job_grades CASCADE CONSTRAINTS;

-- II
CREATE TABLE regions AS SELECT * FROM hr.regions;
CREATE TABLE countries AS SELECT * FROM hr.countries;
CREATE TABLE locations AS SELECT * FROM hr.locations;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE jobs AS SELECT * FROM hr.jobs;
CREATE TABLE employees AS SELECT * FROM hr.employees;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;
CREATE TABLE job_grades AS SELECT * FROM hr.job_grades;
CREATE TABLE products AS SELECT * FROM hr.products;
CREATE TABLE sales AS SELECT * FROM hr.sales;

ALTER TABLE regions ADD CONSTRAINT pk_regions PRIMARY KEY (region_id);
ALTER TABLE countries ADD CONSTRAINT pk_countries PRIMARY KEY (COUNTRY_ID);
ALTER TABLE locations ADD CONSTRAINT pk_locations PRIMARY KEY (location_id);
ALTER TABLE departments ADD CONSTRAINT pk_departments PRIMARY KEY (DEPARTMENT_ID);
ALTER TABLE jobs ADD CONSTRAINT pk_jobs PRIMARY KEY (job_id);
ALTER TABLE employees ADD CONSTRAINT pk_employees PRIMARY KEY (EMPLOYEE_ID);
ALTER TABLE job_history ADD CONSTRAINT pk_job_history PRIMARY KEY (EMPLOYEE_ID, START_DATE);
ALTER TABLE products ADD CONSTRAINT pk_products PRIMARY KEY (product_id);
ALTER TABLE sales ADD CONSTRAINT pk_sales PRIMARY KEY (sale_id);


ALTER TABLE countries 
  ADD CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE locations 
  ADD CONSTRAINT fk_locations_country FOREIGN KEY (country_id) REFERENCES countries(country_id);

ALTER TABLE employees 
  ADD CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees 
  ADD CONSTRAINT fk_emp_job FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees 
  ADD CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE departments 
  ADD CONSTRAINT fk_departments_loc FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE departments 
  ADD CONSTRAINT fk_departments_mng FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE job_history 
  ADD CONSTRAINT fk_jh_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history 
  ADD CONSTRAINT fk_jh_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE job_history 
  ADD CONSTRAINT fk_jh_job FOREIGN KEY (job_id) REFERENCES jobs(job_id);
  
ALTER TABLE sales 
  ADD CONSTRAINT fk_sales_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE sales 
  ADD CONSTRAINT fk_sales_prd FOREIGN KEY (product_id) REFERENCES products(product_id);

-- III
-- 1.
CREATE OR REPLACE VIEW v_employee_wynagrodzenie AS
SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000;
  
-- 2.
CREATE OR REPLACE VIEW v_employees_2005 AS
SELECT hire_date, last_name, salary
FROM employees
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005;
  
-- 3.
SELECT first_name || ' ' || last_name AS imie_nazwisko, salary, phone_number
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e'
  AND LOWER(first_name) LIKE LOWER('%' || '&czesc_imienia' || '%')
ORDER BY 1 DESC, 2 ASC;

-- 4.
SELECT first_name, 
       last_name, 
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy,
       CASE 
           WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) <= 150 THEN salary * 0.10
           WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) <= 200 THEN salary * 0.20
           ELSE salary * 0.30
       END AS wysokość_dodatku
FROM employees
ORDER BY liczba_miesiecy;

-- 5.
SELECT department_id,
       SUM(salary) AS suma_zarobkow,
       ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

-- 6.
SELECT e.last_name, 
       e.department_id, 
       d.department_name, 
       e.job_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l   ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- 7.
SELECT j.first_name || ' ' || j.last_name AS jennifer,
       c.first_name || ' ' || c.last_name AS wspolpracownik
FROM employees j
JOIN employees c ON j.department_id = c.department_id
WHERE j.first_name = 'Jennifer'
  AND j.employee_id != c.employee_id;
  
-- 8.
SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- 9.
SELECT e.first_name, 
       e.last_name, 
       e.job_id, 
       d.department_name, 
       e.salary, 
       j.grade
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN job_grades j  ON e.salary BETWEEN j.min_salary AND j.max_salary;

--10.
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 11.
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT DISTINCT department_id
    FROM employees
    WHERE LOWER(last_name) LIKE '%u%'
      AND department_id IS NOT NULL
);

-- 12.
SELECT employee_id, 
       first_name, 
       last_name, 
       hire_date,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS miesiace_pracy
FROM employees
WHERE (SYSDATE - hire_date) > (SELECT AVG(SYSDATE - hire_date) FROM employees)
ORDER BY hire_date ASC;

-- 13.
SELECT d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY liczba_pracownikow DESC;

-- 14.
SELECT first_name, last_name, salary
FROM employees
WHERE salary < (
    SELECT MIN(e.salary)
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);

-- 15.
SELECT DISTINCT d.department_id, d.department_name
FROM departments d
JOIN employees e ON d.department_id = e.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);

-- 16.
SELECT j.job_title,
       ROUND(AVG(e.salary), 2) AS srednia_pensja
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_id, j.job_title
ORDER BY srednia_pensja DESC
FETCH FIRST 5 ROWS ONLY;

-- 17.
SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(DISTINCT e.employee_id) AS liczba_pracownikow
FROM regions r
LEFT JOIN countries c   ON r.region_id = c.region_id
LEFT JOIN locations l   ON c.country_id = l.country_id
LEFT JOIN departments d ON l.location_id = d.location_id
LEFT JOIN employees e   ON d.department_id = e.department_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_name;

-- 18.
SELECT e.first_name AS imie_pracownika,
       e.last_name  AS nazwisko_pracownika,
       e.salary     AS zarobki_pracownika,
       m.first_name AS imie_menedzera,
       m.last_name  AS nazwisko_menedzera,
       m.salary     AS zarobki_menedzera
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 19.
SELECT TO_CHAR(hire_date, 'MM') AS numer_miesiaca,
       TO_CHAR(hire_date, 'Month') AS nazwa_miesiaca,
       COUNT(*) AS liczba_pracownikow
FROM employees
GROUP BY TO_CHAR(hire_date, 'MM'), TO_CHAR(hire_date, 'Month')
ORDER BY numer_miesiaca;

-- 20.
SELECT d.department_name,
       ROUND(AVG(e.salary), 2) AS srednia_pensja
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY srednia_pensja DESC
FETCH FIRST 3 ROWS ONLY;