use classicmodels;

Select * from customers;

#1.a.	
select employeeNumber,firstname,lastname from employees
where reportsTo=1102;

#1.b.	
SELECT DISTINCT PRODUCTLINE FROM PRODUCTS
WHERE PRODUCTLINE LIKE '%CARS';

#2.a?
SELECT CUSTOMERNUMBER,CUSTOMERNAME,
CASE 
	WHEN COUNTRY="USA" OR "CANADA" THEN "NORTH AMERICA"
    WHEN COUNTRY="UK" OR "FRANCE" OR "GERMANY" THEN "EUROPE"
    ELSE "OTHERS"
END AS CUSTOMERSEGMENT
FROM CUSTOMERS;

#3.a.	
SELECT  PRODUCTCODE,SUM(QUANTITYORDERED) AS TOTAL_ORDERED FROM ORDERDETAILS
GROUP BY PRODUCTCODE
ORDER BY TOTAL_ORDERED DESC
LIMIT 10;

#3.b?
SELECT date_format(PAYMENTDATE,'%M') AS PAYMENT_MONTH,COUNT(customernumber) AS NUM_PAYMENTS
FROM PAYMENTS
GROUP BY PAYMENT_MONTH 
HAVING NUM_PAYMENTS > 20
ORDER BY NUM_PAYMENTS DESC;



#4. 


CREATE DATABASE CUSTOMERS_ORDERS;

USE CUSTOMERS_ORDERS;

CREATE TABLE CUSTOMERS( 
						CUSTOMER_ID int primary key auto_increment,
                        FIRST_NAME varchar(50) NOT NULL,
                        LAST_NAME varchar(50) NOT NULL,
                        EMAIL varchar(255) UNIQUE,
                        PHONE_NUMBER varchar(20));

CREATE TABLE ORDERS(
					ORDER_ID int primary key auto_increment,
                    CUSTOMER_ID INT references CUSTOMERS(CUSTOMER_ID),
                    ORDER_DATE date,
                    TOTAL_AMOUNT decimal(10,2) check(TOTAL_AMOUNT>=0));
                    
#5.a. 

SELECT CUSTOMERS.COUNTRY,count(ORDERS.CUSTOMERNUMBER) AS ORDER_COUNT
FROM ORDERS
INNER JOIN CUSTOMERS ON ORDERS.CUSTOMERNUMBER=CUSTOMERS.CUSTOMERNUMBER
GROUP BY CUSTOMERS.COUNTRY
ORDER BY ORDER_COUNT DESC
LIMIT 5;


#6.

create table project (
						EMPLOYEEID int PRIMARY KEY auto_increment,
                        FULLNAME VARCHAR(50) NOT NULL,
                        GENDER ENUM('Male', 'Female'),
                        MANAGERID INT);

INSERT INTO PROJECT VALUES
							(1,"PRANAYA","Male",3),
                            (2,"Priyanka","Female",1),
                            (3,"Preety","Female",null),
                            (4,"Anurag","Male",1),
                            (5,"Sambit","Male",1),
                            (6,"Rajesh","Male",3),
                            (7,"Hina","Female",3);
                            
SELECT * FROM PROJECT;

SELECT a.FULLNAME AS "MANAGER NAME",e.FULLNAME AS "EMP NAME" 
FROM PROJECT e
inner JOIN PROJECT a ON e.MANAGERID=a.EmployeeID;



#Q7. DDL Commands: Create, Alter, Rename?

Create table FACILITY(
						Facility_id int,
                        Name varchar(100),
                        State varchar(100),
                        Country varchar(100));

alter table facility
 modify 
		facility_id int primary key auto_increment;

alter table facility
 add column
			city varchar(100) not null;
describe facility;

#8 CREATE VIEW ?

create view product_category_sales as
select products.productline,SUM(orderdetails.quantityordered*orderdetails.priceeach) as total_sales,Count(distinct orders.ordernumber) as number_of_orders 
from ((orderdetails 
inner join products on orderdetails.productcode=products.productcode)
inner join orders on orderdetails.ordernumber=orders.ordernumber)
group by products.productline;

select * from product_category_sales;


#Q9. Stored Procedures in SQL with parameters?

DELIMITER //

CREATE PROCEDURE Get_country_payments(IN inputYear INT, IN inputCountry VARCHAR(255)) 
BEGIN 
	SELECT YEAR(p.paymentDate) AS Year, c.country AS Country, CONCAT(FORMAT(SUM(p.amount)/1000, 0), 'K') AS TotalAmount
    FROM Payments p 
    inner JOIN Customers c ON p.customerNumber = c.customerNumber 
    WHERE YEAR(p.paymentDate) = inputYear AND c.country = inputCountry 
    GROUP BY Year, Country; 
    END// 
    
    DELIMITER ;
    

call Get_country_payments(2023,'usa');

DROP PROCEDURE IF EXISTS Get_country_payments;


#10.a) Using customers and orders tables, rank the customers based on their order frequency?

select customers.customerName,count(orders.customernumber) as Order_count,dense_rank() over (order by count(orders.customernumber) desc) as order_frequency_rnk
from customers
inner join orders on customers.customernumber=orders.customernumber
group by orders.customernumber
#having order_count>3
order by order_frequency_rnk;

#10.b)Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign?

WITH YearMonthOrderCounts AS (
    SELECT YEAR(orderDate) AS `Year`,MONTHNAME(orderDate) AS `Month`,
        MONTH(orderDate) AS `MonthNumber`,COUNT(orderNumber) AS OrderCount
    FROM orders
    GROUP BY YEAR(orderDate), MONTHNAME(orderDate), MONTH(orderDate)
),
YoYCalculation AS (
    SELECT `Year`,`Month`,`MonthNumber`,OrderCount,LAG(OrderCount, 1) OVER (ORDER BY `Year`) AS PreviousYearOrderCount
    FROM YearMonthOrderCounts
)
SELECT `Year`,`Month`,OrderCount,
    CASE 
        WHEN PreviousYearOrderCount IS NULL THEN 'N/A'
        ELSE CONCAT(ROUND((OrderCount - PreviousYearOrderCount) * 100.0 / PreviousYearOrderCount, 0), '%')
    END AS YoY_Change
FROM YoYCalculation
ORDER BY `Year`, `MonthNumber`;

#11.a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count?

select productline,count(buyprice) as Total
from products
Where buyprice >(SELECT AVG(buyprice) FROM Products)
group by productline
order by total desc;



CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

DELIMITER //

#Q12. ERROR HANDLING in SQL?

CREATE PROCEDURE InsertIntoEmp_EH(IN p_EmpID INT, IN p_EmpName VARCHAR(100), IN p_EmailAddress VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback any changes made if an error occurs
        ROLLBACK;
        -- Show the error message
        SELECT 'Error occurred' AS ErrorMessage;
    END;

    -- Start a transaction
    START TRANSACTION;

    -- Insert the values into the Emp_EH table
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    -- Commit the transaction
    COMMIT;
END //

DELIMITER ;


CALL InsertIntoEmp_EH(1, 'B Abhi', 'abhi.b@gmail.com');

#13.Triggers?

CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);


DELIMITER //

CREATE TRIGGER Before_Insert_Emp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;

INSERT INTO Emp_BIT VALUES ('Abhi', 'Data Scientist', '2023-08-13', -8);

SELECT * FROM Emp_BIT;
