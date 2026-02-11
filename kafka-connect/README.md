# Kafka Connect with Iceberg Sink

Test stack for Apache Iceberg Kafka Connect sink connector.

See also [LLM notes](connector_notes.md) re committing problems.

## Start the stack

```bash
docker compose up -d
```

Wait for Kafka Connect to be ready:

```bash
kcctl info
```

## Send test data to Kafka

```bash
echo '{"schema":{"type":"struct","fields":[{"field":"id","type":"int32"},{"field":"name","type":"string"},{"field":"ts","type":"int64"}]},"payload":{"id":1,"name":"Alice","ts":1705900800000}}
{"schema":{"type":"struct","fields":[{"field":"id","type":"int32"},{"field":"name","type":"string"},{"field":"ts","type":"int64"}]},"payload":{"id":2,"name":"Bob","ts":1705900801000}}
{"schema":{"type":"struct","fields":[{"field":"id","type":"int32"},{"field":"name","type":"string"},{"field":"ts","type":"int64"}]},"payload":{"id":3,"name":"Charlie","ts":1705900802000}}' | \
  kcat -b localhost:9092 -t test -P
```

## Create the Iceberg sink connector

```bash
kcctl apply -f - <<'EOF'
{
  "name": "iceberg-sink",
  "config": {
    "connector.class": "org.apache.iceberg.connect.IcebergSinkConnector",
    "tasks.max": "1",
    "topics": "test",
    "iceberg.catalog.type": "rest",
    "iceberg.catalog.uri": "http://iceberg-rest:8181",
    "iceberg.catalog.warehouse": "s3://warehouse/",
    "iceberg.catalog.s3.endpoint": "http://seaweedfs:9000",
    "iceberg.catalog.s3.access-key-id": "admin",
    "iceberg.catalog.s3.secret-access-key": "password",
    "iceberg.catalog.s3.path-style-access": "true",
    "iceberg.tables": "default.test",
    "iceberg.tables.auto-create-enabled": "true",
    "iceberg.control.commit.interval-ms": "1000",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true"
  }
}
EOF
```

Check connector status:

```bash
kcctl get connectors
kcctl describe connector iceberg-sink
```

## Query with DuckDB

```bash
duckdb
```

```sql
INSTALL iceberg; LOAD iceberg;
INSTALL httpfs; LOAD httpfs;

CREATE SECRET s3_secret (
    TYPE S3,
    KEY_ID 'admin',
    SECRET 'password',
    REGION 'us-east-1',
    ENDPOINT 'localhost:9000',
    USE_SSL false,
    URL_STYLE 'path'
);

CREATE SECRET iceberg_secret (TYPE iceberg, TOKEN 'dummy');

ATTACH 'warehouse' AS cat (TYPE iceberg, ENDPOINT 'http://localhost:8181', SECRET iceberg_secret);

SELECT * FROM cat.default.test;
```

## Troubleshooting

Check connector logs:

```bash
docker logs kafka-connect --tail 100 -f
```

Check SeaweedFS bucket contents:

```bash
docker exec mc mc ls -r seaweedfs/warehouse
```

Check Iceberg REST catalog:

```bash
curl -s http://localhost:8181/v1/namespaces | jq
curl -s http://localhost:8181/v1/namespaces/default/tables | jq
```

## Tear down

```bash
docker compose down -v
```
