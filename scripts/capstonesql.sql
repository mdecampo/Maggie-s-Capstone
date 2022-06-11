--Insert year and date columns into incidents table for joining purposes later
ALTER TABLE incidents
ADD COLUMN year_value integer,
ADD COLUMN month_value integer

--Update those columns to extract dateparts from the date column 
UPDATE incidents SET year_value = EXTRACT(YEAR FROM date)
UPDATE incidents SET month_value = EXTRACT(MONTH FROM date)

--Add new table to lookup month names without 12 case statements 
CREATE TABLE month_lookup (
	month_value integer PRIMARY KEY,
	month_name VARCHAR ( 50 ) 
);

--Updating newly created table with values 
INSERT INTO 
    month_lookup (month_value, month_name)
VALUES
    (1,'January'),
    (2, 'February'),
    (3, 'March'), 
	(4, 'April'), 
	(5, 'May'),
	(6, 'June'), 
	(7, 'July'), 
	(8, 'August'), 
	(9, 'September'), 
	(10, 'October'), 
	(11, 'November'), 
	(12, 'December');

--Check to make sure table updated correctly
SELECT * 
FROM month_lookup

--Sums new cases and averages cumulative cases (because they are cumulative and summing would inflate values) by month and year. Calculates yearly average for new cases per month to compare a given month in that year and determine months where cases were greater than average.  CSV name: casesbymonthwithavg
SELECT month_value, 
year_value, 
SUM(new_confirmed) AS confirmed_by_month, 
ROUND(AVG(total_confirmed),0) AS cumulative_by_month, 
AVG(SUM(new_confirmed)) OVER (PARTITION BY year_value) AS total_year_avg
	FROM covid
GROUP by month_value, year_value
ORDER BY year_value DESC, month_value DESC

--Creating a dataset to trend total incidents over time, for use as a baseline. This spans years 2015 - 2022 and will include all incidents of any type. 

SELECT i.month_value, 
year_value, 
month_name, 
COUNT(incident_num) AS incidents_by_month, 
SUM(COUNT(incident_num)) OVER (PARTITION BY year_value) AS total_year_count, 
SUM(COUNT(incident_num)) OVER (PARTITION BY year_value)/COUNT(i.month_value) OVER (PARTITION BY year_value) AS incidents_per_month
	FROM incidents AS i
LEFT JOIN month_lookup
	ON i.month_value=month_lookup.month_value
GROUP by i.month_value, month_name, year_value
ORDER BY year_value DESC, i.month_value DESC

--Identify top 50 days across all years where cases spiked (top 50 covid days). CSV name: top50coviddays
SELECT date, 
new_confirmed
	FROM covid
ORDER BY new_confirmed DESC
LIMIT 50

--Lets look at top 50 days for both covid and police incidents in the same table. Only one day was in the top 50 for both Covid Cases AND police incidents. When you expand to 100 there is slightly more overlap, but still not a lot (9 days). CSV name: covidincidentoverlap

SELECT * 
FROM (SELECT incidents.date, 
	  COUNT(incident_num) FROM incidents
            WHERE EXTRACT(year FROM incidents.date)>=2020 AND EXTRACT(month FROM incidents.date)>=03
GROUP BY incidents.date
ORDER BY COUNT(incident_num) DESC
LIMIT 100) AS i
    INNER JOIN (SELECT covid.date, new_confirmed FROM covid ORDER BY new_confirmed DESC LIMIT 100) AS c
		ON i.date=c.date
		
--Identify top 50 days across March 2020-2022 (to coincide with Covid timeframe) with the most police incidents. CSV name: top50incidentdays

SELECT date, 
COUNT(incident_num) AS number_of_incidents
	FROM incidents
WHERE EXTRACT(year FROM date)>=2020 AND EXTRACT(month FROM date)>=03
GROUP BY date
ORDER BY number_of_incidents DESC
LIMIT 50

--Returning count of incidents and sum of cases by month and year. CSV name: casesandincidentcountsbymonthyear

SELECT COUNT(DISTINCT incident_num) AS incident_count, 
SUM(DISTINCT new_confirmed) AS confirmed_cases,
c.month_value, 
c.year_value
	FROM covid AS c
JOIN incidents as i
ON c.month_value=i.month_value 
	AND c.year_value=i.year_value
GROUP BY c.month_value, c.year_value
ORDER BY c.year_value DESC, c.month_value DESC

--Examining crimes by weapon type by month and year. Calculates a yearly total for each weapon or offense desc as well as a yearly average, to help identify months where spikes above or below average occured. 

--This one is by weapon type. CSV name: weapondescbymonthyear
SELECT COUNT(DISTINCT incident_num) AS incident_count, 
year_value, 
month_value, 
weapon_desc, 
SUM(COUNT(incident_num)) OVER (PARTITION BY weapon_desc, year_value) AS total_incidents_by_year, 
AVG(COUNT(incident_num)) OVER (PARTITION BY weapon_desc, year_value) AS avg_incidents_by_month
	FROM incidents 
WHERE weapon_desc NOT LIKE '#N/A'
GROUP BY weapon_desc, year_value, month_value 
ORDER BY weapon_desc, year_value DESC, month_value DESC

--This one is by offense type. CSV name: offensedescbymonthyear
SELECT COUNT(DISTINCT incident_num) AS incident_count, 
year_value, 
month_value, 
offense_desc, 
SUM(COUNT(incident_num)) OVER (PARTITION BY offense_desc, year_value) AS total_incidents_by_year,
AVG(COUNT(incident_num)) OVER (PARTITION BY offense_desc, year_value) AS avg_incidents_by_month
	FROM incidents 
WHERE offense_desc NOT LIKE '#N/A'
GROUP BY offense_desc, year_value, month_value 
ORDER BY offense_desc, year_value DESC, month_value DESC
