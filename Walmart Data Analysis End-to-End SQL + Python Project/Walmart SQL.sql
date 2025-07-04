SELECT TOP (1000) [invoice_id]
      ,[branch]
      ,[city]
      ,[category]
      ,[unit_price]
      ,[quantity]
      ,[date]
      ,[time]
      ,[payment_method]
      ,[rating]
      ,[profit_margin]
      ,[total]
  FROM [walamrt].[dbo].[WAL]


  -- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT COUNT(*) AS Count_Of_Transactions,
payment_method
FROM [walamrt].[dbo].[WAL]
GROUP BY payment_method
ORDER BY Count_Of_Transactions DESC ;




-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
WITH  CTE  AS (
SELECT [branch],
[category],
AVG([rating]) AS avg_rating,
ROW_NUMBER()OVER( PARTITION BY [branch] ORDER BY AVG([rating]) DESC ) AS RN 
FROM [walamrt].[dbo].[WAL] 
GROUP BY [branch],
[category]
)
SELECT [branch],
[category],
avg_rating
FROM CTE 
WHERE RN = 1;


-- Q3: Identify the busiest day for each branch based on the number of transactions
WITH CTE AS (
    SELECT 
        branch,
        DATENAME(WEEKDAY, TRY_CAST([date] AS DATE)) AS day_name,
        COUNT(*) AS no_transactions,
        ROW_NUMBER() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM [walamrt].[dbo].[WAL]
    GROUP BY branch, DATENAME(WEEKDAY, TRY_CAST([date] AS DATE))
)
SELECT branch, day_name, no_transactions
FROM CTE
WHERE rank = 1;




-- Q4: Calculate the total quantity of items sold per payment method
SELECT [payment_method],
SUM([quantity]) AS Sum_Of_Quantity
FROM [walamrt].[dbo].[WAL]
GROUP BY payment_method
ORDER BY Sum_Of_Quantity DESC



-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT [city],
[category],
MAX([rating]) AS MAX,
MIN([rating])AS MIN,
AVG([rating]) AS AVG
FROM [walamrt].[dbo].[WAL]
GROUP BY [city],
[category]


-- Q6: Calculate the total profit for each category
SELECT [category],
ROUND(SUM(unit_price * quantity * profit_margin),0) AS SUM_OF_PROFIT
FROM [walamrt].[dbo].[WAL]
GROUP BY [category]
ORDER BY SUM_OF_PROFIT DESC



-- Q7: Determine the most common payment method for each branch
WITH CTE AS (
SELECT [branch],
[payment_method],
COUNT(*) AS total_trans,
ROW_NUMBER()OVER(PARTITION BY [branch] ORDER BY COUNT(*) DESC) AS RN
FROM [walamrt].[dbo].[WAL]
GROUP BY [branch],
[payment_method]
)
SELECT [branch],
[payment_method],
total_trans
FROM CTE
WHERE RN = 1;



-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT 
	CASE
	WHEN DATEPART(HOUR,Time) < 12 Then 'Morning'
	WHEN DATEPART(HOUR,Time) Between 12 AND 17   Then 'Afternoon'
	Else 'Evening'
	END AS Shift,
COUNT(*) AS num_invoices
FROM [walamrt].[dbo].[WAL]
GROUP BY 
CASE
	WHEN DATEPART(HOUR,Time) < 12 Then 'Morning'
	WHEN DATEPART(HOUR,Time) Between 12 AND 17   Then 'Afternoon'
	Else 'Evening'
END
ORDER BY num_invoices DESC;




-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM [walamrt].[dbo].[WAL]
    WHERE YEAR(TRY_CAST([date] AS DATE)) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM [walamrt].[dbo].[WAL]
    WHERE YEAR(TRY_CAST([date] AS DATE)) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) * 100.0 / r2022.revenue), 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
