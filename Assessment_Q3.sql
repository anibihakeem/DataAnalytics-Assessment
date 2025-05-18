-- Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
-- Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

SELECT 
    p.id AS plan_id,
    p.owner_id,
    -- Determine the plan type
    CASE 
        WHEN p.is_a_fund = 1 THEN 'Investment'
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        ELSE 'Others'
    END AS type_of_trans,

    -- Last transaction date associated with the plan
    MAX(s.transaction_date) AS last_transaction_date,

    -- Days since the last transaction
    DATEDIFF(NOW(), MAX(s.transaction_date)) AS inactivity_days

FROM savings_savingsaccount AS s
-- Join with plans to determine plan details
JOIN plans_plan AS p ON p.id = s.plan_id

-- Filter for only active (non-deleted, non-archived) plans
WHERE p.is_deleted = 0 
  AND p.is_archived = 0

-- Group by plan id and owner id
GROUP BY p.id, p.owner_id

-- Only include plans with inactivity greater than 365 days
HAVING inactivity_days > 365

-- Sort from most inactive to least
ORDER BY inactivity_days DESC;
