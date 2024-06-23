-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era) FROM pitching -- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
    select namefirst, namelast, birthyear from people where weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  select namefirst, namelast, birthyear from people where namefirst like "% %" order by namefirst, namelast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, yearid
  FROM people INNER JOIN halloffame ON people.playerID = halloffame.playerID
  WHERE inducted = "Y"
  ORDER BY yearid DESC , people.playerID
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, c.schoolid, yearid
  FROM people p, halloffame h, collegeplaying c, schools s
  WHERE p.playerID = h.playerID
    and p.playerID = c.playerid
    and c.schoolID = s.schoolID
    and inducted = "Y"
    and s.schoolState = "CA"
  ORDER BY yearid DESC , c.schoolID, p.playerID
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, namefirst, namelast, c.schoolid
  FROM people p inner join halloffame h on p.playerID = h.playerID Left Join collegeplaying c on p.playerID = c.playerid
  WHERE inducted = "Y"
  ORDER BY p.playerID DESC, c.schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerid, namefirst, namelast, yearid, ROUND((CAST(h AS FLOAT) + 1.0 * CAST(h2b AS FLOAT) + 2.0 * CAST(h3b AS FLOAT) + 3.0 * CAST(hr AS FLOAT)) / CAST(ab AS FLOAT),4) AS slg
  FROM people
  INNER JOIN batting ON people.playerid = batting.playerid
  WHERE AB > 50
  ORDER BY slg DESC, yearid, people.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT n.playerid, namefirst, namelast, lslg
  FROM
      (SELECT playerid, ROUND((CAST(SUM(h) AS FLOAT) + 1.0 * CAST(SUM(h2b) AS FLOAT) + 2.0 * CAST(SUM(h3b) AS FLOAT) + 3.0 * CAST(SUM(hr) AS FLOAT)) / CAST(SUM(ab) AS FLOAT),4) AS lslg
      FROM batting
      Group By playerID
      HAVING SUM(AB) > 50
      ORDER BY lslg DESC, playerid
      LIMIT 10) n INNER JOIN people ON people.playerID = n.playerID
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM
      (SELECT playerid, ROUND((CAST(SUM(h) AS FLOAT) + 1.0 * CAST(SUM(h2b) AS FLOAT) + 2.0 * CAST(SUM(h3b) AS FLOAT) + 3.0 * CAST(SUM(hr) AS FLOAT)) / CAST(SUM(ab) AS FLOAT),4) AS lslg
      FROM batting
      Group By playerID
      HAVING SUM(AB) > 50
      ORDER BY lslg DESC, playerid) n, people
  WHERE people.playerID = n.playerID
    AND lslg > (SELECT ROUND((CAST(SUM(h) AS FLOAT) + 1.0 * CAST(SUM(h2b) AS FLOAT) + 2.0 * CAST(SUM(h3b) AS FLOAT) + 3.0 * CAST(SUM(hr) AS FLOAT)) / CAST(SUM(ab) AS FLOAT),4) AS lslg
      FROM batting
      WHERE playerID = "mayswi01")
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
    SELECT yearid, min(salary) as min, max(salary) as max, avg(salary) as avg
    FROM salaries
    GROUP BY yearid
    ORDER BY yearID
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
    SELECT binid, low, high, COUNT(*)
    FROM
        (SELECT binid,
               (max(salary) - min(salary)) / 10.0 * binid + min(salary) as low,
               (max(salary) - min(salary)) / 10.0 * (binid + 1) + min(salary) as high
        FROM salaries, binids
        WHERE yearID = 2016
        GROUP BY binid) as b, salaries
    WHERE yearID = 2016
              and ((salary >= b.low AND salary < b.high AND binid >= 0 AND binid < 9)
                       or (salary >= b.low AND salary <= b.high AND binid >= 0 AND binid = 9))
    GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
    WITH tmp as (
        SELECT yearid, min(salary) as min, max(salary) as max, avg(salary) as avg
        FROM salaries
        GROUP BY yearid)
    SELECT s1.yearID,
           (s1.min - s2.min) as mindiff,
           (s1.max - s2.max) as maxdiff,
           (s1.avg - s2.avg) as avgdiff
    FROM tmp s1, tmp s2
    WHERE s1.yearID = s2.yearID + 1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
    SELECT salaries.playerid, namefirst, namelast, salary, salaries.yearid
    FROM salaries
        INNER JOIN people ON salaries.playerID = people.playerID
        INNER JOIN (SELECT MAX(salary) max, yearID FROM salaries WHERE yearID in (2000, 2001) GROUP BY  yearID) as m ON salaries.yearID = m.yearID and salaries.salary = max
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
    SELECT allstarfull.teamID, max(salary) - min(salary)
    FROM allstarfull INNER JOIN salaries ON salaries.playerID = allstarfull.playerID AND salaries.yearID = allstarfull.yearID
    WHERE salaries.yearID = 2016
    GROUP BY allstarfull.teamID
;

