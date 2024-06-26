-- DATA Wrangling--

CREATE DATABASE IF NOT EXISTS AMAZON;

CREATE TABLE IF NOT EXISTS sales (
     invoice_id VARCHAR(30) NOT NULL PRIMARY KEY ,
     branch VARCHAR(5) NOT NULL ,
     City VARCHAR(30) NOT NULL,
     customer_type VARCHAR(30) NOT NULL ,
     gender VARCHAR (20) NOT NULL,
     product_line VARCHAR(100) NOT NULL,
     unit_price DECIMAL(10,2),
     quantity INT NOT NULL,
     VAT FLOAT(6,4)NOT NULL,
     total DECIMAL (12,9) NOT NULL,
     date DATETIME NOT NULL,
     time TIME NOT NULL,
     payment_method VARCHAR(15) NOT NULL,
     cogs DECIMAL (10,2) NOT NULL,
     gross_margin_Pct FLOAT (11,9),
     gross_income DECIMAL (12,4) NOT NULL,
     rating FLOAT(2,1) 
     );
     
     -- FEATURE ENGINEERING --

-- time of the day 
SELECT 
     time,
     (CASE
       WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE 'Evening'
     END) AS time_of_date
FROM sales;

 ALTER TABLE sales ADD COLUMN time_of_day VARCHAR (20);
  
  UPDATE sales
  SET time_of_day = ( 	
   CASE
       WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
       WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
       ELSE 'Evening'
     END);

-- day name
SELECT 
    date,
    dayname(date)
FROM sales; 

 ALTER TABLE sales ADD COLUMN day_name VARCHAR (10);
  UPDATE sales
 SET day_name = dayname(date);


-- month name 
SELECT
      date,
      monthname(date)
FROM sales;

 ALTER TABLE sales ADD COLUMN month_name VARCHAR (20); 
 UPDATE sales
 SET month_name = monthname(date);

-------------- Exploratory data analysis (EDA)------------

-- Q.1 what is the count of distinct cities in dataset ?
SELECT 
    DISTINCT city
FROM sales;
-- There are 3 distinct cities Yangon,Naypyitaw,Mandalay --

-- Q.2 For each branch, what is the corresponding city?
SELECT 
    DISTINCT city,
    branch
FROM sales;


-- Q.3 What is the count of distinct product lines in the dataset?
SELECT
    COUNT(DISTINCT product_line)
FROM sales;
-- The distinct count for product lines is 6 --


-- Q.4 Which payment method occurs most frequently?

SELECT payment_method,
     COUNT(*) AS count_payment_method
FROM sales
GROUP BY payment_method
ORDER BY count_payment_method DESC;
-- The most frequently use payment method is cash with count of 342 ------


-- Q.5 Which product line has the highest sales?

SELECT product_line ,                                                                 
	 SUM(quantity ) AS sum_qty
FROM sales
GROUP BY product_line 
ORDER BY sum_qty  DESC;
-- Electronic accessories has the highest sales with count of 961 ---

-- Q.6 How much revenue is generated each month?
SELECT month_name,
      SUM(total) As total_revenue     
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;
--  january months has generated 111205.56 after this march 107844.66 and last is february with 92624.73 --

-- Q.7 In which month did the cost of goods sold reach its peak?
SELECT
    month_name,
    SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;
-- In january month cost of goods was highest 105910.20--

-- Q.8 Which product line generated the highest revenue?
SELECT product_line,
     SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;
-- food and beverages has the highest revenue which is 55110.38--

-- Q.9 In which city was the highest revenue recorded?
SELECT branch,city,
     SUM(total) AS total_revenue
FROM sales
GROUP BY branch,city
ORDER BY total_revenue DESC;
-- yangon has the highest revenue recorded--

-- Q.10 Which product line incurred the highest Value Added Tax?
SELECT
    product_line,
    SUM(vat) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;
-- Food and beverages has incurred highest value added tax--

-- Q.11 For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT
    product_line,
    SUM(total) AS total_sales,
    CASE
        WHEN SUM(total) > AVG(SUM(total)) OVER () THEN 'Good'
        ELSE 'Bad'
    END AS total_category
FROM sales
GROUP BY product_line
ORDER BY product_line;


-- Q.12 Identify the branch that exceeded the average number of products sold.
SELECT city,
    branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch,city
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
-- branch A Yangon has exceeded average number of products sold with 1839 quantity--

-- Q.13 Which product line is most frequently associated with each gender?
SELECT gender,
    product_line,
    count(gender) AS total_count
