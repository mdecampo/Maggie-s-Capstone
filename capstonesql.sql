--Sums new cases and averages cumulative cases (because they are cumulative and summing would inflate values) by month and year. Calculates yearly average for new cases per month to compare a given month in that year and determine months where cases were greater than average.  
SELECT month_value, 
year_value, 
SUM(new_confirmed) AS new_by_month, 
ROUND(AVG(total_confirmed),0) AS cumulative_by_month, 
AVG(SUM(new_confirmed)) OVER (PARTITION BY year_value) AS total_avg
FROM covid
GROUP by month_value, year_value
ORDER BY year_value DESC, month_value DESC

--Identify top 20 days where cases spiked
SELECT date, 
new_cases
FROM covid
ORDER BY new_cases DESC
LIMIT 20