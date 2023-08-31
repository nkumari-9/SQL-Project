--D1 Create Database for yelp project

CREATE DATABASE yelp_project;
\c yelp_project

--Q1 Number of user joined yelp since 2010

SELECT EXTRACT(YEAR FROM dateandtime) AS year,
COUNT(userid) As number_of_users
FROM users
WHERE EXTRACT(YEAR FROM dateandtime) >= '2010'
GROUP BY year
ORDER BY year;
 

--Q2 List of elite users from 2012 through 2021

SELECT year, COUNT(DISTINCT userid) AS number_of_eliteusers
FROM usereliteyears
WHERE year BETWEEN '2012' AND '2021'
GROUP BY year
ORDER BY year;


--Q3 Details of user with the most 5-star reviews

SELECT U.name, U.dateandtime AS date_of_joining, U.numberoffans, U.funnyvotes, U.usefulvotes, U.coolvotes, C.reviewtext
FROM 
(
SELECT userid, rank() over(order by count(*) desc) AS rnk
FROM reviews
WHERE userrating = 5.00
GROUP BY userid
) AS A 
JOIN users AS U
ON A.userid = U.userid
JOIN reviews AS C
ON A.userid = C.userid
WHERE A.rnk=1
ORDER BY C.reviewdateandtime DESC
LIMIT 5;


--Q4 List of 10 users with most friends

SELECT uf.userid, us.name AS Name_of_User
FROM userfriends AS uf JOIN users AS us
ON uf.userid = us.userid
GROUP BY uf.userid, us.name
ORDER BY COUNT(DISTINCT(uf.friendid)) DESC
LIMIT 10;



--Q5 Top 10 US states with most business

SELECT state FROM businesses
GROUP BY state
ORDER BY COUNT(*) DESC
LIMIT 10 ;


--Q6 Top 10 Business Categories

SELECT categoryname FROM business_categories
GROUP BY categoryname
ORDER BY COUNT(DISTINCT(businessid)) DESC
LIMIT 10;


--Q7 Average rating of top 10 business categories

SELECT bc.categoryname, round(avg(rs.userrating),2) AS avg_rating
FROM business_categories AS bc LEFT JOIN reviews AS rs
ON bc.businessid = rs.businessid
WHERE categoryname IN (SELECT categoryname FROM business_categories
GROUP BY categoryname
ORDER BY COUNT(DISTINCT(businessid)) DESC
LIMIT 10)
GROUP BY bc.categoryname
ORDER BY COUNT(DISTINCT(bc.businessid)) DESC;


--Q8 Most funny and least funny reviews

SELECT A.funny_review, B.least_funny_review
FROM
(
SELECT rownum, funny_review
FROM (SELECT  row_number() OVER () AS rownum, reviewtext AS funny_review FROM reviews
WHERE businessid IN (SELECT distinct businessid FROM business_categories WHERE categoryname='Restaurants')
ORDER BY usersmarkingreviewfunny DESC
    ) AS C
WHERE rownum <=5
) AS A join
(
SELECT rownum, least_funny_review
FROM (SELECT  row_number() OVER () AS rownum, businessid, reviewtext AS least_funny_review FROM reviews
WHERE businessid IN (SELECT distinct businessid FROM business_categories WHERE categoryname='Restaurants')
ORDER BY usersmarkingreviewfunny
    ) AS D 
WHERE rownum <=5
) AS B on A.rownum = B.rownum;



--Q9 Tips Compliment analysis

SELECT B.avg_length_most_complimented, D.avg_length_least_complimented
FROM
(
SELECT row_number() over() AS row_num, avg(A.length_most_complimented) AS avg_length_most_complimented
FROM
(
SELECT length(text) AS length_most_complimented
FROM tips
ORDER BY numberofcompliments DESC
LIMIT 100 ) AS A
) AS B
JOIN
(
SELECT row_number() over() AS row_num, avg(C.length_least_complimented) AS avg_length_least_complimented
FROM
(
SELECT length(text) AS length_least_complimented
FROM tips
ORDER BY numberofcompliments
LIMIT 100 ) AS C
) AS D
ON B.row_num = D.row_num;


--Q10 Data to analyze restaurant reviews

