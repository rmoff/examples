#!/bin/bash
set -e

echo ""
echo "    ░▒▓██████████████████████████████████████████████████▓▒░"
echo "    ▒                                                      ▒"
echo "    ▓      ___                    ▓▓▓▓▓                    ▓"
echo "    █  ___( o)>  ┌───────────┐  ▓▓▓▓▓▓▓  ▒▒▒▒▒▒▒           █"
echo "    █  \\ <_. )   │  DUCKDB   │  ▓░Local S3 ░▓  ▒▒▒▒        █"
echo "    █   \`---'    └───────────┘   ▓▓ Garage ▒▒▒             █"
echo "    ▓           ┏━━━━━━━━━━━━━┓        ░░░                 ▓"
echo "    ▒  ≋≋≋≋≋≋≋  ┃  ICEBERG    ┃  ≋≋≋≋≋≋≋≋  Smoke test      ▒"
echo "    ░  ≋≋≋≋≋≋≋  ┗━━━━━━━━━━━━━┛  ≋≋≋≋≋≋≋≋                  ░"
echo "    ░▒▓██████████████████████████████████████████████████▓▒░"
echo ""

echo "1. Checking Garage buckets (before)..."
docker compose exec garage /garage -c /etc/garage.toml bucket list
echo ""

echo "2. Creating Iceberg table and inserting data..."
docker compose exec duckdb duckdb -c "
INSTALL iceberg;
INSTALL httpfs;
LOAD iceberg;
LOAD httpfs;

-- Configure S3
CREATE SECRET s3_secret (
    TYPE S3,
    KEY_ID 'GKb69252a3b0643e8bd08d4cd4',
    SECRET '9115be9c9e4994306a4176543b0db461f4eb04c5c8a388676d1b57392d0f4e93',
    REGION 'us-east-1',
    ENDPOINT 'garage:3900',
    USE_SSL false,
    URL_STYLE 'path'
);

-- Configure Iceberg catalog
CREATE SECRET iceberg_secret (TYPE iceberg, TOKEN 'dummy');
ATTACH 'warehouse' AS cat (TYPE iceberg, ENDPOINT 'http://iceberg-rest:8181', SECRET iceberg_secret);

-- Create schema and table
CREATE SCHEMA IF NOT EXISTS cat.test;
DROP TABLE IF EXISTS cat.test.products;
CREATE TABLE cat.test.products (id INTEGER, name VARCHAR, price DECIMAL(10,2));

-- Insert data
INSERT INTO cat.test.products VALUES
    (1, 'Widget', 9.99),
    (2, 'Gadget', 19.99),
    (3, 'Doohickey', 14.99);

-- Query data
SELECT 'Row count:' as metric, COUNT(*)::VARCHAR as value FROM cat.test.products
UNION ALL
SELECT 'Total value:', CAST(SUM(price) AS VARCHAR) FROM cat.test.products;
"
echo ""

echo "3. Verifying data in DuckDB..."
docker compose exec duckdb duckdb -c "
INSTALL iceberg;
INSTALL httpfs;
LOAD iceberg;
LOAD httpfs;
CREATE SECRET s3_secret (TYPE S3, KEY_ID 'GKb69252a3b0643e8bd08d4cd4', SECRET '9115be9c9e4994306a4176543b0db461f4eb04c5c8a388676d1b57392d0f4e93', REGION 'us-east-1', ENDPOINT 'garage:3900', USE_SSL false, URL_STYLE 'path');
CREATE SECRET iceberg_secret (TYPE iceberg, TOKEN 'dummy');
ATTACH 'warehouse' AS cat (TYPE iceberg, ENDPOINT 'http://iceberg-rest:8181', SECRET iceberg_secret);
SELECT * FROM cat.test.products ORDER BY id;
"
echo ""

echo "4. Listing bucket objects with mc..."
docker compose exec mc mc ls --recursive garage/warehouse/
echo ""
