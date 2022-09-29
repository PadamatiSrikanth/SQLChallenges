/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
		SELECT 
			customer_id,
			SUM(price)
		FROM sales s
		JOIN menu m USING(product_id)
		GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
		SELECT 
			customer_id,
			COUNT(DISTINCT order_date)
		FROM sales
		GROUP BY customer_id;
-- 3. What was the first item from the menu purchased by each customer?
		SELECT
			customer_id,
			product_name
		FROM
		(
		SELECT
			product_id,
			customer_id,
			order_date,
			product_name,
			RANK() OVER(PARTITION BY customer_id ORDER BY(order_date)) AS rank_prod
		FROM sales s
		JOIN menu m USING(product_id)
		) prod_rank
		WHERE rank_prod = 1
		GROUP BY customer_id,product_name;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
		SELECT 
			product_name,
			COUNT(product_id) AS most_purchased
		FROM sales s
		JOIN menu m USING(product_id)
		GROUP BY product_name
		ORDER BY most_purchased DESC
		LIMIT 1;
-- 5. Which item was the most popular for each customer?
		SELECT
		customer_id,
		product_name
	FROM 
	(
	SELECT
		COUNT(product_id) AS most_purchased,
		customer_id,
		product_name,
		RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS prod_rank
	FROM sales s
	JOIN menu m USING(product_id)
	GROUP BY customer_id,product_name
	) prod_tbl
	WHERE prod_rank = 1;
-- 6. Which item was purchased first by the customer after they became a member?
		SELECT
			customer_id,
			product_name
		FROM 
		(
		SELECT 
			customer_id,
			product_id,
			RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as prod_order_rank
		FROM sales s
		JOIN members m USING(customer_id)
		WHERE order_date >= join_date 
		) pdk
		JOIN menu USING(product_id)
		WHERE prod_order_rank = 1
		ORDER BY customer_id 
		LIMIT 2;
-- 7. Which item was purchased just before the customer became a member?
		SELECT 
			customer_id,
			product_name
		FROM
			(
			SELECT 
				customer_id,
				product_id,
				order_date,
				join_date,
				RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS prod_rank
			FROM sales s
			JOIN members m USING(customer_id)
			WHERE order_date < join_date
			) prd
			JOIN menu USING(product_id)
			WHERE prod_rank = 1
			ORDER BY customer_id;
-- 8. What is the total items and amount spent for each member before they became a member?
		SELECT 
			s.customer_id,
			COUNT(*) total_items,
			SUM(price) amount_spent
		FROM sales s
		JOIN menu m ON s.product_id = m.product_id
		JOIN members me ON s.customer_id = me.customer_id
		WHERE order_date < join_date
		GROUP BY customer_id
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
		SELECT 
 		customer_id,
		--  s.product_id,
		--  product_name,
		--  price,
		--  order_date,
		SUM(IF(m.product_name = 'sushi', (price * 20),(price * 10))) points
		FROM sales s
		JOIN menu m ON s.product_id = m.product_id
		GROUP BY customer_id	
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

