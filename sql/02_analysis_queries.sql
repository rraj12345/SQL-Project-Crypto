-- Cryptocurrency Transactions & Market Analysis
-- Run after CRYPTO.sql and sql/01_members_schema.sql.

-- 1. Transaction count and quantity by asset and transaction type.
SELECT ticker,
       txn_type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(quantity), 4) AS total_quantity
FROM transactions
GROUP BY ticker, txn_type
ORDER BY ticker, txn_type;

-- 2. Buy/sell activity by transaction date.
SELECT txn_date,
       ticker,
       txn_type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(quantity), 4) AS total_quantity
FROM transactions
GROUP BY txn_date, ticker, txn_type
ORDER BY txn_date, ticker, txn_type;

-- 3. Member activity by region.
SELECT m.region,
       COUNT(t.txn_id) AS transaction_count,
       COUNT(DISTINCT m.member_id) AS active_members
FROM members AS m
JOIN transactions AS t
  ON t.member_id = m.member_id
GROUP BY m.region
ORDER BY transaction_count DESC;

-- 4. Most active members.
SELECT m.member_id,
       m.first_name,
       m.region,
       COUNT(t.txn_id) AS transaction_count,
       ROUND(SUM(t.quantity), 4) AS total_quantity
FROM members AS m
JOIN transactions AS t
  ON t.member_id = m.member_id
GROUP BY m.member_id, m.first_name, m.region
ORDER BY transaction_count DESC, total_quantity DESC
LIMIT 10;

-- 5. Daily price movement using LAG().
WITH price_history AS (
    SELECT ticker,
           market_date,
           price,
           LAG(price) OVER (
               PARTITION BY ticker
               ORDER BY market_date
           ) AS previous_price
    FROM prices
)
SELECT ticker,
       market_date,
       price,
       previous_price,
       ROUND(
           (price - previous_price) / NULLIF(previous_price, 0) * 100,
           2
       ) AS calculated_change_pct
FROM price_history
ORDER BY ticker, market_date;

-- 6. Daily high-low range by asset.
SELECT ticker,
       market_date,
       high,
       low,
       ROUND(high - low, 2) AS daily_price_range
FROM prices
ORDER BY ticker, market_date;

-- 7. Estimated transaction notional using the same day's recorded market price.
-- This is a proxy calculation, not an execution-price or fee reconciliation.
SELECT t.ticker,
       t.txn_type,
       COUNT(*) AS matched_transactions,
       ROUND(SUM(t.quantity * p.price), 2) AS estimated_notional_value
FROM transactions AS t
JOIN prices AS p
  ON p.ticker = t.ticker
 AND p.market_date = t.txn_date
GROUP BY t.ticker, t.txn_type
ORDER BY t.ticker, t.txn_type;

-- 8. Transactions that do not have a matching member record.
SELECT t.*
FROM transactions AS t
LEFT JOIN members AS m
  ON m.member_id = t.member_id
WHERE m.member_id IS NULL;

-- 9. Transactions without a same-day price record.
SELECT t.*
FROM transactions AS t
LEFT JOIN prices AS p
  ON p.ticker = t.ticker
 AND p.market_date = t.txn_date
WHERE p.ticker IS NULL;
