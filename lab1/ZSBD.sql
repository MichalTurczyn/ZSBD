CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(30)
);

CREATE TABLE countries (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR(40),
    region_id INT REFERENCES regions(region_id)
);

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    street_address VARCHAR(40),
    postal_code VARCHAR(12),
    city VARCHAR(30) NOT NULL,
    state_province VARCHAR(25),
    country_id CHAR(2) REFERENCES countries(country_id)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL
);

CREATE TABLE jobs (
    job_id VARCHAR(10) PRIMARY KEY,
    job_title VARCHAR(35) NOT NULL,
    min_salary INT,
    max_salary INT,
    CHECK (max_salary - min_salary >= 2000)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL REFERENCES jobs(job_id),
    salary NUMBER(8,2) CHECK (salary > 0),
    manager_id INT REFERENCES employees(employee_id),
    department_id INT REFERENCES departments(department_id)
);

CREATE TABLE job_history (
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL REFERENCES jobs(job_id),
    department_id INT REFERENCES departments(department_id),
    PRIMARY KEY (employee_id, start_date),
    CHECK (end_date > start_date)
);



ALTER TABLE departments ADD manager_id INT;
ALTER TABLE departments ADD location_id INT;
ALTER TABLE employees ADD commission_pct NUMBER(2,2);

ALTER TABLE departments ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);



INSERT INTO jobs VALUES ('job1', 'Programista', 5000, 8000);
INSERT INTO jobs VALUES ('job2', 'Sprzedawca', 4000, 6000);
INSERT INTO jobs VALUES ('job3', 'Ksiegowy', 4500, 6500);
INSERT INTO jobs VALUES ('job4', 'Prezes', 8000, 15000);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary) 
VALUES (1, 'Jan', 'Kowalski', 'jkowalski@wp.pl', '2023-01-10', 'job1', 5000);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary) 
VALUES (2, 'Anna', 'Nowak', 'anowak@wp.pl', '2023-02-15', 'job2', 4000);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary) 
VALUES (3, 'Piotr', 'Wisniewski', 'pwisniewski@wp.pl', '2023-03-20', 'job3', 4500);

INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary) 
VALUES (4, 'Marek', 'Zieliński', 'mzielinski@wp.pl', '2023-04-05', 'job1', 5500);



UPDATE employees SET manager_id = 1 WHERE employee_id IN (2, 3);



UPDATE jobs SET min_salary = min_salary + 500, max_salary = max_salary + 500 
WHERE job_title LIKE '%b%' OR job_title LIKE '%s%' OR job_title LIKE '%B%' OR job_title LIKE '%S%';


DELETE FROM jobs WHERE max_salary > 9000;

DROP TABLE job_history;

FLASHBACK TABLE job_history TO BEFORE DROP;