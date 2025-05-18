-- Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
-- Task: Calculate the average number of transactions per customer per month and categorize them:
-- "High Frequency" (≥10 transactions/month)
-- "Medium Frequency" (3-9 transactions/month)
-- "Low Frequency" (≤2 transactions/month)


-- Count the number of transactions each customer makes per month using a CTE
WITH transactions_per_month AS (
  
    SELECT 
        owner_id,
        MONTH(transaction_date) AS month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, MONTH(transaction_date)
),

-- Calculate the average monthly transactions per customer and classify them based on frequency
avg_trans_per_customer AS (
  
    SELECT 
        owner_id,
        AVG(monthly_txn_count) AS avg_trans_per_month,
        CASE 
            WHEN AVG(monthly_txn_count) >= 10 THEN 'High Frequency'
            WHEN AVG(monthly_txn_count) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM transactions_per_month
    GROUP BY owner_id
)

-- Aggregating results and grouping by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_trans_per_month), 1) AS avg_transactions_per_month
FROM avg_trans_per_customer
GROUP BY frequency_category;
