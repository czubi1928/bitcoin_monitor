# Bitcoin Monitor - A near real-time Bitcoin price monitoring tool

## Objective

This project aims to provide a near real-time monitoring tool for Bitcoin prices. It fetches the latest Bitcoin price
data from a public API, processes it, and visualizes the trends using interactive dashboards.

## Technologies Used

- Python 3.13
  - Pandas
- Terraform
- Docker
- Airflow
- dbt
- Snowflake

## Documentation

Design notes, architecture and decisions are in [`docs/`](docs/).

## Knowledge Gained

- Data Modeling

## To-Do

- [ ] Add `dbt` transformation task to DAG in Airflow
- [ ] Implement CI/CD pipeline for automated deployments
- [ ] Add alerting mechanism for significant price changes

## Setup

### Prerequisites

- Python 3.13 installed on your machine.
- Docker installed for containerization.
- Terraform installed for infrastructure management.
- A free API key from [CoinCap Pro](https://pro.coincap.io/dashboard) to access the CoinCap API.
- A Snowflake service user for Terraform with key-pair authentication (steps "Create a Service User for Terraform"
  and "Setup Terraform Authentication" from the *terraforming-snowflake* guide).

### Running

`make setup` installs dependencies, provisions Snowflake with Terraform, starts the containers, builds the dbt
project and serves the dbt documentation. To regenerate and browse the docs later, run `make dbt_docs_generate`
and then `make dbt_docs_serve`.

## References

- CoinCap API Documentation: https://pro.coincap.io/api-docs/

## Inspiration

GitHub repository: [link](https://github.com/josephmachado/bitcoinMonitor)
