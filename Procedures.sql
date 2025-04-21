-- INIT database
CREATE TABLE Product (
  ProductID INT AUTO_INCREMENT KEY,
  Name VARCHAR(100),
  Description VARCHAR(255)
);

INSERT INTO Product(Name, Description) VALUES ('Entity Framework Extensions', 'Use <a href="https://entityframework-extensions.net/" target="_blank">Entity Framework Extensions</a> to extend your DbContext with high-performance bulk operations.');
INSERT INTO Product(Name, Description) VALUES ('Dapper Plus', 'Use <a href="https://dapper-plus.net/" target="_blank">Dapper Plus</a> to extend your IDbConnection with high-performance bulk operations.');
INSERT INTO Product(Name, Description) VALUES ('C# Eval Expression', 'Use <a href="https://eval-expression.net/" target="_blank">C# Eval Expression</a> to compile and execute C# code at runtime.');


ALTER TABLE PRODUCT ADD COLUMN rating INTEGER;
ALTER TABLE PRODUCT MODIFY COLUMN rating FLOAT;


update product set rating = 3.5 where productid = 1;
update product set rating = 4.5 where productid = 2;
update product set rating = 3.8 where productid = 3;



-- SELECT * FROM PRODUCT;

-- QUERY database

DELIMITER $$

CREATE PROCEDURE get_row(IN user_id INT)
BEGIN
    SELECT * FROM product WHERE ProductId = user_id;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE getall(OUT total_count INT)
BEGIN
select count(*) into total_count from Product;
END $$
DELIMITER ;

call getall(@count);




DELIMITER $$

CREATE PROCEDURE add_val(IN numtoadd INT, INOUT total INT)
BEGIN
    SET total = total + numtoadd;
END $$

DELIMITER ;



-- SET @total = 1;
-- CALL add_val(10,@total);
-- select @total;


DELIMITER $$

CREATE PROCEDURE getreviews(IN product VARCHAR(100), OUT review VARCHAR(100))
BEGIN
    DECLARE rated DECIMAL(3,2) DEFAULT 0;
    
    -- Fetch the rating for the given product
    SELECT rating INTO rated 
    FROM PRODUCT 
    WHERE name = product LIMIT 1; -- Ensure only one row is returned
    
    -- Assign review based on the rating
    IF rated > 3.5 AND rated <= 4.0 THEN
        SET review = 'Good';
    ELSEIF rated > 4.0 AND rated <= 4.5 THEN
        SET review = 'Great';
    ELSE
        SET review = 'Excellent'; -- Optional: for ratings above 4.5 or below 3.5
    END IF;
END $$

DELIMITER ;


-- SET @product = 'Dapper Plus';
-- call getreviews(@product,@review);
-- SELECT @review;

DELIMITER $$

CREATE PROCEDURE getviews(IN product VARCHAR(100), OUT review VARCHAR(100))
BEGIN
    DECLARE rated DECIMAL(3,2) DEFAULT 0;

    -- Fetch the rating for the given product
    SELECT rating INTO rated
    FROM PRODUCT
    WHERE name = product LIMIT 1; -- Ensure only one row is returned

    -- Set review based on the rating using CASE
    SET review = CASE 
                    WHEN rated > 3.5 AND rated <= 4.0 THEN 'Good'
                    WHEN rated > 4.0 AND rated <= 4.5 THEN 'Great'
                    ELSE 'Excellent' -- Default value if rating is higher than 4.5
                 END;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE printnumbers()
BEGIN
	DECLARE counter INT DEFAULT 1;
    myloop : LOOP
    IF counter > 10 THEN
    	LEAVE myloop;
    END IF;
    select counter;
    SET counter = counter + 1;
    
    END LOOP myloop;
END $$




DELIMITER ;

-- call printnumbers();

DELIMITER $$

CREATE PROCEDURE printwhilenumbers()

BEGIN
	DECLARE num INT DEFAULT 1;
    WHILE num > 10 DO
    	SELECT num;
    	SET num = num + 2;
    END WHILE;
  END $$

DELIMITER ;
  
call printwhilenumbers();
 
 
DELIMITER $$

