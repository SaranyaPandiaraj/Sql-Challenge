-- Fetching the Databse

USE sakila;


-- 1a. Display the first and last names of all actors from the table `actor`.

DESCRIBE actor;

SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT concat(upper(first_name)," ",upper(last_name)) AS "Actor Name"
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name="Joe";


-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT *
FROM actor
WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT *
FROM actor
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

DESCRIBE country;

SELECT country_id, country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
-- A BLOB, or Binary Large Object, is an SQL object data type

ALTER TABLE actor 
ADD COLUMN description BLOB;

SELECT * 
FROM actor LIMIT 10;

DESCRIBE actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor 
DROP COLUMN description;

SELECT * 
FROM actor LIMIT 10;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,count(last_name) AS "Count of Actors"
FROM actor
WHERE last_name is not null
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name,count(last_name) AS "Count of Actors"
FROM actor
WHERE last_name is not null
GROUP BY last_name
HAVING count(last_name) >=2;


-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SELECT * 
FROM actor 
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";

--- Update Query ---

UPDATE actor
SET first_name="HARPO"
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";

SELECT * 
FROM actor 
WHERE first_name="HARPO" AND last_name="WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

--- Update Query ---

UPDATE actor
SET first_name="GROUCHO"
WHERE first_name="HARPO" AND last_name="WILLIAMS";

SELECT * 
FROM actor 
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

  -- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
  
  SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

DESCRIBE STAFF;
DESCRIBE ADDRESS;

SELECT * 
FROM STAFF LIMIT 10;

SELECT * 
FROM ADDRESS LIMIT 10;

-- Join ON
SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a
	ON s.address_id = a.address_id;

-- Join USING
SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a
using(address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

DESCRIBE payment;

SELECT * 
FROM payment;

-- Total Amount by Each Staff
SELECT s.first_name, s.last_name, sum(p.amount)
FROM staff s
JOIN payment p
	ON s.staff_id = p.staff_id
WHERE EXTRACT(MONTH FROM payment_date) = 8 AND EXTRACT(YEAR FROM payment_date) = 2005
GROUP BY 1,2;

-- Total Amount 
SELECT sum(p.amount) as "Total Amount"
FROM staff s
JOIN payment p
	ON s.staff_id = p.staff_id
WHERE EXTRACT(MONTH FROM payment_date) = 8 AND EXTRACT(YEAR FROM payment_date) = 2005;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

DESCRIBE film_Actor;
DESCRIBE film;

SELECT * FROM  film_Actor LIMIT 10;
SELECT * FROM  film LIMIT 10;

SELECT f.title AS "Film Title", count(fa.actor_id) AS "Number Of Actors"
FROM film f
INNER JOIN film_actor fa
	ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

DESCRIBE inventory;

SELECT f.title, count(f.title) as "Number of Copies"
FROM film f 
INNER JOIN inventory i
	on f.film_id = i.film_id
WHERE f.title='Hunchback Impossible'
GROUP BY 1;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

 -- ![Total amount paid](Images/total_payment.png)
  
  DESCRIBE payment;
  DESCRIBE customer;
  
  SELECT c.first_name, c.last_name, sum(amount) as "Total Amount Paid"
  FROM payment p
  JOIN customer c
	ON p.customer_id = c.customer_id
  GROUP BY c.first_name, c.last_name
  ORDER BY c.last_name;
  
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film 
WHERE language_id IN 
		( 
          SELECT language_id 
          FROM language 
          WHERE name = 'English'
		)
AND title like 'K%' 
OR title like 'Q%';


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
       (
		 SELECT actor_id 
         FROM film_actor
         WHERE film_id IN
				(
                   SELECT film_id
                   FROM film 
                   WHERE title = 'Alone Trip'
				) 
		);
        

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT cu.first_name, cu.last_name, cu.email, co.country
FROM customer cu
INNER JOIN address ad
	ON cu.address_id = ad.address_id
INNER JOIN city ci
	ON ad.city_id = ci.city_id
INNER JOIN country co
	ON ci.country_id = co.country_id
WHERE co.country ='Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT fi.title, cat.name
FROM film fi
INNER JOIN film_category fc
	ON fi.film_id = fc.film_id
INNER JOIN category cat
	ON fc.category_id = cat.category_id
WHERE cat.name = 'Family' ;

-- 7e. Display the most frequently rented movies in descending order.

SELECT fi.title, Count(*) as "No. Of Times Rented"
FROM film fi
INNER JOIN inventory inv
	ON fi.film_id = inv.film_id
INNER JOIN rental re
	ON inv.inventory_id = re.inventory_id
Group by 1
ORDER BY 2 desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT sto.store_id, CONCAT("$", FORMAT(SUM(pay.amount),2)) as "Profit"
FROM store sto
INNER JOIN inventory inv
	ON sto.store_id = inv.store_id
INNER JOIN rental ren
	ON inv.inventory_id = ren.inventory_id
INNER JOIN payment pay
	ON ren.rental_id = pay.rental_id
GROUP by 1;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT st.store_id, ci.city, co.country
FROM store st
INNER JOIN address ad
	ON ad.address_id = ad.address_id
INNER JOIN city ci
	ON ad.city_id and ci.city_id
INNER JOIN country co
	ON ci.country_id and co.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (----Hint----: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT ca.name as "Genre" , CONCAT('$', FORMAT(SUM(pay.amount), 2)) AS "Gross Revenue"
FROM category ca
INNER JOIN film_category fic
	ON ca.category_id = fic.category_id
INNER JOIN inventory inv
	ON fic.film_id = inv.film_id
INNER JOIN rental rent
	ON inv.inventory_id = rent.inventory_id
INNER JOIN payment pay
	ON rent.rental_id = pay.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_Five_Genres AS
	SELECT ca.name as "Genre" , CONCAT('$', FORMAT(SUM(pay.amount), 2)) AS "Gross Revenue"
	FROM category ca
	INNER JOIN film_category fic
		ON ca.category_id = fic.category_id
	INNER JOIN inventory inv
		ON fic.film_id = inv.film_id
	INNER JOIN rental rent
		ON inv.inventory_id = rent.inventory_id
	INNER JOIN payment pay
		ON rent.rental_id = pay.rental_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5;


-- 8b. How would you display the view that you created in 8a?

SELECT * 
FROM Top_Five_Genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW Top_Five_Genres;