SELECT C.businessid, C.businessname, A.no_of_days, A.no_of_hrs, C.averagereviews
FROM
(SELECT businessid, COUNT(DISTINCT dayoftheweek) AS no_of_days, SUM('00:00:00'::TIME +(closingtime - openingtime)) AS no_of_hrs
FROM business_hours
GROUP BY businessid)AS A
JOIN 
(SELECT businessid FROM business_categories WHERE categoryname='Restaurants')AS B
ON A.businessid = B.businessid
JOIN 
(SELECT businessid, businessname, averagereviews from businesses)AS C
ON A.businessid = C.businessid 
ORDER BY A.no_of_days DESC , A.no_of_hrs DESC
LIMIT 100;




-- Additional Queries on Yelp Data



--Q11 Top 5 Bakeries details with the highest average reviews in California

SELECT businessname, streetaddress, city, postalcode
FROM businesses 
WHERE businessid IN (SELECT DISTINCT businessid FROM business_categories WHERE categoryname ='Bakeries')
AND state = 'CA'
ORDER BY averagereviews DESC, numberofreviews DESC
LIMIT 5;


--Q12 Business/Businesses which has the most 5 star ratings for the year 2022

SELECT C.businessname, C.city, C.postalcode,C.state
FROM businesses AS C
JOIN
(
SELECT businessid
FROM(
SELECT businessid, rank() over(order by count(*) DESC) AS rnk
FROM reviews
WHERE EXTRACT(YEAR FROM reviewdateandtime) = '2022'
AND userrating = 5.00
GROUP BY businessid
) AS A
WHERE rnk=1
)AS B
ON B.businessid = C.businessid;


--Q13 Top 5 users who have more fans than friends

SELECT name, (A.numberoffans-B.friends_count) AS diff_fans_friends
FROM users AS A
JOIN
(SELECT userid, COUNT(DISTINCT friendid) AS friends_count
FROM userfriends
GROUP BY userid
) AS B
ON A.userid = B.userid
WHERE (A.numberoffans-B.friends_count) >0
ORDER BY diff_fans_friends DESC
LIMIT 5;

--Q14 Top 5 Restaurants details and their average reviews in Pennsylvania which are open all 7 days in a week and has the most number of reviews

SELECT D.businessname, D.city, D.postalcode, D.averagereviews
FROM
(SELECT DISTINCT businessid FROM business_categories WHERE categoryname='Restaurants')AS A
JOIN
(SELECT businessid
FROM business_hours
GROUP BY businessid
HAVING COUNT(DISTINCT dayoftheweek)=7 )AS C
ON A.businessid=C.businessid
JOIN businesses AS D
ON A.businessid=D.businessid
WHERE state = 'PA'
ORDER BY numberofreviews DESC
LIMIT 5;

--Q15 15 categories which has least number of reviews

SELECT categoryname
FROM business_categories AS bc
JOIN
businesses AS b
ON b.businessid = bc.businessid
GROUP BY categoryname
ORDER BY SUM(numberofreviews)
LIMIT 15;

--Q16 Total Restaurants which allows take out

SELECT COUNT(DISTINCT businessid) AS total_restaurants
FROM business_attributes
WHERE businessid IN (SELECT DISTINCT businessid FROM business_categories WHERE categoryname='Restaurants')
AND attributename = 'restaurantstakeout'
AND attributevalue = 'True';

--Q17  Top ten users who has given maximum number of reviews

SELECT name, numberofreviews
FROM users
ORDER BY numberofreviews DESC
LIMIT 10;

--Q18 Total count of users who has not reviewd yet

Select COUNT(userid) AS total_users_not_reviewed
FROM users
WHERE numberofreviews=0 ;

--Q19 Top 10 business_attributes which are most often used

SELECT attributename, COUNT(*) AS attribute_count FROM business_attributes
GROUP BY attributename
ORDER BY COUNT(*) DESC
LIMIT 10;

--Q20 List of the years with the highest number of tip left by the user

SELECT EXTRACT(YEAR FROM dateandtimeoftip) AS year_with_highest_tip,
COUNT(DISTINCT(userid)) AS number_of_tips
FROM tips
GROUP BY  year_with_highest_tip
ORDER BY  number_of_tips DESC;