CREATE PROCEDURE getName(OUT name VARCHAR(100))
BEGIN
    DECLARE singlename VARCHAR(100) DEFAULT "";
    DECLARE readingstatus BOOL DEFAULT FALSE;
    
    DECLARE namecursor CURSOR FOR SELECT Name FROM product;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET readingstatus = TRUE;
    
    SET name = "";  -- Initialize OUT parameter to empty string
    
    OPEN namecursor;
    
    nameloop: LOOP
        FETCH namecursor INTO singlename;
        
        IF readingstatus THEN
            LEAVE nameloop;
        END IF;
        
        SET name = CONCAT(name, singlename, ';');
    END LOOP nameloop;
    
    CLOSE namecursor;

END $$

DELIMITER ;


SET @name = "";
CALL getName(@name);

SELECT @name;

CREATE TABLE employees (
  emp_id INT PRIMARY KEY,
  name VARCHAR(100),
  department VARCHAR(100),
  salary DECIMAL(10,2),
  hire_date DATE
);

CREATE TABLE departments (
  dept_id INT PRIMARY KEY,
  dept_name VARCHAR(100),
  budget DECIMAL(15,2),
  manager_id INT
);


INSERT INTO departments (dept_id, dept_name, budget, manager_id) VALUES
(1, 'Human Resources', 500000.00, 101),
(2, 'Engineering', 1000000.00, 102),
(3, 'Marketing', 300000.00, 103);


INSERT INTO employees (emp_id, name, department, salary, hire_date) VALUES
(1, 'Alice Johnson', 'Human Resources', 55000.00, '2020-01-10'),
(2, 'Bob Smith', 'Human Resources', 48000.00, '2021-02-20'),
(3, 'Charlie Davis', 'Human Resources', 62000.00, '2019-03-15'),
(4, 'David Miller', 'Engineering', 80000.00, '2020-06-01'),
(5, 'Eve Wilson', 'Engineering', 75000.00, '2018-07-23'),
(6, 'Frank Brown', 'Engineering', 95000.00, '2022-09-12'),
(7, 'Grace Taylor', 'Marketing', 47000.00, '2021-05-18'),
(8, 'Hannah Lee', 'Marketing', 50000.00, '2020-08-15'),
(9, 'Irene Martinez', 'Marketing', 60000.00, '2021-11-01'),
(10, 'John Clark', 'Engineering', 85000.00, '2019-04-03');




DELIMITER //

CREATE PROCEDURE GetDepartmentStats(IN p_dept_name VARCHAR(100))
BEGIN
    DECLARE total_salary DECIMAL(15,2);
    DECLARE employee_count INT;
    DECLARE dept_budget DECIMAL(15,2);
    DECLARE budget_utilization DECIMAL(10,2);
    
    -- Get the department's budget
    SELECT budget INTO dept_budget
    FROM departments 
    WHERE dept_name = p_dept_name;
    
    -- Get total salary expense and employee count
    SELECT 
        SUM(salary), 
        COUNT(*)
    INTO 
        total_salary, 
        employee_count
    FROM employees
    WHERE department = p_dept_name;
    
    -- Handle NULL values for calculations
    IF total_salary IS NULL THEN
        SET total_salary = 0;
    END IF;
    
    IF employee_count IS NULL THEN
        SET employee_count = 0;
    END IF;
    
    -- Calculate budget utilization as percentage
    IF dept_budget > 0 THEN
        SET budget_utilization = (total_salary / dept_budget) * 100;
    ELSE
        SET budget_utilization = 0;
    END IF;
    
    -- Return the results
    SELECT 
        p_dept_name AS 'Department',
        total_salary AS 'Total Salary Expense',
        employee_count AS 'Number of Employees',
        CONCAT(ROUND(budget_utilization, 2), '%') AS 'Budget Utilization';
    
END //

DELIMITER ;


CALL GetDepartmentStats('Marketing');


CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  signup_date DATE
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)  -- Foreign key reference to customers
);

ALTER TABLE orders ADD COLUMN status VARCHAR(50);

CREATE TABLE order_items (
  item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)  -- Foreign key reference to orders
);  -- Removed the trailing comma here

