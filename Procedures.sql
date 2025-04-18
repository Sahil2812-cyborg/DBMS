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





















 
 
 
 
 
 
