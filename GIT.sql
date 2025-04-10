CREATE DATABASE IF NOT EXISTS WALMART;
CREATE TABLE IF NOT EXISTS SALES(
INVOICE_ID VARCHAR(30) NOT NULL PRIMARY KEY,
BRANCH VARCHAR(5) NOT NULL,
CITY VARCHAR(30) NOT NULL,
CUSTOMER_TYPE VARCHAR(30) NOT NULL,
GENDER VARCHAR(30) NOT NULL,
PRODUCT_LINE VARCHAR(100) NOT NULL,
UNIT_PRICE DECIMAL(10,2) NOT NULL,
QUANTITY INT NOT NULL,
TAX_PCT DECIMAL(6,4) NOT NULL,
TOTAL DECIMAL(12,4) NOT NULL,
DATE datetime NOT NULL,
TIME TIME NOT NULL,
PAYMENT VARCHAR(15) NOT NULL,
COGS DECIMAL(10,2) NOT NULL,
GROSS_MARGIN_PCT DECIMAL(11,9),
GROSS_INCOME DECIMAL(12,4),
RATING FLOAT(2,1)
);
SELECT * FROM sales;

---------------- Feature Engineering---------------------------
---------------- ADD COLUMN TIME OF DAY -----------------------
SELECT TIME,(
CASE 
WHEN TIME BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING" 
WHEN TIME BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
ELSE "EVENING"
END) AS TIME_OF_DAY
FROM sales;

ALTER TABLE sales ADD COLUMN TIME_OF_DAY VARCHAR(20);

UPDATE sales set TIME_OF_DAY=(CASE 
WHEN TIME BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING" 
WHEN TIME BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
ELSE "EVENING"
END);

--------------------------- ADD COLUMN DAY NAME------------

ALTER TABLE sales ADD COLUMN DAY_NAME VARCHAR(20);
UPDATE sales SET DAY_NAME=dayname(DATE);

--------------------------- ADD COLUMN MONTH NAME-----------

ALTER TABLE sales ADD COLUMN MONTH_NAME VARCHAR(20);
UPDATE sales set MONTH_NAME=monthname(DATE);

-------------------------- EDA ----------------
-------------------------- GENRIC QUES -----------
-------------------------- UNIQUE CITIES -----------

SELECT 
	distinct(CITY) 
FROM sales;

----------------- DISTINCT BRANCH IN CITY ---------
SELECT 
	DISTINCT(BRANCH) , 
    CITY 
FROM sales;

--------------- PRODUCT --------------
--------------- HOW MANY UNIQUE PRODUCTS -----------

SELECT distinct(PRODUCT_LINE) FROM sales;

---------------- MOST COMMON PAYMENT METHOD ----------
SELECT 
	COUNT(*)AS CNT,PAYMENT 
FROM sales 
	group by PAYMENT ORDER BY CNT DESC;
    
------------------ MOST SELLING PRODUCT --------------
SELECT 
	PRODUCT_LINE,SUM(QUANTITY) AS TOTAL
FROM sales
group by PRODUCT_LINE
ORDER BY TOTAL DESC;

--------------- TOTAL REVENUE BY MONTH ---------
SELECT MONTH_NAME,SUM(TOTAL) AS REVENUE
FROM sales
GROUP BY MONTH_NAME
ORDER BY REVENUE DESC;

---------- MONTH HAVING LARGEST COGS -------
SELECT 
	MONTH_NAME, SUM(COGS) AS TOTAL_COGS
FROM sales
GROUP BY MONTH_NAME
ORDER BY TOTAL_COGS DESC LIMIT 1;

------------------ product line had the largest revenue -------------------
SELECT 
	PRODUCT_LINE , SUM(TOTAL) AS REVENUE
FROM sales
GROUP BY PRODUCT_LINE
ORDER BY REVENUE DESC;

-------------------- the city with the largest revenue -----------------
SELECT 
	CITY , SUM(TOTAL) AS REVENUE
FROM sales
GROUP BY CITY
ORDER BY REVENUE DESC;

-------------------- product line had the largest VAT ------------------
SELECT
	PRODUCT_LINE , AVG(TAX_PCT) AS AVG_VAT
FROM sales
GROUP BY PRODUCT_LINE
ORDER BY AVG_VAT DESC;

--------------------- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales ----------------
ALTER TABLE sales ADD COLUMN REVIEW VARCHAR(12);

SELECT AVG(QUANTITY) FROM sales;

SELECT PRODUCT_LINE , (CASE
WHEN AVG(QUANTITY)>5.4995 THEN "GOOD"
ELSE "BAD" END) AS REVIEW
FROM sales
GROUP BY PRODUCT_LINE;

------------------------ Which branch sold more products than average product sold? --------
SELECT BRANCH , SUM(QUANTITY)
FROM sales
group by BRANCH
HAVING SUM(QUANTITY)> (SELECT AVG(QUANTITY) FROM sales);

------------------------ What is the most common product line by gender -----------
SELECT PRODUCT_LINE , COUNT(GENDER) AS TOTAL_CNT
FROM sales
GROUP BY PRODUCT_LINE
ORDER BY TOTAL_CNT DESC;

--------------------- What is the average rating of each product line ---------------------

SELECT PRODUCT_LINE,AVG(RATING)
FROM sales
GROUP BY PRODUCT_LINE;

------------------- NOW FOR SALES ----------------
------------------- Number of sales made in each time of the day per weekday -----------------
SELECT TIME_OF_DAY,COUNT(QUANTITY) AS NUMBER_OF_SALES
FROM sales
WHERE DAY_NAME = "Sunday"
group by TIME_OF_DAY
ORDER BY NUMBER_OF_SALES DESC;


-------------------- CUSTOMER TYPE BRING MORE REVENUE ----------------
SELECT CUSTOMER_TYPE , SUM(TOTAL)
FROM sales
GROUP BY CUSTOMER_TYPE
ORDER BY SUM(TOTAL) DESC;

--------------------- Which city has the largest tax percent/ VAT (Value Added Tax)? ------------
SELECT CITY , AVG(TAX_PCT) 
FROM sales
group by CITY
ORDER BY AVG(TAX_PCT) DESC;

------------------------ Which customer type pays the most in VAT ------------
SELECT CUSTOMER_TYPE , AVG(TAX_PCT)
FROM sales
group by CUSTOMER_TYPE

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
ORDER BY AVG(TAX_PCT) DESC;