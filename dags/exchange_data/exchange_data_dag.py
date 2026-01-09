# --- Import necessary libraries ---
import datetime
import json
import logging
import os
from typing import Optional, Tuple, Any

import requests
import snowflake.connector
from airflow.sdk import dag, task
from airflow.sdk.bases.operator import chain
from snowflake.connector.connection import SnowflakeConnection

# --- Set up logging ---
logger = logging.getLogger(__name__)

# --- Define constants ---
COINCAP_API_URL = 'https://rest.coincap.io/v3'
COINCAP_API_KEY = os.getenv('COINCAP_API_KEY')
COINCAP_API_HEADERS = {'Authorization': f'Bearer {COINCAP_API_KEY}'}
COINCAP_API_LIMIT = 10

SNOWFLAKE_USER = os.getenv('SNOWFLAKE_USER')
SNOWFLAKE_PASSWORD = os.getenv('SNOWFLAKE_PASSWORD')
SNOWFLAKE_ACCOUNT = os.getenv('SNOWFLAKE_ACCOUNT')
PRIVATE_KEY_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'snowflake_tf_snow_key.p8'))
SNOWFLAKE_STRUCTURE_SQL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                            'snowflake_warehouse_structure.sql')
SNOWFLAKE_CONFIG = {
    'warehouse': 'COINCAP_WAREHOUSE',
    'database': 'COINCAP_DATABASE',
    'schema_bronze': 'COINCAP_BRONZE_SCHEMA',
    'schema_silver': 'COINCAP_SILVER_SCHEMA',
    'schema_gold': 'COINCAP_GOLD_SCHEMA',
}


# --- Define helper functions ---
def _get_snowflake_conn(warehouse: str = None, database: str = None, schema: str = None) -> SnowflakeConnection | None:
    """
    Establish a connection to the warehouse database.
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


# def _read_and_template_sql() -> list[str]:
#     """
#     Reads the SQL file, applies configuration templating, and splits commands.
#     :return: A list of SQL commands.
#     """
#
#     # Read the SQL template file
#     with open(SNOWFLAKE_STRUCTURE_SQL_PATH, 'r') as f:
#         sql_template = f.read()
#
#     # Apply templating using Python's format method
#     templated_script = sql_template.format(**SNOWFLAKE_CONFIG)
#
#     # Split the script by semicolon, filtering out comments and empty lines
#     raw_commands = templated_script.split(';')
#
#     commands = []
#     for command in raw_commands:
#         # Strip leading/trailing whitespace (including newlines)
#         cleaned_command = command.strip()
#
#         # Only include commands that are not empty
#         # This filters out results from comments, empty lines, or trailing semicolons.
#         if cleaned_command:
#             commands.append(cleaned_command)
#
#     return commands


# --- Define the DAG ---
@dag(
    dag_id='exchange_data_dag',
    description='The DAG to pull data from CoinCap API and load it into our warehouse.',
    schedule='*/1 * * * *',  # At every minute
    # retries=3,
    # retry_delay=timedelta(seconds=30),
    tags=['data_engineer_team', 'load'],
    catchup=False,
    dagrun_timeout=None,
)
def exchange_data_dag():
    # --- Define tasks ---
    # @task(task_id='create_warehouse_structure')
    # def create_warehouse_structure_task() -> None:
    #     """
    #     Create the necessary warehouse structure if it does not exist.
    #     :return: None.
    #     """
    #     # Create Snowflake connection
    #     conn = _get_snowflake_conn()
    #
    #     # If connection failed, fail the task to stop the DAG run
    #     if conn is None:
    #         logger.error('Cannot create warehouse structure without a database connection...')
    #         return
    #
    #     # Define SQL commands to create database, schema, and tables etc.
    #     commands = _read_and_template_sql()
    #
    #     # Execute each command
    #     for command in commands:
    #         _execute_query(conn, command)

    @task(task_id='extract_data_from_api', do_xcom_push=True)
    def extract_data_from_api_task() -> dict:
        """
        Extract data from CoinCap API and load into warehouse.
        :return: A dictionary containing extracted data.
        """
        # Extract data from CoinCap API
        assets = _get_request(f'assets')
        exchanges = _get_request(f'exchanges')
        markets = _get_request(f'markets')
        rates = _get_request(f'rates')

        data = {
            'data': {
                'assets': assets,
                'exchanges': exchanges,
                'markets': markets,
                'rates': rates,
            }
        }

        return data

    @task(task_id='load_data_to_warehouse')
    def load_data_to_warehouse_task(**context) -> None:
        """
        Load data into warehouse.
        :param context: The context containing extracted data.
        :return: None.
        """
        # Pull data from XCom
        data = context['ti'].xcom_pull(task_ids='extract_data_from_api', key='return_value')

        # Create Snowflake connection
        conn = _get_snowflake_conn(
            database=SNOWFLAKE_CONFIG['database'],
            schema=SNOWFLAKE_CONFIG['schema_bronze'],
            warehouse=SNOWFLAKE_CONFIG['warehouse'],
        )
        if conn is None:
            raise

        # Process each data entity
        for table_name, content in data['data'].items():
            snowflake_table_name = table_name.upper()
            logger.info(f'Inserting data into "{snowflake_table_name}" table...')
            ts_val = datetime.datetime.fromtimestamp(content['timestamp'] / 1000.0)
            json_val = json.dumps(content['data'])

            sql = f'''
                INSERT INTO {snowflake_table_name} ("ingest_time", "api_response") 
                SELECT %s, PARSE_JSON(%s)
            '''
            logger.info(f'Executing SQL: {sql} with timestamp: {ts_val} and data length: {len(json_val)}')

            # Pass values as a tuple in the second argument
            _execute_query(conn, sql, (ts_val, json_val))

            try:
                logger.debug(f'Inserting timestamp: {ts_val}, data: {json_val[:100]}...')  # Log first 100 chars of data
            except Exception as e:
                logger.error(f'Failed to insert data into {snowflake_table_name}: {e}')
                continue

            # records = content['data']
            #
            # # Skip loading if no records
            # if not records:
            #     logger.warning(f'Skipping "{table_name}" dataset - no records found.')
            #     continue
            #
            # # Create DataFrame
            # df = pd.DataFrame(records)
            # df['timestamp'] = content['timestamp']
            #
            # if 'tokens' in df.columns:
            #     # Use json.dumps to convert Python objects (like lists of dicts)
            #     # into valid JSON strings (which map to Snowflake VARCHAR/VARIANT).
            #     df['tokens'] = df['tokens'].apply(
            #         lambda x: json.dumps(x) if pd.notna(x) and x is not None else None
            #     )
            #
            # df.columns = [col.upper() for col in df.columns]
            #
            # # Load data into Snowflake
            # success, nchunks, nrows, _ = write_pandas(conn, df, snowflake_table_name)
            # logger.debug(
            #     f'Success: {success}, Chunks: {nchunks}, Rows: {nrows} inserted into "{snowflake_table_name}".')

        # Close the database connection
        conn.close()

    # --- Define task dependencies ---
    chain(
        # create_warehouse_structure_task(),
        extract_data_from_api_task(),
        load_data_to_warehouse_task()
    )


exchange_data_dag()
