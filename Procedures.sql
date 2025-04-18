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




















 
 
 
 
 
 
