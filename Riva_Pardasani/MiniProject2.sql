-- Riva Pardasani

--- Step 2:
CREATE TABLE organizations (
  Index SERIAL PRIMARY KEY,
  Organization_Id VARCHAR(255),
  Name VARCHAR(255),
  Website VARCHAR(255),
  Country VARCHAR(255),
  Description TEXT,
  Founded VARCHAR(5),
  Industry VARCHAR(255),
  Number_of_Employees INT
);

COPY public.organizations (Index, Organization_Id, Name, Website, Country, Description, Founded, Industry, Number_of_Employees)
FROM '/Users/rivapard/Downloads/organizations-10000.csv'
DELIMITER ',' CSV HEADER;

--- Step 3:
-- Task 1:
SELECT 
  Name,
  Country
FROM organizations
LIMIT 20;

-- Task 2:
INSERT INTO organizations (
  Index, Organization_Id, Name, Website, Country, Description, Founded, Industry, Number_of_Employees
)
VALUES (
  100001, 'bC0CEd48A8000E0', 'Velazquez-Odom', 'https://stokes.com/', 'Djibouti',
  'Streamlined 6th generation function', '2002', 'Alternative Dispute Resolution', 4044
);

SELECT *
FROM organizations
WHERE Index = '100001'

-- Task 3:
SELECT
    MIN(Number_of_Employees) AS min_Number_of_Employees,
    MAX(Number_of_Employees) AS max_Number_of_Employees
FROM organizations;

SELECT *
FROM organizations
WHERE
    Number_of_Employees IS NULL;

UPDATE organizations
SET Number_of_Employees = '3135'
WHERE Organization_Id = '6CDCcdE3D0b7b44';

SELECT *
FROM organizations
WHERE Organization_Id = '6CDCcdE3D0b7b44'

-- Task 4:
SELECT DISTINCT Industry
FROM organizations;

SELECT
     Industry,
     COUNT(*) AS count_by_industry
FROM organizations
GROUP BY Industry
ORDER BY count_by_industry DESC;

SELECT
    Industry,
    COUNT(DISTINCT Country) AS Number_of_Countries
FROM organizations
GROUP BY Industry
ORDER BY Number_of_Countries DESC;

-- Task 5:
SELECT
  LENGTH(Founded) AS years_founded
FROM organizations;

SELECT
     Organization_Id, Country, Founded
FROM organizations
WHERE LENGTH(Founded) > 4; 

-- Task 6:
UPDATE organizations
SET Founded = '1980'
WHERE Organization_Id = '74FAA2BF6f0E0ed';

ALTER TABLE public.organizations
ALTER COLUMN founded TYPE VARCHAR(4)
USING SUBSTRING(founded FROM 1 FOR 4);

-- Task 7:
SELECT
Organization_Id,
COUNT(*) AS Occurrences
FROM organizations
GROUP BY Organization_Id
HAVING COUNT(*) > 1;

CREATE TABLE organizations_clean AS
SELECT DISTINCT ON (Organization_Id) *
FROM organizations
ORDER BY Organization_Id, Index;

DROP TABLE organizations;
ALTER TABLE organizations_clean RENAME TO organizations;

-- Task 8:
SELECT
    Country,
    Number_of_employees
FROM organizations
ORDER BY Number_of_employees DESC;

-- Task 9:
SELECT
    Name,
    Country,
    to_date(Founded, 'YYYY') AS Founded_Date
FROM organizations
WHERE to_date(Founded, 'YYYY') BETWEEN '1990-01-01' AND '2000-12-31';

-- Task 10:
SELECT
    CONCAT(Name, ' - ', Country) AS Firm_Details,
    Founded,
    Number_of_Employees
FROM organizations
WHERE
    CAST(Founded AS INTEGER) <= EXTRACT(YEAR FROM CURRENT_DATE) - 20 -- Firms older than 20 years
    AND Number_of_Employees > 6000;

