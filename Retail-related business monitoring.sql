#Manage a chain of Movie Rental Stores - A typical retail-related business case
#key metrics: Production information (film here), sales information, inventory information
#customer behavior information

#Explore data firstly 
select * from actor limit 100;
select * from film_actor limit 100;
select * from film limit 100;
select * from language limit 100;
select * from film_category limit 100;
select * from category limit 100;

#Search largest rental_rate for each rating 
select rating, max(rental_rate) from film group by 1;

#Count the number of films in each rating category 
select rating, count(distinct film_id) from film group by rating;

SELECT
CASE WHEN length > 0 and length < 60 THEN 'short'			
	 WHEN length >= 60 and length < 120 THEN 'standard'            
	 WHEN length >=120  THEN 'long'           
	 ELSE 'others'            
                         END as film_length, 
                         count(film_id) from film            
                         group by 1
                         order by 2;

#count distinct actors' last names 
select count(distinct last_name) from actor;

select last_name, 
count(*) as num from actor group by last_name 
having count(*) = 1;

select last_name, 
count(*) as num from actor group by last_name 
having count(*) > 1;

#Count the number of actors in each film, order the result by the number of actors with descending order
select film_id, 
count(distinct actor_id) as num_of_actor 
from film_actor group by film_id order by num_of_actor desc;

#find how many films each actor played in
select actor_id, 
count(distinct film_id) as num_of_film 
from film_actor group by actor_id order by num_of_film desc;

select f.*,l.name as languge_name
from film as f
left join
language as l
on f.language_id=l.language_id;

select fa.*, a.first_name,a.last_name, 
f.title  from 
film_actor as fa,
actor as a,
film as f
where fa.actor_id = a.actor_id
and fa.film_id=f.film_id;

select f.*, c.name as category_name 
from
film as f
left join
film_category as fc
on f.film_id=fc.film_id
left join
category as c
on fc.category_id=c.category_id;

select * from film where rating in ('G','PG-13','PG')
UNION
select * from film where rental_rate > 2;

select * from film where 
rating in ('G','PG-13','PG')
or 
rental_rate > 2;

#obtain the sales volume happened from 2005-05 to 2005-08
select count(rental_id) as volume from rental
where rental_date 
between '2005-05-01 00:00:00' and '2005-08-31 23:59:59';

#see the rental volume by month 
select 
substring(rental_date, 1,7) as rental_month, 
count(rental_Id) as volume from rental
where rental_date between '2005-05-01 00:00:00' and '2005-08-31 23:59:59' group by 1;

#rank the staff by total rental volumes for all time period 
select s.first_name, 
s.last_name, 
count(r.rental_Id) as volume from 
rental as r
left join
staff as s
on r.staff_id=s.staff_id
group by 1,2
order by volume desc;


#create the current inventory level report for each film in each store 
select f.title as film_name, i.film_id, i.store_id, count(*)
from
inventory as i
left join
film as f on i.film_id=f.film_id
group by 1,2,3;

#modifying inventory report byadding the category for each film upon the manager's request 
select f.title as film_name, 
f.film_id,  -- be careful about which film_id you are using. if you select film_id from inventory table, you will get NULL value
c.name as category, 
i.store_id, 
count(i.film_id) as num_of_stock -- be careful which column you want to count to get the inventory number. if you count(*), NULL will be counted as 1
from
film as f 
left join inventory as i
on i.film_id=f.film_id
left join
film_category as fc on f.film_id=fc.film_id
left join
category as c on fc.category_id=c.category_id
group by 1,2,3,4;


create table inventory_rep as
select f.title as film_name, 
f.film_id, 
c.name as category, 
i.store_id, 
count(i.film_id) as num_of_stock 
from
film as f 
left join inventory as i
on i.film_id=f.film_id
left join
film_category as fc on f.film_id=fc.film_id
left join
category as c on fc.category_id=c.category_id
group by 1,2,3,4;


drop table inventory_rep;
create table inventory_rep as
select f.title as film_name, 
f.film_id, 
c.name as category, 
sum(case when i.store_id =1 then 1 else 0 end) as num_of_stock_in_store1,
sum(case when i.store_id =2 then 1 else 0 end) as num_of_stock_in_store2
from
film as f 
left join inventory as i
on i.film_id=f.film_id
left join
film_category as fc on f.film_id=fc.film_id
left join
category as c on fc.category_id=c.category_id
group by 1,2,3;


select * from inventory_rep;


select film_id from inventory_rep where num_of_stock = 0;


#find how many revenues made from 2005-05 to 2005-08 by month 
select substring(payment_date, 1,7) as payment_month, sum(amount) as revenue from payment
where payment_date between '2005-05-01 00:00:00' and '2005-08-31 23:59:59' group by 1;

#find how many revenues made from 2005-05 to 2005-08 by each store
select store_id, sum(amount) as revenue from 
payment p
join
staff s
on p.staff_id=s.staff_id
where payment_date between '2005-05-01 00:00:00' and '2005-05-31 23:59:59' group by 1;


#help the store to identify unpopular movies so that the movie rental store can offer unpopular 
#movies for sale to free up shelf space for newer ones. 
select f.film_id, f.title, c.name as category, count(distinct rental_id) as times_rented 
from 
rental r
left join inventory i
on i.inventory_id=r.inventory_id
left join film f
on i.film_id=f.film_id
left join film_category fc
on f.film_id=fc.film_id
left join category c
on fc.category_id=c.category_id
group by 1,2,3
order by 4;
