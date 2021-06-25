/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * 
FROM `Facilities` 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(membercost)
FROM `Facilities` 
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities` 
WHERE membercost < 0.2*monthlymaintenance AND membercost > 0

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities` 
WHERE facid in (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap' END
FROM `Facilities` 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT 		firstname, surname
FROM `Members` as mem1
WHERE joindate = 
(	
	SELECT MAX(joindate) as MaxJoin
 	FROM Members as mem2
)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT( firstname, ' ', surname ) AS 'Full Name', fac.name AS Facility
FROM Members AS mem
RIGHT JOIN Bookings AS book ON mem.memid = book.memid
LEFT JOIN Facilities AS fac ON book.facid = fac.facid
WHERE book.facid
IN ( 0, 1 )
ORDER BY `Full Name` ASC, Facility

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
		CONCAT(M.firstname, ' ', M.surname) AS name, 
		F.name AS facility,
		CASE WHEN B.memid = 0 
		THEN B.slots*F.guestcost
		ELSE B.slots*F.membercost END AS cost
FROM Members AS M
INNER JOIN Bookings AS B 
ON M.memid = B.memid
INNER JOIN Facilities AS F
ON B.facid = F.facid
WHERE B.starttime LIKE '2012-09-14%' AND 
		CASE WHEN B.memid = 0 
		THEN B.slots*F.guestcost
		ELSE B.slots*F.membercost END > 30
ORDER BY cost DESC



/* answer
SELECT
firstname || ' ' || surname AS member,
name AS facility,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
ORDER BY cost DESC;

*/


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub.memid, sub.name, sub.slots, F.facid, F.name, F.membercost, F.guestcost,
		CASE WHEN sub.memid = 0
		THEN sub.slots * F.guestcost
		ELSE sub.slots * F.membercost END as cost
FROM (
		SELECT B.facid, B.memid, B.starttime, B.slots, 
				CONCAT(firstname, ' ', surname) as name
		FROM Bookings AS B
		INNER JOIN Members AS M
		ON B.memid = M.memid
		WHERE B.starttime LIKE '2012-09-14%') as sub
INNER JOIN Facilities AS F
ON sub.facid = F.facid
WHERE 	CASE WHEN sub.memid = 0
		THEN sub.slots * F.guestcost
		ELSE sub.slots * F.membercost END > 30
ORDER BY cost DESC

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

        SELECT F.name, 
                SUM(CASE WHEN B.memid = 0 
                THEN F.guestcost*B.slots
                ELSE F.membercost*B.slots END) AS revenue
        FROM BOOKINGS AS B
        INNER JOIN FACILITIES AS F
        ON B.facid = F.facid
        GROUP BY F.name
        HAVING revenue < 1000
        ORDER BY revenue DESC

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
        SELECT M1.surname, M1.firstname, M2.surname as recommender_last, M2.firstname as recommender_first
        FROM Members as M1
        LEFT JOIN Members as M2
        ON M1.recommendedby = M2.memid
        ORDER BY M1.surname, M1.firstname

/* Q12: Find the facilities with their usage by member, but not guests */
        select M.surname, M.firstname,
            count(case when facid = 0 then facid end) as TC1,
            count(case when facid = 1 then facid end) as TC2,
            count(case when facid = 2 then facid end) as BC,
            count(case when facid = 3 then facid end) as TT,
            count(case when facid = 4 then facid end) as MR1,
            count(case when facid = 5 then facid end) as MR2,
            count(case when facid = 6 then facid end) as SC,
            count(case when facid = 7 then facid end) as ST,
            count(case when facid = 8 then facid end) as PT
        from Bookings as B
        inner join Members as M
        on B.memid = M.memid
        where B.memid > 0
        group by B.memid

/* Q13: Find the facilities usage by month, but not guests */

        select F.name,
            count(case when strftime('%m',starttime) = '07' then 'July' end) as July,
            count(case when strftime('%m',starttime) = '08' then 'August' end) as August,
            count(case when strftime('%m',starttime) = '09' then 'September' end) as September
        from Bookings as B
        inner join Facilities as F
        on B.facid = F.facid
        where B.memid > 0
        group by B.facid