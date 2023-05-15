--Census and School Data 

--Clean data, replace 'NULL' strings with NULL VALUES
UPDATE school_data
SET pct_proficient_reading = NULL
WHERE pct_proficient_reading = 'NULL';

-- How many public high schools are in each state?
SELECT state_code, COUNT(DISTINCT school_name) AS 'Number of schools'
FROM school_data
GROUP BY 1;

-- How many public high schools are in each zip code?
SELECT zip_code, COUNT(DISTINCT school_name) AS 'Number of schools'
FROM school_data
GROUP BY 1
ORDER BY 2 DESC;


--How many public high schools in each locale_code?
SELECT  COUNT(DISTINCT school_name) AS 'Number of schools', 
CASE	locale_code
	WHEN 11 THEN 'Large City'
	WHEN 12 THEN 'Midsize City'
	WHEN  13 THEN 'Small City'
	WHEN  21 THEN 'Large Suburb'
	WHEN  22 THEN 'Midsize Suburb'
	WHEN 23 THEN 'Small Suburb'
	WHEN 31 THEN 'Fringe Town'
	WHEN 32 THEN 'Distant Town'
	WHEN 33 THEN 'Remote Town'
	WHEN 41 THEN 'Fringe Rural'
	WHEN 42 THEN 'Distant Rural'
	WHEN 43 THEN 'Remote Rural'
	END locale_text
FROM school_data
GROUP BY 2
ORDER BY 1 DESC;


--What is the minimum, maximum, and average median_household_income of the nation? 
SELECT MIN(median_household_income) AS 'Minimum', MAX( median_household_income) AS 'Maximum', ROUND(AVG(median_household_income)) AS 'Average'
FROM census_data;

--What is the minimum, maximum, and average median_household_income for each state?
SELECT state_code AS 'State', MIN(median_household_income) AS 'Minimum', MAX( median_household_income) AS 'Maximum', ROUND(AVG(median_household_income)) AS 'Average'
FROM census_data
GROUP BY state_code
ORDER BY 4 DESC;

--What percent of students in each state are proficient in math and reading?
SELECT state_code AS 'State', ROUND(AVG(pct_proficient_math), 1) AS '% proficient in math', ROUND(AVG(pct_proficient_reading), 1) AS '% proficient in reading'
FROM school_data
GROUP BY state_code;

--Do characteristics of the zip-code area, such as median household income, influence students’ performance in high school?
SELECT 
CASE 
	WHEN median_household_income < 50000 THEN 'Low'
	WHEN median_household_income BETWEEN 50000 AND 100000 THEN 'Middle'
	WHEN median_household_income  > 100000 THEN 'High'
	WHEN median_household_income  IS NULL THEN 'No income info'
	END income_bracket,
ROUND(AVG(pct_proficient_math), 1) AS '% proficient in math', ROUND(AVG(pct_proficient_reading), 1) AS '% proficient in reading'	
FROM census_data
JOIN school_data
ON school_data.zip_code = census_data.zip_code
GROUP BY income_bracket
ORDER BY median_household_income DESC;

--On average, do students perform better on the math or reading exam? 
SELECT ROUND(AVG(pct_proficient_math),1) AS '% proficient in math', ROUND(AVG(pct_proficient_reading), 1) AS '% proficient in reading', 
CASE	
	WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading )THEN 'Better at math'
	WHEN AVG(pct_proficient_math) < AVG(pct_proficient_reading) THEN 'Better at reading'
	ELSE 'No difference'
	END comparison 
FROM school_data;

--Find the number of states where students do better on the math exam, and vice versa.
WITH compareScores AS (
SELECT state_code,
CASE	
	WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading) THEN 'Better at math'
	WHEN AVG(pct_proficient_math) < AVG(pct_proficient_reading) THEN 'Better at reading'
	WHEN pct_proficient_math IS NULL OR pct_proficient_reading IS NULL THEN 'No testing information'
	ELSE 'No difference'
	END comparison
FROM school_data
GROUP BY 1
)
	
SELECT COUNT(DISTINCT school_data.state_code) AS 'State', compareScores.comparison
FROM school_data
JOIN compareScores
ON compareScores.state_code = school_data.state_code
GROUP BY 2
ORDER BY 1 DESC;

--What is the average proficiency on state assessment exams for each zip code, and how do they compare to other zip codes in the same state?
WITH scores AS (
SELECT state_code, AVG(pct_proficient_math) AS stateMath, AVG(pct_proficient_reading) AS stateRead
FROM school_data
GROUP BY 1
)
SELECT zip_code, ROUND(AVG(pct_proficient_math)/scores.stateMath * 100, 1) AS '% of state mean math score', ROUND(AVG(pct_proficient_reading)/scores.stateRead * 100, 1) AS '% of state mean reading score'
FROM school_data
JOIN scores
ON school_data.state_code = scores.state_code
GROUP BY 1
ORDER BY 2 DESC;


