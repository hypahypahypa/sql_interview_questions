--Why is this query not returning the expected results?

--We have 1000 total rows in the orders table:

SELECT * FROM orders;
	-- 1000 rows in set (0.05 sec)
--And 23 of those orders are from the user with customer_id = 45:

SELECT * FROM orders WHERE customer_id = 45;
	-- 23 rows in set (0.10 sec)
--Yet, when we SELECT the number of orders that are not from customer_id = 45, we only get 973 results:

--SELECT * FROM orders WHERE customer_id <> 45;
	-- 973 rows in set (0.11 sec)
--973 + 23 = 996. But shouldn't the number of orders with customer_id equal to 45 plus the number of orders with customer_id not equal to 45 equal 1000? Why is this query not returning the expected results?

/*
The answer: this data set most likely contains order values with a NULL customer_id. 
When using the SELECT clause with conditions, rows with the NULL value will not match against either the = or the <> operator.

Our second query above could be modified as follows to produce the expected results:

SELECT * FROM orders WHERE (customer_id <> 45 OR customer_id IS NULL);
	-- 977 rows in set (0.11 sec)
*/