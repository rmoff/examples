# Minimal Iceberg Stack: DuckDB + MinIO

A bare-bones Apache Iceberg environment for local development and testing.

## Stack

- **MinIO** - S3-compatible object storage
- **Iceberg REST Catalog** - Lightweight catalog service
- **DuckDB** - Query engine with Iceberg support

![](minio01.excalidraw.png)

## Quick Start

```bash
docker compose up -d
```

Access DuckDB:
```bash
docker compose exec duckdb duckdb
```

## Writing Data

```sql
-- Install and load extensions
INSTALL iceberg;
INSTALL httpfs;
LOAD iceberg;
LOAD httpfs;

-- Configure S3 access for MinIO
CREATE SECRET s3_secret (
    TYPE S3,
    KEY_ID 'admin',
    SECRET 'password',
    REGION 'us-east-1',
    ENDPOINT 'minio:9000',
    USE_SSL false,
    URL_STYLE 'path'
);

-- Create Iceberg catalog authentication (token can be any value)
CREATE SECRET iceberg_secret (
    TYPE iceberg,
    TOKEN 'dummy'
);

-- Connect to the Iceberg catalog
ATTACH 'warehouse' AS iceberg_catalog (
    TYPE iceberg,
    ENDPOINT 'http://iceberg-rest:8181',
    SECRET iceberg_secret
);

-- Create a schema
CREATE SCHEMA iceberg_catalog.demo;

-- Create a table
CREATE TABLE iceberg_catalog.demo.users (
    id INTEGER,
    name VARCHAR,
    email VARCHAR,
    created_at TIMESTAMP
);

-- Insert data
INSERT INTO iceberg_catalog.demo.users VALUES
    (1, 'Alice', 'alice@example.com', CURRENT_TIMESTAMP),
    (2, 'Bob', 'bob@example.com', CURRENT_TIMESTAMP),
    (3, 'Charlie', 'charlie@example.com', CURRENT_TIMESTAMP);
```

## Reading Data

```sql
-- Query the table
SELECT * FROM iceberg_catalog.demo.users;

-- View table metadata
SELECT * FROM iceberg_metadata('iceberg_catalog.demo.users');
```

Snapshots & time travel:

```sql
-- View snapshots (for time travel)
SELECT * FROM iceberg_snapshots('iceberg_catalog.demo.users');

-- Query a specific snapshot (time travel using snapshot_from_id)
SELECT * FROM iceberg_scan('iceberg_catalog.demo.users', snapshot_from_id => <snapshot_id_from_above>);
```

## Viewing Data in MinIO

### Web Console

Access the MinIO console at http://localhost:9001

- **Username**: `admin`
- **Password**: `password`

Navigate to the `warehouse` bucket to see your Iceberg table structure:
- `warehouse/demo/users/metadata/` - Table metadata (JSON files)
- `warehouse/demo/users/data/` - Parquet data files

### CLI

Use the MinIO client to browse the bucket:

```bash
# List all buckets
docker compose exec mc mc ls minio

# List warehouse bucket contents
docker compose exec mc mc ls minio/warehouse/

# List Iceberg table structure
docker compose exec mc mc ls --recursive minio/warehouse/demo/

# View table metadata files
docker compose exec mc mc ls minio/warehouse/demo/users/metadata/

# View data files (Parquet)
docker compose exec mc mc ls minio/warehouse/demo/users/data/
```

## Cleanup

```bash
docker compose down
```

To remove data volumes:
```bash
docker compose down -v
```