-- Inserting data into the tables
INSERT INTO customers (customer_id, name, email, signup_date) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', '2020-01-10'),
(2, 'Bob Smith', 'bob.smith@example.com', '2021-02-20'),
(3, 'Charlie Davis', 'charlie.davis@example.com', '2019-03-15'),
(4, 'David Miller', 'david.miller@example.com', '2022-06-01'),
(5, 'Eve Wilson', 'eve.wilson@example.com', '2018-07-23');

INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(1, 1, '2025-01-15', 250.75),
(2, 2, '2025-02-10', 450.50),
(3, 3, '2025-03-20', 150.25),
(4, 4, '2025-04-18', 500.00),
(5, 5, '2025-04-05', 300.60);

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 101, 2, 50.25),
(2, 1, 102, 1, 150.50),
(3, 2, 101, 3, 50.25),
(4, 2, 103, 2, 75.00),
(5, 3, 104, 1, 150.25),
(6, 3, 102, 2, 150.50),
(7, 4, 105, 4, 125.00),
(8, 4, 101, 1, 50.25),
(9, 5, 102, 2, 150.50),
(10, 5, 106, 1, 100.00);


DELIMITER $$

CREATE PROCEDURE topcustomers()
BEGIN

WITH recent_orders AS (
    SELECT 
        o.customer_id,
        o.order_id,
        o.order_date,
        o.total_amount
    FROM orders o
    WHERE o.order_date >= CURDATE() - INTERVAL 3 MONTH
),
total_spend AS (
    SELECT 
        ro.customer_id,
        SUM(ro.total_amount) AS total_spent
    FROM recent_orders ro
    GROUP BY ro.customer_id
),
most_common_products AS (
    SELECT 
        ro.customer_id,
        oi.product_id,
        COUNT(oi.product_id) AS product_count
    FROM recent_orders ro
    JOIN order_items oi ON ro.order_id = oi.order_id
    GROUP BY ro.customer_id, oi.product_id
),
top_products AS (
    SELECT
        customer_id,
        product_id,
        RANK() OVER (PARTITION BY customer_id ORDER BY product_count DESC) AS product_rank
    FROM most_common_products
)
SELECT 
    ts.customer_id,
    ts.total_spent,
    tp.product_id AS most_common_product
FROM total_spend ts
JOIN top_products tp ON ts.customer_id = tp.customer_id
WHERE tp.product_rank = 1
ORDER BY ts.total_spent DESC
LIMIT 5;



END $$

DELIMITER ;

-- call topcustomers();


DELIMITER $$

CREATE PROCEDURE getallproducts(IN cname VARCHAR(50))
BEGIN

    DECLARE customer VARCHAR(100);
    DECLARE prod_id INT;
    
    -- This only works for a single row result
    -- Will cause error if multiple rows are returned
    SELECT c.name, oi.product_id INTO customer, prod_id
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE c.name = cname
    LIMIT 1;
    
    SELECT customer, prod_id;

END $$


DELIMITER ;

SET @cname = 'David Miller';

-- call getallproducts(@cname);


DELIMITER $$
CREATE PROCEDURE getcustomerordersummary(IN custid INT)
BEGIN
SELECT name,count(o.order_id) as total_orders, sum(total_amount),avg(total_amount) from customers c
join orders o on c.customer_id = o.customer_id where c.customer_id = custid group by name;

END$$

DELIMITER ;

set @id = 1;

-- call getcustomerordersummary(@id);


DELIMITER $$
CREATE PROCEDURE GetTopCustomers(IN n INT)
BEGIN

SELECT name, email, sum(total_amount) as total_spending from customers c join orders o
on c.customer_id = o.customer_id group by name, email
order by total_spending DESC
limit n;

END $$

DELIMITER ;

SET @n = 3;

-- call GetTopCustomers(@n);


DELIMITER $$

CREATE PROCEDURE FindInactiveCustomers()
BEGIN
    SELECT c.customer_id, c.name
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_id IS NULL;
END $$

DELIMITER ;


call FindInactiveCustomers();


SELECT MONTH(order_date) as month, DAY(order_date) AS day from orders;

CREATE INDEX idx_unpaid_orders ON orders (order_id)
WHERE payment_status = 'unpaid';




















 
 
 
 
 
 
