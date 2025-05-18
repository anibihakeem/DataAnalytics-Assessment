# DataAnalytics-Assessment
This repository contains SQL-based solutions to a data analytics assessment questions. The focus was on querying and transforming customer and transaction data to generate insights for operational, financial, and marketing teams.

## Overview

The database includes:
- **users_customuser:** customer demographic and contact information
- **savings_savingsaccount:** records of deposit transactions
- **plans_plan:** records of plans created by customers
- **withdrawals_withdrawal:**  records of withdrawal transactions

## Questions & Approaches

### 1. High-Value Customers with Multiple Products

Identify customers who have both a savings plan and an investment plan and rank them by their total deposits. This helps the business understand cross-sell opportunities and prioritize high-value clients.

**Approach**:
- Performed ` INNER JOINs` across `users_customuser`, `plans_plan`, and `savings_savingsaccount` using `owner_id` and `plan_id`.
- Used `CASE` statements inside `SUM()` to separately count:
  - `is_regular_savings = 1` → for savings plans
  - `is_a_fund = 1` → for investment plans
- Aggregated the total deposit amount from `savings_savingsaccount.confirmed_amount` (in kobo), converted to Naira by dividing by 100 (`/100`), and formatted using `FORMAT(...)` and `CONCAT('₦', ...)`.
- Filtered with `HAVING` to keep only users with both plan types.
- Sorted results by deposit value in descending order to highlight top customers.

---

### 2. Transaction Frequency Analysis

Categorize customers based on their average monthly transaction activity into:
- High Frequency (≥ 10/month)
- Medium Frequency (3–9/month)
- Low Frequency (≤ 2/month)

**Approach**:
- Created a Common Table Expression (CTE) to count the number of transactions per customer per month using `MONTH(transaction_date)`.
- In a second CTE, calculated the `AVG` of those monthly transaction counts per user to derive `avg_trans_per_month`.
- Classified users into frequency categories using a `CASE` statement.
- Aggregated and counted how many users fell into each category and their average transaction volume.

---

### 3. Account Inactivity Alert

Identify all *active* plans (savings or investment) that have had no deposit activity in the last 365 days. This is useful for retention alerts or operational interventions.

**Approach**:
- Filtered `plans_plan` to include only non-deleted and non-archived plans (`is_deleted = 0 AND is_archived = 0`).
- Joined with `savings_savingsaccount` on `plan_id` to get deposit records.
- Used `MAX(transaction_date)` per plan to determine the most recent inflow.
- Calculated inactivity using `DATEDIFF(NOW(), MAX(transaction_date))`.
- Used `HAVING` to filter for plans inactive for more than 365 days.
- Labeled each plan by type (Savings or Investment) using a `CASE` expression.

---

### 4. Customer Lifetime Value (CLV) Estimation

Estimate the CLV for each customer using a simplified model:

**Approach**:
- Created a CTE that:
  - Counts `total_trans` per customer
  - Computed tenure in months using `TIMESTAMPDIFF(MONTH, created_on, NOW())`
  - Calculated `avg_profit` as 0.1% of each transaction (`confirmed_amount * 0.001`)
- In the final query, applied the CLV formula, using `NULLIF(tenure_months, 0)` to prevent divide-by-zero errors.
- Rounded the CLV to two decimal places.
- Sorted customers by estimated CLV descending to identify the most valuable ones.

---

## Challenges & Resolutions

### 1. Calculating Date Differences in Months
- `DATEDIFF()` gives days, but months were needed for tenure and frequency.
- Used `TIMESTAMPDIFF(MONTH, start_date, end_date)` for precise results.

### 2. Currency Formatting in MySQL
- MySQL lacks built-in currency formatting (`FORMAT(..., 'C')` like SQL Server.
- Used `CONCAT('₦', FORMAT(amount / 100, 2))` for a presentable currency display.

### 3. Formatting Names as Proper Case
- Names appeared in inconsistent formats.
- Used `UPPER(LEFT(...))` and `LOWER(SUBSTRING(...))` to produce readable names like `John Doe`.

---


