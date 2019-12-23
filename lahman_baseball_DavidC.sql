/*1.
SELECT MAX(yearid),min(yearid) FROM batting
from 1871 to 2016
*/
/*2.
SELECT  batting.yearid,namefirst,namelast,height,name,batting.g
FROM people,batting,teams
WHERE height = (SELECT MIN(height) FROM people) and people.playerid=batting.playerid
AND teams.teamid=batting.teamid --appearance as a batter
UNION
SELECT  pitching.yearid,namefirst,namelast,height,name,pitching.g
FROM people,teams,pitching 
WHERE height = (SELECT MIN(height) FROM people)
AND people.playerid=pitching.playerid AND teams.teamid=pitching.teamid --appearance as a pitcher

--Eddie Gaedal, 43inches tall played 1 game for the St.louis Browns in 1951 
*/

/*3
SELECT distinct playerid,namefirst,namelast,SUM(salary) OVER(Partition by playerid) AS total_salary_earned
FROM(
SELECT distinct people.playerid,namefirst,namelast,schoolname,salary
FROM people
JOIN collegeplaying ON people.playerid=collegeplaying.playerid
JOIN schools ON collegeplaying.schoolid=schools.schoolid
JOIN salaries ON people.playerid=salaries.playerid
WHERE schoolname='Vanderbilt University') AS j
ORDER BY total_salary_earned DESC

--15 mlb players who played at Vanderbilt, David Price earned the most salary in mlb with total of 81,851,296
*/
/*4
SELECT CASE 
WHEN pos IN ('OF') THEN 'Outfield'
WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
WHEN pos IN ('P','C') THEN 'Battery' END AS positions,
SUM(po)
FROM fielding
WHERE yearid=2016
GROUP BY positions
--battery:41424, infield:58934, outfield:29560 in 2016
*/
/*5
SELECT CASE 
	   WHEN yearid between 1920 AND 1929 THEN '1920s'
	   WHEN yearid between 1930 AND 1939 THEN '1930s'
	   WHEN yearid between 1940 AND 1949 THEN '1940s'
	   	   WHEN yearid between 1950 AND 1959 THEN '1950s'
		   WHEN yearid between 1960 AND 1969 THEN '1960s'
		   WHEN yearid between 1970 AND 1979 THEN '1970s'
		   WHEN yearid between 1980 AND 1989 THEN '1980s'
		   WHEN yearid between 1990 AND 1999 THEN '1990s'
		   WHEN yearid between 2000 AND 2009 THEN '2000s'
		   ELSE '2010s' END AS decades,
		   SUM(strike_out) AS Total_Strikeouts,SUM(home_run) AS total_homeruns,
		   
		   ROUND(AVG(strike_out),2) AS so_per_game,
		   ROUND(AVG(home_run),2) AS hr_per_game
		   
		  
FROM(
SELECT yearid,so AS strike_out,hr AS home_run
FROM batting	
) j
GROUP BY decades
ORDER BY decades
*/ -- strikeouts and homeruns seem to have linear relationship

/*6.
SELECT j.playerid,p.namefirst,p.namelast,sum(sb) AS stolen_base,sum(cs) AS caught_stealing,
sum(sb)+sum(cs) AS stolen_base_attempt, 
ROUND(SUM(sb)::decimal/(SUM(sb)::decimal+SUM(cs)::decimal),2) AS stolen_base_success_rate
FROM 
 (SELECT distinct playerid,sb,cs,(SUM(sb)+SUM(cs)) AS sb_attempt FROM batting WHERE yearid=2016
  GROUP BY playerid,sb,cs
  HAVING (SUM(sb)+SUM(cs))!=0) j
INNER JOIN people AS p USING(playerid)
WHERE sb_attempt>=20
GROUP BY j.playerid,p.namefirst,p.namelast
ORDER BY stolen_base_success_rate DESC
*/
--Chris Owings had the highest success rate .91 in 2016
/*7

WITH champ AS(
SELECT yearid,name,MAX(w) AS wins
FROM teams WHERE yearid>=1970 AND yearid!=1981 AND yearid!= 1994 AND wswin='Y' group by yearid, name order by yearid)			  
, 
max_wins AS(
SELECT yearid,MAX(w) AS wins
FROM teams WHERE yearid>=1970 AND yearid!=1981  AND yearid != 1994 
group by yearid
order by yearid)


SELECT champ.yearid,champ.name AS ws_champs,champ.wins AS ws_champion_wins,max_wins.wins AS max_regular_season_wins
FROM champ,max_wins
WHERE champ.yearid=max_wins.yearid
--12 out of 45 times most game won during regular season won the world series. (12/45)*100=26.67%
*/
/*8 
--top 5 
SELECT teams.name,park_name,homegames.attendance,games,homegames.attendance/games AS attendance_per_game
FROM homegames
INNER JOIN parks ON homegames.park=parks.park
AND year=2016 AND games>1
INNER JOIN teams ON homegames.team=teams.teamid AND homegames.year=teams.yearid
WHERE teams.yearid>1960
ORDER BY attendance_per_game DESC
LIMIT 5
--bottom 5
SELECT teams.name,park_name,homegames.attendance,games,homegames.attendance/games AS attendance_per_game
FROM homegames
INNER JOIN parks ON homegames.park=parks.park
AND year=2016 AND games>1
INNER JOIN teams ON homegames.team=teams.teamid AND homegames.year=teams.yearid
WHERE teams.yearid>1960
ORDER BY attendance_per_game 
LIMIT 5
*/
/*9.
SELECT DISTINCT CONCAT(people.namefirst,' ',people.namelast) AS manager_name,awardsmanagers.lgid,
teams.name
FROM awardsmanagers
INNER JOIN managers ON awardsmanagers.yearid=managers.yearid AND awardsmanagers.playerid=managers.playerid
INNER JOIN people ON awardsmanagers.playerid=people.playerid
INNER JOIN teams ON managers.teamid=teams.teamid
WHERE teams.yearid>1960 AND awardsmanagers.playerid IN (SELECT distinct people.playerid FROM people
INNER JOIN managers ON people.playerid=managers.playerid
WHERE CONCAT(namefirst,' ',namelast) 
IN (
SELECT j.manager_name FROM(
select j.yearid,j.lgid,CONCAT(j.first_name,' ',j.last_name) AS manager_name,managers.teamid
FROM (select distinct yearid, lgid,awardsmanagers.playerid, people.namefirst AS first_name, people.namelast AS last_name
FROM awardsmanagers
INNER JOIN people 
ON awardsmanagers.playerid=people.playerid
WHERE lgid != 'ML' AND awardsmanagers.awardid='TSN Manager of the Year' AND lgid='AL'
ORDER BY yearid) j
INNER JOIN managers ON j.yearid=managers.yearid AND j.playerid=managers.playerid)j
INTERSECT
SELECT j2.manager_name FROM(
select j.yearid,j.lgid,CONCAT(j.first_name,' ',j.last_name) AS manager_name,managers.teamid
FROM (select distinct yearid, lgid,awardsmanagers.playerid, people.namefirst AS first_name, people.namelast AS last_name
FROM awardsmanagers
INNER JOIN people 
ON awardsmanagers.playerid=people.playerid
WHERE lgid != 'ML' AND awardsmanagers.awardid='TSN Manager of the Year' AND lgid='NL'
ORDER BY yearid) j
INNER JOIN managers ON j.yearid=managers.yearid AND j.playerid=managers.playerid)j2)) AND awardid='TSN Manager of the Year'
ORDER BY manager_name

*/