FROM sales
GROUP BY gender,product_line
ORDER BY total_count DESC;
-- fashion and accessories are most frequently associated with female health and beauty are associated with males--

-- Q.14 Calculate the average rating for each product line.
SELECT 
     AVG(rating) AS avg_rating,
     product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- Q.15 Count the sales occurrences for each time of day on every weekday.
SELECT time_of_day,day_name,
      count(*) AS total_sales
FROM sales
Where day_name IN ('monday','tuesday','wednesday','thursday','friday' )
GROUP BY day_name,time_of_day
ORDER BY day_name,total_sales DESC LIMIT 1;
-- For Afternoon we have the highest number of sales--

-- Q.16 Identify the customer type contributing the highest revenue.
SELECT customer_type,
     SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;
-- Member customer type is contributing highest revenue with 160527.28--

-- Q.17 Determine the city with the highest VAT percentage.
SELECT city,
     MAX(VAT) AS Total_vat
FROM sales
GROUP BY city
ORDER BY total_vat;
-- Mandalay has highest VAT percentage

-- Q.18 Identify the customer type with the highest VAT payments.
SELECT customer_type,
      MAX(VAT) AS highest_vat_payment
FROM sales
GROUP BY customer_type
ORDER BY highest_vat_payment DESC;
-- Member customer type has the highest VAT payment--

-- Q.19 What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM sales;
-- There are two distinct customer type --

-- Q.20 What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment_method) AS distinct_payment_method
FROM sales;
-- there are 3 different payment_method --

-- Q.21 Which customer type occurs most frequently?
SELECT customer_type,
      COUNT(*) AS customer_count
FROM sales
GROUP BY customer_type
ORDER BY customer_count DESC;
-- Member type occurs most frequently  --

-- Q.22.Identify the customer type with the highest purchase frequency.
SELECT
    customer_type,
    COUNT(*) AS purchase_frequency,
    MAX(total) AS highest_total_payment
FROM sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC ;
-- Member has the highest purchase frequency --

-- Q.23 Determine the predominant gender among customers.
SELECT
    gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;
-- Male are the predominant gender --

-- Q.24 Examine the distribution of genders within each branch.
SELECT
    branch,gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY branch,gender
ORDER BY branch,gender;


-- Q.25 Identify the time of day when customers provide the most ratings.
SELECT time_of_day,
     AVG(rating) As Avg_rating
From sales
GROUP BY time_of_day
ORDER BY Avg_rating DESC;
-- In afternoon customer provide the most rating--

-- Q.26 Determine the time of day with the highest customer ratings for each branch.
SELECT time_of_day,branch,
     Max(rating) As max_rating
From sales
GROUP BY time_of_day,branch
ORDER BY max_rating DESC;
-- 

-- Q.27 Identify the day of the week with the highest average ratings.
SELECT day_name,
     AVG(rating) As avg_rating
From sales
GROUP BY day_name
ORDER BY avg_rating DESC;
-- In weekdays like monday friday has highest average rating--

-- Q.28 Determine the day of the week with the highest average ratings for each branch.
SELECT day_name,branch,
     AVG(rating) As avg_rating
From sales
GROUP BY day_name,branch
ORDER BY avg_rating DESC;

-- -- -- -- -- -- -- -- -- --  PRODUCT ANALYSIS -- -- -- -- -- -- -- -- -- -- 
-- The distinct count for product lines is 6 
	-- Food and beverages	  55110.384000000
    -- Electronic accessories 53783.236500000
    -- Sports and travel      52934.007000000
    -- Fashion accessories    51203.250000000
    -- Home and lifestyle     49789.698000000
	-- Health and beauty      48854.379000000
-- -- food and beverages has the highest revenue which is 55110.38--
-- -- Food and beverages has incurred highest value added tax--

-- -- -- -- -- -- -- -- -- -- -- CUSTOMER ANALYSIS -- -- -- -- -- -- -- -- -- --
   -- There are two distinct customer type -- Members and Normal --
   -- Member has the highest purchase frequency --
    -- Member customer type has the highest VAT payment--
    -- fashion and accessories are most frequently associated with female health and beauty are associated with males--
    -- Male are the predominant gender --
	-- In afternoon customer provide the most rating--

-- -- -- -- -- -- -- -- -- -- -- --  SALES ANALYSIS -- -- -- -- -- -- -- -- -- -- 
     -- yangon has the highest revenue recorded --
     -- january months has generated 111205.56 highest revenue --
      -- In january month cost of goods was highest 105910.20 --
      -- For Afternoon we have the highest number of sales --
	  -- branch A Yangon has exceeded average number of products sold with 1839 quantity--