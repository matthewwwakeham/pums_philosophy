### Where do philosophy graduates end up?
In this project we look at a microdata sample to determine the occupations, industries, and wages philosophy graduates may achieve.

### Info - Public Use Microdata Sample
PUMS are datasets based on data collected from the American Community Survey. Responses are self-reported.

### Getting Started
## API
# Getting A Key
Rename the file called ".example env" to ".env" and add your own API key. You can request a key here: https://api.census.gov/data/key_signup.html.

## Script
# Data
A dataset has been included if you don't want to run the script.
# Run the script
You will need to use the Amazon Web Services CLI in order to put your AWS keys on device or use some other method. From there, make sure you have created a bucket in S3 so boto3 can find it.

## ETL in Snowflake
# Set up Snowflake
You will need to connect S3 with Snowflake. From there, create a stage connecting to S3, and then import the JSON dataset into Snowflake as a table under the stage you created earlier.
# SQL
Run the SQL commands in "sql/views_queries.sql". You may need to use the following commands first:
- use database {name of your database};
- use schema public;

## Further analysis and dashboards
# Connect Power BI to Snowflake
You can connect Power BI to Snowflake through the "Get data from other sources" button and then searching "Snowflake".
It is easiest to import the queries rather than live query them.
Drag and drop the different buckets of data into the proper visualizations.

## Dashboards and PowerPoint
A file containing the dashboards and associated data can be downloaded and viewed. Additionally, a PowerPoint going over some of the results is available.
