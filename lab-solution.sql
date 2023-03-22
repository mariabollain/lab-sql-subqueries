use sakila;

# 1 How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory_id) AS num_copies
FROM inventory
WHERE film_id = (SELECT film_id 
FROM film 
WHERE title = "Hunchback Impossible");

# 2 List all films whose length is longer than the average of all the films.

SELECT film_id, title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length ASC;

# 3 Use subqueries to display all actors who appear in the film Alone Trip.

SELECT actor_id, first_name, last_name 
FROM actor
WHERE actor_id IN (SELECT actor_id 
FROM film_actor 
WHERE film_id = (SELECT film_id 
FROM film 
WHERE title = "Alone Trip"));

# 4 Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT film_id, title 
FROM film 
WHERE film_id IN (SELECT film_id
FROM film_category 
WHERE category_id = (SELECT category_id
FROM category 
WHERE name = "Family"));

# 5 Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

## using subqueries

SELECT CONCAT(first_name, " ",  last_name) AS name, email 
FROM customer 
WHERE address_id IN (SELECT address_id FROM address 
WHERE city_id IN (SELECT city_id FROM city 
WHERE country_id = (SELECT country_id FROM country 
WHERE country = "Canada")));

## using joins

SELECT CONCAT(CU.first_name, " ",  CU.last_name) AS name, CU.email 
FROM customer CU
JOIN address A ON CU.address_id = A.address_id
JOIN city CI ON A.city_id = CI.city_id
JOIN country CO ON CI.country_id = CO.country_id
WHERE CO.country = "Canada";

# 6 Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

## most prolific actor

SELECT actor_id, COUNT(film_id) AS num_films
FROM film_actor 
GROUP BY actor_id
HAVING num_films = (SELECT MAX(films) 
FROM (SELECT actor_id, COUNT(film_id) AS films
FROM film_actor
GROUP BY actor_id) AS actor_films);

# what's his/her name?
SELECT first_name, last_name 
FROM actor 
WHERE actor_id = (SELECT actor_id FROM film_actor 
GROUP BY actor_id
HAVING COUNT(film_id) = (SELECT MAX(films) 
FROM (SELECT actor_id, COUNT(film_id) AS films
FROM film_actor
GROUP BY actor_id) AS actor_films));

## films that she starred

SELECT film_id, title
FROM film 
WHERE film_id IN (SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id FROM film_actor 
GROUP BY actor_id
HAVING COUNT(film_id) = (SELECT MAX(films) 
FROM (SELECT actor_id, COUNT(film_id) AS films
FROM film_actor
GROUP BY actor_id) AS actor_films)));

# 7 Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

## who is the most profitable customer?

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = (SELECT customer_id FROM payment 
GROUP BY customer_id
HAVING SUM(amount) = (SELECT MAX(payments) 
FROM (SELECT customer_id, SUM(amount) as payments 
FROM payment
GROUP BY customer_id) AS total_payments));

## films rented

SELECT film_id, title
FROM film
WHERE film_id IN (SELECT film_id FROM inventory
WHERE inventory_id IN (SELECT inventory_id FROM rental
WHERE customer_id = (SELECT customer_id FROM payment 
GROUP BY customer_id
HAVING SUM(amount) = (SELECT MAX(payments) 
FROM (SELECT customer_id, SUM(amount) as payments 
FROM payment
GROUP BY customer_id) AS total_payments)))); 

# 8 Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

## average of the total amount

SELECT AVG(total_amount) 
FROM (SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id) AS client_amount;

# clients that spent more than average

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id 
HAVING total_amount_spent > (SELECT AVG(total_amount) 
FROM (SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id) AS client_amount)
ORDER BY total_amount_spent ASC;