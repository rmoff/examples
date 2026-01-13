#!/bin/bash
set -e

echo ""
echo "    ░▒▓██████████████████████████████████████████████▓▒░"
echo "    ▒                                                      ▒"
echo "    ▓      ___                    ▓▓▓▓▓                    ▓"
echo "    █  ___( o)>  ┌───────────┐  ▓▓▓▓▓▓▓  ▒▒▒▒▒▒▒           █"
echo "    █  \\ <_. )   │  DUCKDB   │  ▓░Local S3 ░▓  ▒▒▒▒        █"
echo "    █   \`---'    └───────────┘   ▓CloudServer▒             █"
echo "    ▓           ┏━━━━━━━━━━━━━┓        ░░░                 ▓"
echo "    ▒  ≋≋≋≋≋≋≋  ┃  ICEBERG    ┃  ≋≋≋≋≋≋≋≋  Smoke test      ▒"
echo "    ░  ≋≋≋≋≋≋≋  ┗━━━━━━━━━━━━━┛  ≋≋≋≋≋≋≋≋                  ░"
echo "    ░▒▓██████████████████████████████████████████████████▓▒░"
echo ""

echo "Waiting for all services to be ready..."
until docker compose exec mc mc ls cloudserver >/dev/null 2>&1; do
    echo "...waiting for CloudServer..."
    sleep 2
done
until curl -sf http://localhost:8181/v1/config >/dev/null 2>&1; do
    echo "...waiting for Iceberg REST..."
    sleep 2
done
echo ""

echo "1. Checking CloudServer buckets (before)..."
docker compose exec mc mc ls cloudserver
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
    KEY_ID 'admin',
    SECRET 'password',
    REGION 'us-east-1',
    ENDPOINT 'cloudserver:8000',
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
CREATE SECRET s3_secret (TYPE S3, KEY_ID 'admin', SECRET 'password', REGION 'us-east-1', ENDPOINT 'cloudserver:8000', USE_SSL false, URL_STYLE 'path');
CREATE SECRET iceberg_secret (TYPE iceberg, TOKEN 'dummy');
ATTACH 'warehouse' AS cat (TYPE iceberg, ENDPOINT 'http://iceberg-rest:8181', SECRET iceberg_secret);
SELECT * FROM cat.test.products ORDER BY id;
"
echo ""

echo "4. Checking CloudServer bucket contents (after)..."
docker compose exec mc mc ls --recursive cloudserver/warehouse/test/products/ | head -10
echo ""