-- Task 11:
SELECT
    CONCAT(Name, ' - ', Country) AS Firm_Details,
    Founded,
    Number_of_Employees
FROM organizations
WHERE
    CAST(Founded AS INTEGER) <= EXTRACT(YEAR FROM CURRENT_DATE) - 20 -- Firms older than 20 years
    AND Number_of_Employees > 6000;

-- Task 12:
SELECT
    TRIM(SUBSTRING(Description FROM '^[A-Za-z]+')) AS First_Word,
    COUNT(*) AS Frequency
FROM organizations
GROUP BY First_Word
ORDER BY Frequency DESC
LIMIT 20;

-- Task 13:
DO $$
DECLARE
    org_id VARCHAR;
BEGIN
    FOR org_id IN
        SELECT Organization_Id
        FROM organizations
    LOOP
        UPDATE organizations
        SET Number_of_Employees = COALESCE(Number_of_Employees, 0) + 100
        WHERE Organization_Id = org_id;
    END LOOP;
END $$;

UPDATE organizations
SET Number_of_Employees = COALESCE(Number_of_Employees, 0) + 100;

CREATE TABLE Departments (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(50)
);

INSERT INTO Departments (Department_ID, Department_Name) VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'Engineering'),
(4, 'Sales'),
(5, 'Service');

CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department_ID INT
);

INSERT INTO Employees (Employee_ID, Employee_Name, Department_ID) VALUES
(101, 'Alice', 1),
(102, 'Bob', 2),
(103, 'Charlie', 3),
(104, 'Diana', NULL),
(105, 'Eve', 4);

-- Task 14:
SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM
    Employees
INNER JOIN
    Departments
ON
    Employees.Department_ID = Departments.Department_ID;

-- Task 15:
SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM
    Employees
LEFT JOIN
    Departments
ON
    Employees.Department_ID = Departments.Department_ID;

-- Task 16:
SELECT
    Departments.Department_ID,
    Departments.Department_Name,
    Employees.Employee_Name
FROM
    Employees
RIGHT JOIN
    Departments
ON
    Employees.Department_ID = Departments.Department_ID;

-- Task 17:
SELECT
    Employees.Employee_ID,
    Employees.Employee_Name,
    Departments.Department_Name
FROM
    Employees
FULL OUTER JOIN
    Departments
ON
    Employees.Department_ID = Departments.Department_ID;

-- Task 18:
SELECT
    warehouse_id,
    warehouse_name,
    (SELECT SUM(amount) FROM Orders) AS total_order_amount
FROM
    Warehouses;

-- Task 19:
SELECT
    W.warehouse_name,
    O.total_amount
FROM
    Warehouses AS W
INNER JOIN (
    SELECT
        warehouse_id,
        SUM(amount) AS total_amount
    FROM
        Orders
    GROUP BY
        warehouse_id
) AS O
ON
    W.warehouse_id = O.warehouse_id;

-- Task 20:
SELECT
    warehouse_name
FROM
    Warehouses
WHERE
    warehouse_id IN (
        SELECT DISTINCT warehouse_id
        FROM Orders
        WHERE customer_id IN (
            SELECT customer_id
            FROM Customers
            WHERE city IN ('New York', 'Dallas')
        )
    );

-- Task 21:
SELECT
    W.warehouse_name,
    COUNT(O.order_id) AS number_of_orders,
    CASE
        WHEN COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) <= 0.20 THEN '0-20% Orders'
        WHEN COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) > 0.20 AND COUNT(O.order_id) * 1.0 / (SELECT COUNT(*) FROM Orders) <= 0.60 THEN '21-60% Orders'
        ELSE 'More than 60% Orders'
    END AS fulfillment_category
FROM
    Warehouses AS W
LEFT JOIN Orders AS O
ON W.warehouse_id = O.warehouse_id
GROUP BY
    W.warehouse_id, W.warehouse_name;




