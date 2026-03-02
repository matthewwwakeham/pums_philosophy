-- Total employed population of philosophy BA degree holders (1,3)
SELECT SUM(PWGTP::INTEGER) AS employed_ba_population
FROM "philosophy-5-year-public-microdata-sample-2023"
WHERE ESR IN ('1', '3')
AND WAGP::FLOAT > 0
AND SCHL = '21';
