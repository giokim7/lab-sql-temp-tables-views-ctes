CREATE VIEW rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer
CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT rs.customer_id, SUM(p.amount) AS total_paid
FROM rental_summary rs
JOIN payment p ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id;

WITH customer_summary AS (
    SELECT rs.first_name, rs.last_name, rs.email, rs.rental_count, tcp.total_paid,
        CASE
            WHEN rs.rental_count > 0 THEN tcp.total_paid / rs.rental_count
            ELSE 0
        END AS average_payment_per_rental
    FROM rental_summary rs
    JOIN temp_customer_payments tcp ON rs.customer_id = tcp.customer_id
)
SELECT first_name, last_name, email, rental_count, total_paid, average_payment_per_rental
FROM customer_summary;

