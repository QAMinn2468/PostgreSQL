-- (https://pgexercises.com/questions/basic/selectall.html)

--1. Retrieve everything from a table

SELECT * FROM CD.Facilities;

--2. Control which rows are retrieved

SELECT * FROM cd.facilities
WHERE membercost != 0;

--3. Control which rows are retrieved - Part 2

SELECT facid, name, membercost, monthlymaintenance FROM cd.facilities
WHERE membercost != 0
AND membercost < (monthlymaintenance/50);

-- 4. Basic string searches

SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- 5. Matching against multiple possible values

SELECT * from cd.facilities
WHERE facid in ('1', '5');

-- 6. Classify results into buckets

SELECT name, CASE
	WHEN (monthlymaintenance < 100) THEN 'cheap'
	ELSE 'expensive'
END AS cost
FROM cd.facilities;

-- 7. Working with dates

SELECT memid, surname, firstname, joindate FROM cd.members
WHERE joindate > to_date('2012-09-00', 'YYYY-MM-DD');

-- 8. Removing duplicates, and improving results

SELECT DISTINCT surname FROM cd.members
ORDER BY surname
LIMIT 10;

-- 9. Combining results from multiple queries

SELECT surname FROM cd.members
UNION
SELECT name fROM cd.facilities;

-- 10. Simple Aggregation

SELECT MAX(joindate) as latest FROM cd.members;

-- 11. More Aggregation

SELECT firstname, surname, joindate FROM cd.members
ORDER BY joindate DESC
LIMIT 1;
----------------------------------------------------------Joins-----------------

-- 12. Retrieve the start times of member's bookings

SELECT a.starttime FROM cd.bookings a
JOIN cd.members b ON a.memid = b.memid
WHERE surname = 'Farrell'
AND firstname = 'David';

-- 13. Work out the start times of bookings for tennis courts

SELECT a.starttime as start, b.name FROM cd.bookings a
JOIN cd.facilities b ON a.facid = b.facid
WHERE b.name LIKE 'Tennis Court %'
AND a.starttime >= '2012-09-21'
AND a.starttime < '2012-09-22'
ORDER BY a.starttime;

-- 14. Produce a list of all members who have recommended another members

SELECT distinct firstname, surname from cd.members
WHERE memid IN (SELECT recommendedby from cd.members)
ORDER BY surname, firstname;

-- 15. Produce a list of all members, along with their recommender

SELECT a.firstname AS memfname, a.surname AS memsname, b.firstname AS recfname, b.surname AS recsname
FROM cd.members a LEFT OUTER JOIN cd.members b ON a.recommendedby=b.memid
ORDER BY a.surname, a.firstname;

-- 16. Produce a list of all members who have used a tennis courts

SELECT DISTINCT a.firstname || ' ' || a.surname AS member, c.name AS facility
FROM cd.members a INNER JOIN cd.bookings b ON a.memid=b.memid
INNER JOIN cd.facilities c ON b.facid=c.facid
WHERE b.facid IN (0,1)
ORDER BY member;

-- 17. Produce a list of costly bookings

SELECT a.firstname || ' ' || a.surname AS member,  c.name AS facility,
				CASE
						 WHEN a.memid=0 then
									b.slots*c.guestcost
						 ELSE
						 			b.slots*c.membercost
				END  AS cost
FROM cd.members a INNER JOIN cd.bookings b ON a.memid=b.memid
INNER JOIN cd.facilities c ON b.facid=c.facid
WHERE b.starttime >= '2012-09-14'
AND b.starttime <'2012-09-15'
AND  (
	    (a.memid =0 and b.slots*c.guestcost > 30)
  OR  (a.memid!=0 and b.slots*c.membercost > 30)
)
ORDER BY cost DESC;

-- 18. Produce a list of all members, along with their recommender, using no joins. (correlated subquery)

SELECT DISTINCT a.firstname|| ' ' || a.surname AS member,
			  (SELECT b.firstname|| ' ' || b.surname AS recommender
			   FROM cd.members b
			   WHERE b.memid = a.recommendedby)
FROM cd.members a
ORDER BY member;


-- 19. Produce a list of  costly booking, using a subquery
