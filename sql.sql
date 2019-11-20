-- For each country calculate the total spending for each customer, and 
-- include a column (called 'difference') showing how much more each customer 
-- spent compared to the next highest spender in that country. 
-- For the 'difference' column, fill any nulls with zero.
-- ROUND your all of your results to the next penny.

-- hints: 
-- keywords to google - lead, lag, coalesce
-- If rounding isn't working: 
-- https://stackoverflow.com/questions/13113096/how-to-round-an-average-to-2-decimal-places-in-postgresql/20934099


WITH customer_total_spending AS(
SELECT
    customer_id,
    ship_country,
    SUM(unit_price * quantity) AS total_spending
FROM orders
JOIN order_details USING(order_id)
GROUP BY customer_id, ship_country
), ranked_total_spending AS(
    SELECT
        *,
        RANK() OVER(PARTITION BY ship_country ORDER BY total_spending DESC) AS rank,
        LEAD(total_spending, 1) OVER(PARTITION BY ship_country ORDER BY ship_country) as next_highest
    FROM customer_total_spending
    ), data_with_difference AS( 
        SELECT
            *,
            total_spending - next_highest AS difference
        FROM ranked_total_spending
        )
        SELECT
            *,
            CASE
                WHEN difference IS NULL THEN 0
                ELSE ROUND(cast(difference as numeric), 2)
            END AS rounded_difference
        FROM data_with_difference;

--shorter version

WITH customer_total_spending AS(
SELECT
    customer_id,
    ship_country,
    SUM(unit_price * quantity) AS total_spending
FROM orders
JOIN order_details USING(order_id)
GROUP BY customer_id, ship_country
), ranked_total_spending AS(
    SELECT
        *,
        RANK() OVER(PARTITION BY ship_country ORDER BY total_spending DESC) AS rank,
        LEAD(total_spending, 1) OVER(PARTITION BY ship_country ORDER BY ship_country) as next_highest
    FROM customer_total_spending
    )
    SELECT
        *,
        CASE
            WHEN next_highest IS NULL THEN 0
            ELSE ROUND(cast(total_spending - next_highest as numeric), 2)
        END AS rounded_difference
    FROM ranked_total_spending;