/* =====================================================
   MARKETING SPEND → SALES IMPACT ANALYSIS (FINAL SQL)
   ===================================================== */
--   CREATE TABLE marketing (
--    campaign_id INT IDENTITY(1,1) PRIMARY KEY,
--    tv FLOAT,
--    radio FLOAT,
--    social_media FLOAT,
--    sales FLOAT
--);
--DROP TABLE marketing;


/* 1. Show the first 10 rows of the dataset */

SELECT TOP 10 * FROM marketing;

/* 2. Find the total spend on TV, Radio, and Social Media */
SELECT 
    ROUND(SUM(tv), 2) AS [Expense on TV],
    ROUND(SUM(radio), 2) AS [Expense on Radio],
    ROUND(SUM(social_media), 2) AS [Expense on Social Media]
FROM marketing;

/* 3. Find the average spend on each channel */
SELECT 
    ROUND(AVG(tv), 2) AS [Average Spend on TV],
    ROUND(AVG(radio), 2) AS [Average Spend on Radio],
    ROUND(AVG(social_media), 2) AS [Average Spend on Social Media]
FROM marketing;

/* 4. Find the maximum and minimum sales recorded */
SELECT 
    ROUND(MAX(sales), 2) AS Max_Sales,
    ROUND(MIN(sales), 2) AS Min_Sales
FROM marketing;

/* 5. Number of records where sales > average sales */
SELECT COUNT(*) AS Count_Above_Avg_Sales
FROM marketing
WHERE sales > (SELECT AVG(sales) FROM marketing);

/* 6. Channel with the highest average spend */
SELECT *
FROM (
    SELECT 'TV' AS Channel, ROUND(AVG(tv),2) AS Avg_Spend FROM marketing
    UNION ALL
    SELECT 'Radio', ROUND(AVG(radio),2) FROM marketing
    UNION ALL
    SELECT 'Social Media', ROUND(AVG(social_media),2) FROM marketing
) AS channel_spend_summary
ORDER BY Avg_Spend DESC;

/* 7. How many campaigns spent more on TV than Radio */
SELECT COUNT(*) AS TV_More_Than_Radio
FROM marketing
WHERE tv > radio;

/* 8. Campaigns where Social Media spend was the highest */
SELECT *
FROM marketing
WHERE social_media > tv AND social_media > radio;

/* 9. Count of rows where Social Media spend is the highest */
SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE 
        WHEN social_media > tv 
         AND social_media > radio 
        THEN 1 ELSE 0 END) AS SocialMedia_Dominant_Rows
FROM marketing;

/* 10. Top 10 most expensive campaigns (total marketing spend) */
SELECT TOP 10 *,
    ROUND((tv + radio + social_media), 2) AS Total_Marketing_Spend
FROM marketing
ORDER BY Total_Marketing_Spend DESC;

/* 11. Avg sales when TV spend is above average */
SELECT ROUND(AVG(sales),2) AS Avg_Sales_When_TV_Above_Avg
FROM marketing
WHERE tv > (SELECT AVG(tv) FROM marketing);

/* 12. Categorize campaigns into High / Low spend */
SELECT *,
    CASE 
        WHEN (tv + radio + social_media) > 
             (SELECT AVG(tv + radio + social_media) FROM marketing)
        THEN 'High Spend'
        ELSE 'Low Spend'
    END AS Spend_Category
FROM marketing;

/* 13. Average sales for High vs Low spend campaigns */
WITH spend_category AS (
    SELECT *,
        CASE 
            WHEN (tv + radio + social_media) > 
                 (SELECT AVG(tv + radio + social_media) FROM marketing)
            THEN 'High Spend'
            ELSE 'Low Spend'
        END AS spend_type
    FROM marketing
)
SELECT 
    spend_type,
    ROUND(AVG(sales),2) AS avg_sales
FROM spend_category
GROUP BY spend_type;

/* 14. Rank campaigns based on sales */
SELECT *,
    ROW_NUMBER() OVER (ORDER BY sales DESC) AS Sales_Rank
FROM marketing;

/* 15. Top 5 most efficient campaigns */
SELECT TOP 5 *,
    ROUND(sales * 1.0 / NULLIF((tv + radio + social_media),0), 4) AS Efficiency
FROM marketing
ORDER BY Efficiency DESC;

/* 16. Total marketing spend per campaign */
SELECT *,
       ROUND((tv + radio + social_media), 2) AS total_spend
FROM marketing;

/* 17. Running total of sales */
--ALTER TABLE marketing
--ADD campaign_id INT IDENTITY(1,1);

SELECT *,
       ROUND(SUM(sales) OVER (ORDER BY campaign_id), 2) AS running_sales
FROM marketing;

/* 18. Rank campaigns by sales (with ties) */
SELECT *,
       RANK() OVER (ORDER BY sales DESC) AS sales_rank
FROM marketing;

/* 19. Difference from average sales */
SELECT *,
       ROUND(sales - AVG(sales) OVER(), 2) AS diff_from_avg_sales
FROM marketing;

/* 20. Sales efficiency for all campaigns */
SELECT *,
       ROUND(sales * 1.0 / NULLIF((tv + radio + social_media),0), 4) AS efficiency
FROM marketing
ORDER BY efficiency DESC;
