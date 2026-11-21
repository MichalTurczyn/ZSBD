-- 1
CREATE OR REPLACE VIEW v_wysokie_pensje AS SELECT * FROM employees WHERE salary > 6000;

-- 2
CREATE OR REPLACE VIEW v_wysokie_pensje AS SELECT * FROM employees WHERE salary > 12000;

-- 3
DROP VIEW v_wysokie_pensje;

-- 4
CREATE OR REPLACE VIEW v_from_finance AS
SELECT e.employee_id, e.last_name, e.first_name FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = 'Finance';

-- 5
CREATE OR REPLACE VIEW v_miedzy_5_12k AS
SELECT e.employee_id, e.last_name, e.first_name, e.salary, e.job_id, e.email, e.hire_date
FROM employees e WHERE e.salary BETWEEN 5000 AND 12000;

-- 6
INSERT INTO v_from_finance (employee_id, first_name, last_name) 
VALUES (999, 'Jan', 'Kowalski');

DELETE FROM v_from_finance WHERE first_name = 'Jan';
UPDATE v_from_finance SET last_name = 'Nowak' WHERE last_name = 'Kowalski';

-- 7
CREATE OR REPLACE VIEW v_przynajmniej_4 AS
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS liczba_pracownikow,
AVG(e.salary) AS srednia_pensja, MAX(e.salary) AS max_pensja
FROM departments d INNER JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id);

-- 8
CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT * FROM employees WHERE salary > 12000
WITH CHECK OPTION;

-- 9
CREATE MATERIALIZED VIEW v_managerowie AS
SELECT DISTINCT m.employee_id, m.first_name, m.last_name, d.department_name
FROM employees e JOIN employees m ON e.manager_id = m.employee_id
LEFT JOIN departments d ON m.department_id = d.department_id;

--10
CREATE OR REPLACE VIEW v_naj_oplacani AS
SELECT first_name, last_name FROM employees 
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;