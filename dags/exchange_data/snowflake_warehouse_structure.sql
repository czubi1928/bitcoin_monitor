-------------------------
-- WAREHOUSE (Compute) --
-------------------------
CREATE WAREHOUSE IF NOT EXISTS {warehouse} WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

--------------
-- DATABASE --
--------------
USE WAREHOUSE {warehouse};

CREATE DATABASE IF NOT EXISTS {database};

-------------
-- SCHEMAS --
-------------

USE DATABASE {database};

CREATE SCHEMA IF NOT EXISTS {schema_bronze};

CREATE SCHEMA IF NOT EXISTS {schema_silver};

CREATE SCHEMA IF NOT EXISTS {schema_gold};

-----------------------------
-- BRONZE SCHEMA STRUCTURE --
-----------------------------
USE SCHEMA {schema_bronze};

CREATE TABLE IF NOT EXISTS ASSETS (
    id                          VARCHAR,
    rank                        VARCHAR,
    symbol                      VARCHAR,
    name                        VARCHAR,
    supply                      VARCHAR,
    maxSupply                   VARCHAR,
    marketCapUsd                VARCHAR,
    volumeUsd24Hr               VARCHAR,
    priceUsd                    VARCHAR,
    changePercent24Hr           VARCHAR,
    vwap24Hr                    VARCHAR,
    explorer                    VARCHAR,
    tokens                      VARIANT,
    timestamp                   BIGINT
);

CREATE TABLE IF NOT EXISTS EXCHANGES (
    exchangeId                  VARCHAR,
    name                        VARCHAR,
    rank                        VARCHAR,
    percentTotalVolume          VARCHAR,
    volumeUsd                   VARCHAR,
    tradingPairs                VARCHAR,
    socket                      BOOLEAN,
    exchangeUrl                 VARCHAR,
    updated                     BIGINT,
    timestamp                   BIGINT
);

CREATE TABLE IF NOT EXISTS MARKETS (
    exchangeId                  VARCHAR,
    rank                        VARCHAR,
    baseSymbol                  VARCHAR,
    baseId                      VARCHAR,
    quoteSymbol                 VARCHAR,
    quoteId                     VARCHAR,
    priceQuote                  VARCHAR,
    priceUsd                    VARCHAR,
    volumeUsd24Hr               VARCHAR,
    percentExchangeVolume       VARCHAR,
    tradesCount24Hr             BIGINT,
    updated                     BIGINT,
    timestamp                   BIGINT
);

CREATE TABLE IF NOT EXISTS RATES (
    id                          VARCHAR,
    symbol                      VARCHAR,
    currencySymbol              VARCHAR,
    type                        VARCHAR,
    rateUsd                     VARCHAR,
    timestamp                   BIGINT
);
