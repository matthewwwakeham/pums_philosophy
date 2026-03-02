-- Create clean view for philosophy majors with relevant fields and filters applied
CREATE OR REPLACE VIEW PUBLIC.v_philosophy_clean AS
SELECT
    PWGTP::FLOATAS weight,
CASE SEX
WHEN'1'THEN'MALE'
WHEN'2'THEN'FEMALE'
ENDAS gender,
CASE SCHL
WHEN'21'THEN'Bachelor''s'
WHEN'22'THEN'Master''s'
WHEN'23'THEN'Professional (JD/MD/OTHER)'
WHEN'24'THEN'DOCTORATE'
ENDAS degree,
CASE ESR
WHEN'1'THEN'Private'
WHEN'3'THEN'Government'
WHEN'2'THEN'Self-Employed Inc.'
WHEN'4'THEN'Self-Employed Uninc.'
WHEN'6'THEN'Not in Labor Force'
ENDAS employment,
    WAGP::FLOATAS wage,
    PERNP::FLOATAS earnings,
    AGEP::INTEGERAS age,
CASE
WHEN AGEP::INTEGER<30THEN'Under 30'
WHEN AGEP::INTEGERBETWEEN30AND39THEN'30s'
WHEN AGEP::INTEGERBETWEEN40AND49THEN'40s'
WHEN AGEP::INTEGERBETWEEN50AND59THEN'50s'
WHEN AGEP::INTEGER>=60THEN'60+'
ENDAS age_group,
    OCCP,
    INDP
FROM"philosophy-5-year-public-microdata-sample-2023"
WHERE FOD1P='6212'-- Philosophy majors
AND ESRIN ('1','3')-- Employed private or government
AND WAGP::FLOAT>0;-- Must have wage

-- Create a view for philosophy majors with bachelor's degree only, with relevant fields and filters applied
CREATE OR REPLACE VIEW PUBLIC.v_philosophy_bachelor_weighted AS
SELECT
*,
    SUM(weight) OVER ()AS total_population_weighted,
    ROUND(SUM(wage* weight) OVER ()/ SUM(weight) OVER (),0)AS avg_wage_weighted
FROM PUBLIC.v_philosophy_bachelors_only
WHERE ESRIN ('1','3');-- only employed in private or government

-- Create a view for philosophy majors with graduate degree only, with relevant fields and filters applied
CREATE OR REPLACE VIEW PUBLIC.v_philosophy_graduate_weighted AS
SELECT
*,
    SUM(weight) OVER ()AS total_population_weighted,
    ROUND(SUM(wage* weight) OVER ()/ SUM(weight) OVER (),0)AS avg_wage_weighted
FROM PUBLIC.v_philosophy_graduate_degree
WHERE ESRIN ('1','3');-- only employed in private or government

-- Create a view for top 10 occupations for philosophy majors with bachelor's degree only, with relevant fields and filters applied
CREATE OR REPLACE VIEW PUBLIC.v_top10_occupations_bachelors_weighted AS
SELECT
    OCCPAS occupation,
    SUM(weight)AS population_weighted,
    ROUND(SUM(wage* weight)/SUM(weight),0)AS avg_wage_weighted
FROM PUBLIC.v_philosophy_bachelors_only
WHERE ESRIN ('1','3')-- employed in private or government
GROUP BY OCCP;

-- Create a view for top 10 occupations for philosophy majors with graduate degree only, with relevant fields and filters applied
CREATE OR REPLACE VIEW PUBLIC.v_top10_occupations_graduate_weighted AS
SELECT
    OCCPAS occupation,
    SUM(weight)AS population_weighted,
    ROUND(SUM(wage* weight)/SUM(weight),0)AS avg_wage_weighted
FROM PUBLIC.v_philosophy_graduate_degree
WHERE ESRIN ('1','3')-- employed in private or government
GROUP BY OCCP;

-- Bachelor pop, avg wage, occupation
CREATE OR REPLACE VIEW "philosophy-5-year-public-microdata-sample-2023".PUBLIC.V_BACHELOR_WAGE_BY_OCCUPATION_NAMED AS
SELECT
    o.occp_title AS occupation,
    v.population,
    v.avg_wage
FROM PUBLIC.v_bachelor_wage_by_occupation v
LEFT JOIN occupation_codes o ON v.occupation = o.occp_code
ORDER BY v.population DESC;
