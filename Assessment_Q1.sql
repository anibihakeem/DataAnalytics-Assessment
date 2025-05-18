-- High-Value Customers with Multiple Products
-- Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
-- Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.


SELECT 
    c.id AS owner_id,
    -- Format full name as Proper Case
    CONCAT(
        UPPER(LEFT(c.first_name, 1)), 
        LOWER(SUBSTRING(c.first_name, 2)), 
        ' ', 
        UPPER(LEFT(c.last_name, 1)), 
        LOWER(SUBSTRING(c.last_name, 2))
    ) AS name,
    -- Count number of savings plans
    FORMAT(SUM(CASE 
				WHEN p.is_regular_savings = 1 THEN 1 
				ELSE 0 
			END),0) AS savings_count,
    -- Count number of investment plans
    FORMAT(SUM(CASE 
				WHEN p.is_a_fund = 1 THEN 1 
				ELSE 0 
			END),0) AS investment_count,
    -- Total deposit amount (in Naira and Kobo), formatted with ₦ symbol and commas
    CONCAT('₦', FORMAT(SUM(s.amount) / 100, 2),'k') AS total_deposits

FROM users_customuser AS c
-- Join to plans to get plan types (savings or investment)
INNER JOIN plans_plan AS p
    ON p.owner_id = c.id
-- Join to savings to get deposit transaction amounts
INNER JOIN savings_savingsaccount AS s
    ON s.plan_id = p.id

-- Group by customer ID and their name
GROUP BY c.id, name

-- Only include customers who have at least one savings and investment plans
HAVING investment_count >= 1 
   AND savings_count >= 1
   
-- Sort by highest total deposits in Naira
ORDER BY SUM(s.amount) / 100 DESC;
