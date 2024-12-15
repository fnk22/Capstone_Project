/*                                             CAPSTONE PROJECT

  

---> Database: Chinook

---> About Chinook Database: 
The Chinook Database is a relational database designed to mimic the structure and operations of a digital media store, 
focusing on data related to music, artists, albums, genres, and customer transactions. 
It provides a comprehensive and realistic dataset, ideal for learning and practicing SQL queries, 
database design, and analytical tasks. The database includes tables for employees, customers,
sales invoices, tracks, playlists, and media formats, allowing users to simulate various real-world business scenarios.  
 

     QUERIES  

*/  

-- 1) Features of the products.
SELECT t.name AS track_name, a.title AS album, art.name AS artist, g.name AS genre,t.composer, mt.name AS media_type, t.milliseconds, t.bytes 
FROM track t 
JOIN album a ON a.album_id = t.album_id
JOIN artist art ON art.artist_id = a.artist_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN mediatype mt ON mt.media_type_id = t.media_type_id;

-- 2) Number of products in categories.
SELECT g.name AS genre, COUNT(t.genre_id) AS track_number 
FROM track t
JOIN genre g ON g.genre_id = t.genre_id 
GROUP BY g.name
ORDER BY COUNT(t.genre_id) DESC;

-- 4) Number of sales by categories.
SELECT g.name AS genre, COUNT(il.invoice_line_id) AS total_sale
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
WHERE g.name LIKE '%' 
GROUP BY g.name
ORDER BY COUNT(il.invoice_line_id) DESC;

-- 5) Group the top five selling categories as BESTSELLER.
SELECT g.name AS genre, COUNT(il.invoice_line_id) AS number_of_sales,
    CASE 
        WHEN RANK() OVER (ORDER BY COUNT(il.invoice_line_id) DESC) <= 5 THEN 'BESTSELLER'
        ELSE 'OTHER'
    END AS category_group
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY COUNT(il.invoice_line_id) DESC
LIMIT 5;

-- 6) Songs with the longest duration.
SELECT name AS track_name, (milliseconds / 60000) AS minutes, ((milliseconds % 60000) / 1000) AS seconds
FROM track
ORDER BY milliseconds DESC
LIMIT 10;

-- 7) Sales quantity and sales total of all tracks.
SELECT t.name AS track_name, t.track_id, COUNT(il.quantity) AS number_of_sales, SUM(il.unit_price) AS total_track_sales 
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.name, t.track_id
ORDER BY COUNT(il.quantity) DESC;

-- 8) Average prices of products with multiple sales.
SELECT t.Name AS track_name, COUNT(il.quantity) AS number_of_sales, AVG(il.unit_price) AS avg_price
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY t.name
ORDER BY COUNT(il.quantity) DESC;

-- 9) Categorization of sales.
SELECT t.track_id, t.name AS track_name, SUM(il.unit_price) AS total_track_sales, 
      CASE 
	      WHEN SUM(il.unit_price) > 3 THEN 'HIGH'
		  WHEN SUM(il.unit_price) <= 2 THEN 'MEDIUM'
		  WHEN SUM(il.unit_price) < 1 THEN 'LOW'
	  END AS sales_category	  
FROM track t
JOIN invoice_line il ON il.track_id = t.track_id 
GROUP BY t.track_id, t.name
ORDER BY SUM(il.unit_price) DESC;

-- 10) Top 10 best-selling products and their album, artist.
SELECT art.name AS artist,a.title AS album_name, t.name AS track_name, SUM(il.unit_price * il.quantity) AS total_track_sales  
FROM track t
JOIN invoice_line il ON il.track_id = t.track_id
JOIN album a ON a.album_id = t.album_id
JOIN artist art ON art.artist_id = a.artist_id 
GROUP BY t.track_id, art.artist_id, a.album_id, art.name, a.title, t.name
ORDER BY SUM(il.unit_price * il.quantity) DESC
LIMIT 10;

-- 11) Information about sales made by customers. 
SELECT c.customer_id, c.first_name, c.last_name , SUM(i.total) AS total
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY SUM(i.total) DESC;

-- 12) Top 10 customers with the most sales.
SELECT c.customer_id,c.first_name || ' ' || c.last_name AS full_name,c.city, c.country, SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.country
ORDER BY SUM(il.unit_price * il.quantity) DESC
LIMIT 10;

-- 13) Segmentation according to customer behavior.
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(il.unit_price * il.quantity) AS total_spent,
    CASE 
        WHEN SUM(il.unit_price * il.quantity) >= 40 THEN 'Premium'
        ELSE 'Standard'
    END AS customer_segment
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY SUM(il.unit_price * il.quantity) DESC;

-- 14) Customer density by country and city.
SELECT c.first_name AS first_name, c.last_name AS last_name, c.city AS city, c.country AS country,
    COUNT(*) OVER (PARTITION BY c.country) AS customer_count_per_country,
    COUNT(*) OVER (PARTITION BY c.city) AS customer_count_per_city
FROM customer c
ORDER BY COUNT(*) OVER (PARTITION BY c.country) DESC, COUNT(*) OVER (PARTITION BY c.city) DESC;

-- 15) Top 5 countries and cities with the highest sales.
SELECT c.country, c.city, SUM(il.unit_price * il.quantity) AS total_sales
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY c.country, c.city
ORDER BY SUM(il.unit_price * il.quantity) DESC
LIMIT 5;

-- 16) Daily, monthly, yearly sales analysis.

--Day
SELECT 
    EXTRACT(DOW FROM i.invoice_date) AS day_of_week, 
    TO_CHAR(i.invoice_date, 'Day') AS day_name,
    SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY day_of_week, day_name
ORDER BY SUM(il.unit_price * il.quantity) DESC;

--Month
SELECT 
    EXTRACT(MONTH FROM i.invoice_date) AS month, 
	TO_CHAR(i.invoice_date, 'Month') AS month_name,
	SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY month, month_name
ORDER BY SUM(il.unit_price * il.quantity) DESC;

--Year
SELECT 
    EXTRACT(YEAR FROM i.invoice_date) AS year,
	SUM(il.unit_price * il.quantity) AS total_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id	
GROUP BY EXTRACT(YEAR FROM i.invoice_date)
ORDER BY total_sales DESC;

-- 17) Profit analysis.
SELECT i.invoice_date, SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.invoice_date
ORDER BY i.invoice_date;

-- 18) Change in album sales over time.
SELECT TO_CHAR(i.invoice_date, 'YYYY-MM') AS month_year, a.title AS album_title, COUNT(il.invoice_line_id) AS sales_count
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
GROUP BY TO_CHAR(i.invoice_date, 'YYYY-MM'), a.title
ORDER BY month_year;

-- 19) Employee information and length of experience in the company.
SELECT first_name, last_name, city, country,
    DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS work_duration
FROM employee 
ORDER BY DATE_PART('year', AGE(CURRENT_DATE, hire_date)) DESC;

--20) Sale performance of employees.
SELECT e.first_name, e.last_name, SUM(il.unit_price * il.quantity) AS total_sales
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY e.first_name, e.last_name
ORDER BY SUM(il.unit_price * il.quantity) DESC;









---> Preapared by Fatma Nur Karaman :)

