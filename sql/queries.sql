-- Total employed population of philosophy BA degree holders (1,3)
SELECT SUM(PWGTP::INTEGER) AS employed_ba_population
FROM "philosophy-5-year-public-microdata-sample-2023"
WHERE ESR IN ('1', '3')
AND WAGP::FLOAT > 0
AND SCHL = '21';

-- Philosophy BA holders + any graduate degree
SELECT SUM(PWGTP::INTEGER) AS est_population,
    ROUND(SUM(WAGP::FLOAT * PWGTP::FLOAT) / SUM(PWGTP::FLOAT), 0) AS weighted_avg_wage,
    MEDIAN(WAGP::INTEGER) AS median_wage
FROM "philosophy-5-year-public-microdata-sample-2023"
WHERE FOD1P = '6212'
AND ESR IN ('1', '3')
AND WAGP::FLOAT > 0
AND SCHL IN ('21', '22', '23', '24');
