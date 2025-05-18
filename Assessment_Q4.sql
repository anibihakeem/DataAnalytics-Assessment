-- Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
-- Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup)
-- Total transactions
-- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
-- Order by estimated CLV from highest to lowest


-- CTE to summarize customer activity
WITH CTE AS (
    SELECT 
        c.id AS customer_id,

        -- Format full name in Proper Case
        CONCAT(
            UPPER(LEFT(c.first_name, 1)), 
            LOWER(SUBSTRING(c.first_name, 2)), 
            ' ', 
            UPPER(LEFT(c.last_name, 1)), 
            LOWER(SUBSTRING(c.last_name, 2))
        ) AS name,

        -- Count total transactions made by the customer
        COUNT(s.transaction_date) AS total_trans,

        -- Calculate account tenure in months
        TIMESTAMPDIFF(MONTH, c.created_on, NOW()) AS tenure_months,

        -- Calculate average profit per transaction (0.1% of confirmed amount)
        AVG(s.confirmed_amount * 0.001) AS avg_profit

    FROM users_customuser AS c
    JOIN savings_savingsaccount AS s ON c.id = s.owner_id
    GROUP BY c.id
)

-- Estimated CLV calculation for each customer based on the CTE
SELECT 
    customer_id, 
    name,
    tenure_months,
    total_trans,

    -- Estimated CLV formula: (total_transactions / tenure) * 12 * avg_profit_per_transaction
    ROUND(
        (total_trans / NULLIF(tenure_months, 0)) * 12 * avg_profit, 
        2
    ) AS estimated_clv

FROM CTE
ORDER BY estimated_clv DESC;
