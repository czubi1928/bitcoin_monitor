# --- Import necessary libraries ---
import datetime
import json
import logging
import os
from datetime import timedelta
from typing import Optional, Tuple, Any

import pendulum
import requests
import snowflake.connector
from airflow.sdk import dag, task
from snowflake.connector.connection import SnowflakeConnection

# --- Set up logging ---
logger = logging.getLogger(__name__)

# --- Define constants ---
# CoinCap API configuration
COINCAP_API_URL = 'https://rest.coincap.io/v3'
COINCAP_API_KEY = os.getenv('COINCAP_API_KEY')
COINCAP_API_HEADERS = {'Authorization': f'Bearer {COINCAP_API_KEY}'}
COINCAP_API_ENDPOINTS = ['assets']
COINCAP_API_LIMIT = 10

# Snowflake configuration
SNOWFLAKE_USER = os.getenv('SNOWFLAKE_USER')
SNOWFLAKE_ACCOUNT = os.getenv('SNOWFLAKE_ACCOUNT')
# PRIVATE_KEY_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'keys', 'snowflake_key.p8'))
PRIVATE_KEY_FILE = '/keys/snowflake_key.p8'
SNOWFLAKE_CONFIG = {
    'warehouse': 'COINCAP_WH',
    'database': 'COINCAP_DB',
    'schema_bronze': 'RAW'
}


# --- Define helper functions ---
def _get_snowflake_conn(warehouse: str = None, database: str = None, schema: str = None) -> SnowflakeConnection | None:
    """
    Establish a connection to Snowflake using JWT authentication.
    :param warehouse: The warehouse to connect to, default is None.
    :param database: The database to connect to, default is None.
    :param schema: The schema to connect to, default is None.
    :return: A SnowflakeConnection object if successful, None otherwise.
    """
    try:
        conn = snowflake.connector.connect(
            account=SNOWFLAKE_ACCOUNT,
            user=SNOWFLAKE_USER,
            authenticator='SNOWFLAKE_JWT',
            private_key_file=PRIVATE_KEY_FILE,
            warehouse=warehouse,
            database=database,
            schema=schema,
        )
        logger.info('Successfully connected to Snowflake!')
        return conn
    except Exception as e:
        logger.error(f'Failed to connect to Snowflake: {e}')
        return None


def _get_request(endpoint: str) -> dict:
    """
    Make a GET request to the CoinCap API.
    :param endpoint: The endpoint to query.
    :return: The dictionary response from the API.
    """

    url = f'{COINCAP_API_URL}/{endpoint}?limit={COINCAP_API_LIMIT}'
    response = requests.get(url, headers=COINCAP_API_HEADERS)
    if response.status_code == 200:
        logger.info(f'Successfully fetched data from {url}.')
        return response.json()
    else:
        logger.error(f'Failed to fetch data: {response.json()['error']}.')
        return {}


def _execute_query(conn: SnowflakeConnection, query: str, params: Optional[Tuple[Any, ...]] = None) -> None:
    """
    Execute a SQL query on the Snowflake connection.
    :param conn: The Snowflake connection object.
    :param query: The SQL query to execute.
    :param params: Optional tuple of parameters to pass to the query.
    :return: None.
    """
    try:
        with conn.cursor() as cur:
            # Pass the params tuple here. Snowflake connector handles the quoting/escaping.
            cur.execute(query, params)
        logger.info('Query executed successfully!')
    except Exception as e:
        logger.error(f'Failed to execute query: {e}')
        # It is usually good practice to raise the error so the Airflow task fails and retries
        raise e


# --- Define the DAG ---
@dag(
    dag_id='exchange_data_dag',
    description='ELT: Pull raw data from CoinCap API and load to Snowflake.',
    # Always set a static start_date. Dynamic dates (pendulum.now) can cause scheduling bugs.
    start_date=pendulum.datetime(2023, 1, 1, tz='UTC'),
    schedule='*/5 * * * *',
    tags=['data_engineer_team', 'bronze', 'extract', 'load'],
    catchup=False,
    # Best Practice: Set default args for retries on API failures
    default_args={
        'retries': 3,
        'retry_delay': timedelta(seconds=30),
        'owner': 'data_engineering'
    },
    dagrun_timeout=timedelta(minutes=10),  # Fail if stuck
)
def exchange_data_dag():
    # --- Define tasks ---
    @task(task_id='extract_data_from_api', do_xcom_push=True)
    def extract_data_from_api_task(endpoint: str) -> dict:
        """
        Extract data from CoinCap API.
        :param endpoint: The API endpoint to extract data from.
        :return: A dictionary containing the extracted data.
        """
        # Make and return the API request result
        return {endpoint: _get_request(endpoint)}

    @task(task_id='load_data_to_warehouse')
    def load_data_to_warehouse_task(extracted_data: list[dict]) -> None:
        """
        Load extracted data into Snowflake.
        :param extracted_data: The list of results aggregated from the upstream mapped tasks.
        :return: None.
        """
        data_dict = {}
        for item in extracted_data:
            data_dict.update(item)

        if not data_dict:
            logger.warning('No data received from upstream extraction tasks. Skipping load.')
            return

        # Create Snowflake connection
        conn = _get_snowflake_conn(
            database=SNOWFLAKE_CONFIG['database'],
            schema=SNOWFLAKE_CONFIG['schema_bronze'],
            warehouse=SNOWFLAKE_CONFIG['warehouse'],
        )
        if conn is None:
            raise

        # Process each data entity
        for table_name, content in data_dict.items():
            snowflake_table_name = f'{table_name.upper()}_SNAPSHOTS'
            logger.info(f'Inserting data into "{snowflake_table_name}" table...')

            try:
                # Assuming the CoinCap response has 'timestamp' and 'data' fields
                ts_val = datetime.datetime.fromtimestamp(content['timestamp'] / 1000.0)
                json_val = json.dumps(content['data'])
                sfn_val = f'{table_name}_{content['timestamp']}.json'
            except KeyError as e:
                logger.error(f'API response for {table_name} missing required key: {e}. Skipping.')
                continue

            sql = f'''
                INSERT INTO {snowflake_table_name} (LOAD_TIMESTAMP, RAW_DATA, SOURCE_FILE_NAME) 
                SELECT %s, PARSE_JSON(%s), %s
            '''
            logger.info(f'Executing SQL: {sql} with timestamp: {ts_val} and data length: {len(json_val)}')

            # Pass values as a tuple in the second argument
            _execute_query(conn, sql, (ts_val, json_val, sfn_val))

        # Close the database connection
        conn.close()

    # --- Define task dependencies ---
    extracted_data_list = extract_data_from_api_task.expand(endpoint=COINCAP_API_ENDPOINTS)

    # Pass the output of the mapped task directly as the argument to the downstream task.
    # This automatically handles XCom aggregation.
    load_data_to_warehouse_task(extracted_data=extracted_data_list)


exchange_data_dag()
