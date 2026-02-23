import logging
import os
import boto3
import requests
import json
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from requests.adapters import HTTPAdapter

load_dotenv()

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

CENSUS_API_KEY = os.getenv('CENSUS_API_KEY')
YEAR = '2023'
DATASET = 'acs5'
FOD_CODE = '6212'

VARIABLES = [
    'PWGTP', 'FOD1P', 'FOD2P', 'SCHL',
    'OCCP', 'INDP', 'WAGP', 'PERNP',
    'ESR', 'AGEP', 'SEX'
]

def check_s3_bucket_exists(bucket_name):
    """
    Check to see if the S3 bucket exists and is accessible.
    """
    s3 = boto3.client('s3')

    try:
        s3.head_bucket(Bucket=bucket_name)
        logging.info(f"Bucket '{bucket_name}' exists and is accessible.")
        return True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '404':
            logging.info(f"Error: Bucket '{bucket_name}' does not exist.")
        else:
            logging.info(f"Error: {e}")
        return False

def grab_pums_api():
    """
    Grab philosophy graduate records from the Census ACS PUMPS API. 
    A list (one record per respondent) is returned.
    """
    url = f"https://api.census.gov/data/{YEAR}/acs/{DATASET}/pums"
    params = {
        'get': ','.join(VARIABLES),
        'FOD1P': FOD_CODE,
        'key': CENSUS_API_KEY
    }

    session = requests.Session()
    session.mount('https://', HTTPAdapter(max_retries=3))

    logging.info(f"Fetching PUMPS {YEAR} {DATASET} for FOD1P={FOD_CODE}.")
    response = session.get(url, params=params, timeout=120)
    response.raise_for_status()

    raw = response.json()

    # Top row contains headers
    headers = raw[0]
    rows = raw[1:]

    records = [dict(zip(headers, row)) for row in rows]
    logging.info(f"Fetched {len(records):,} records.")
    return records

def upload_pums_to_s3(bucket_name, records):
    """
    Upload PUMS records to S3.
    """
    s3 = boto3.client('s3')
    s3_key = f"raw/pums/year={YEAR}/dataset={DATASET}/pums_philosophy_{YEAR}.json"

    body = '\n'.join(json.dumps(record) for record in records)

    try:
        s3.put_object(
            Bucket=bucket_name,
            Key=s3_key,
            Body=body,
            ContentType='application/json'
        )
        logging.info(f"Uploaded {len(records):,} records to s3://{bucket_name}/{s3_key}.")
        return True
    except Exception as e:
        logging.error(f"Failed to upload to s3: {e}")
        return False
    
if __name__ == "__main__":
    bucket_name = 'philosophyandlogic'

    # If check_s3_bucket_exists returns True, run the script
    if check_s3_bucket_exists(bucket_name):
        logging.info("Pipeline starting...")
        records = grab_pums_api()
        if records:
            upload_pums_to_s3(bucket_name, records)
        logging.info("Pipeline finished.")