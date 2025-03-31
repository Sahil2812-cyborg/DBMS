Newton School Online MySQL compiler to run SQL online.
Write MySQL code in this online editor and run it.

CREATE TABLE Emp (
    eid INTEGER PRIMARY KEY,          -- Employee ID (Primary Key)
    ename VARCHAR(100),               -- Employee Name
    age INTEGER,                      -- Employee Age
    salary REAL                       -- Employee Salary
);

ALTER TABLE Emp add constraint check_sal check(salary >= 1000);

-- Creating the Dept table
CREATE TABLE Dept (
    did INTEGER PRIMARY KEY,          -- Department ID (Primary Key)
    budget REAL,                      -- Department Budget
    managerid INTEGER,                 -- Manager ID (Foreign Key from Emp)
    FOREIGN KEY (managerid) REFERENCES Emp(eid) -- Foreign Key referencing Emp table
);

ALTER table dept add constraint check_manager_sal check()



-- Creating the Works table
CREATE TABLE Works (
    eid INTEGER,                      -- Employee ID (Foreign Key from Emp)
    did INTEGER,                      -- Department ID (Foreign Key from Dept)
    pcttime INTEGER,                  -- Percentage of time spent on work
    PRIMARY KEY (eid, did),           -- Composite Primary Key
    FOREIGN KEY (eid) REFERENCES Emp(eid),    -- Foreign Key referencing Emp table
    FOREIGN KEY (did) REFERENCES Dept(did)   -- Foreign Key referencing Dept table
);



-- select version();

INSERT INTO Emp (eid, ename, age, salary) 
VALUES 
    (1, 'John Doe', 28, 50000.00),
    (2, 'Jane Smith', 34, 60000.00),
    (3, 'Alice Johnson', 41, 70000.00),
    (4, 'Bob Brown', 29, 55000.00),
    (5, 'Alice Johnson', 41, 70000.00);

INSERT INTO Emp (eid, ename, age, salary) 
VALUES 
 (6, 'Alex Johnson', 41, 500.00);


INSERT INTO Dept (did, budget, managerid)
VALUES 
    (101, 200000.00, 1),   -- Manager: John Doe
    (102, 150000.00, 2);   -- Manager: Jane Smith


INSERT INTO Works (eid, did, pcttime)
VALUES 
    (1, 101, 80),  -- John Doe works 80% time in Dept 101
    (2, 102, 90),  -- Jane Smith works 90% time in Dept 102
    (3, 101, 70),  -- Alice Johnson works 70% time in Dept 101
    (4, 102, 60);  -- Bob Brown works 60% time in Dept 102




DELIMITER $$

CREATE TRIGGER validate_manager_salary
BEFORE INSERT ON Emp
FOR EACH ROW
BEGIN
    DECLARE manager_salary DECIMAL(10,2);

    -- Check if the new employee's manager exists in the dept table
    IF EXISTS (SELECT 1 FROM Dept WHERE managerid = NEW.eid) THEN

        -- Fetch the manager's salary
        SELECT salary INTO manager_salary
        FROM Emp
        WHERE eid = NEW.eid;

        -- Check if the new employee's salary is greater than or equal to the manager's salary
        IF NEW.salary >= manager_salary THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New employee salary must be less than the manager\'s salary.';
        END IF;
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER validate_manager_salary_and_budget
BEFORE INSERT ON Emp
FOR EACH ROW
BEGIN
    -- Check if the employee's manager exists in the department
    IF EXISTS (SELECT 1 FROM dept WHERE managerid = NEW.eid) THEN
        
        -- Declare variable for manager's salary
        DECLARE manager_salary DECIMAL(10,2);
        
        -- Get the manager's salary
        SELECT salary INTO manager_salary
        FROM Emp
        WHERE eid = NEW.eid;

        -- Ensure that the new employee's salary is less than the manager's salary
        IF NEW.salary >= manager_salary THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New employee salary must be less than the manager\'s salary.';
        END IF;
        
        -- Check if the department's budget is greater than the sum of all employee salaries in that department
        DECLARE dept_budget DECIMAL(10,2);
        DECLARE total_salary DECIMAL(10,2);
        
        -- Get the department's budget
        SELECT budget INTO dept_budget
        FROM Dept
        WHERE did = (SELECT did FROM Works WHERE eid = NEW.eid LIMIT 1);
        
        -- Calculate the total salary of all employees in the department
        SELECT SUM(salary) INTO total_salary
        FROM Emp
        WHERE eid IN (SELECT eid FROM Works WHERE did = (SELECT did FROM Works WHERE eid = NEW.eid LIMIT 1));
        
        -- Ensure the department budget is greater than the sum of employee salaries
        IF dept_budget <= total_salary + NEW.salary THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department budget must be greater than the sum of salaries of all employees in the department.';
        END IF;
        
    END IF;
END $$

DELIMITER ;



