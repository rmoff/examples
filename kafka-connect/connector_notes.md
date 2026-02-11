# Apache Iceberg Kafka Connect

NOTE: This doc was written by Claude Code (Opus 4.6) about troubleshooting the connector during testing

See [README](README.md) for details on running the test.

---

The connector works correctly but has a **critical requirement for continuous data flow**. This commonly trips up users during initial testing/evaluation when they send a few test records and expect immediate results.

### Key Findings

✅ **Connector functions correctly** with continuous data streams
⚠️ **Requires ongoing data arrival** for Iceberg snapshot commits
❌ **Appears broken** when tested with static datasets

## The Core Issue: Continuous Data Requirement

### What Happens with Static Data (Common Test Scenario)

**Scenario**: User evaluating the connector
1. Produces 5 test records to Kafka
2. Configures connector
3. Waits for data to appear
4. Sees "committed to 0 table(s)" in logs
5. Queries table → 0 rows
6. Concludes connector is broken

**What's Actually Happening**:
- ✅ Records consumed from Kafka
- ✅ Data written to Parquet files in S3
- ❌ Iceberg snapshot NOT committed to catalog
- **Result**: Data exists but isn't queryable (no snapshot reference)

**Test Results**:
```
Data in Parquet file (direct read):  5 records ✅
Data via Iceberg catalog (query):    0 rows ❌
Snapshot ID in metadata:              -1 (none)
Commit logs:                          "committed to 0 table(s)"
```

### What Happens with Continuous Data (Production Use)

**Scenario**: Streaming workload
1. Data continuously flows to Kafka topic (e.g., 1 message/second)
2. Connector consumes and writes data
3. Commits succeed regularly
4. Data is queryable

**Test Results**:
```
Records produced:              100+ (continuous stream)
Records committed:             80
Iceberg snapshots created:     2
Commit logs:                   "committed to 1 table(s)" ✅
Data queryable:                80 rows ✅
Snapshot ID in metadata:       5988198648919712218 (real snapshot)
```

## Why This Happens

The connector uses Kafka consumer groups for commit coordination between tasks. When data stops flowing:

1. Commit cycle begins
2. Control consumer joins coordination group
3. **No new data arrives** → Consumer appears idle
4. Kafka broker evicts consumer as inactive (`UnknownMemberIdException`)
5. Commit coordination fails → timeout
6. Snapshot not committed

**When data flows continuously**, consumers remain active and coordination succeeds.

**Related Issue**: [Apache Iceberg #11796](https://github.com/apache/iceberg/issues/11796) - "Kafka Connect Sporadic Commit Delay"
> "When no new messages arrive since the last commit, the system still waits for the full timeout period"

Status: Known limitation (Closed - Not Planned)

## Configuration: What Actually Matters

**Working configuration**:
```json
{
  "connector.class": "org.apache.iceberg.connect.IcebergSinkConnector",
  "tasks.max": "1",
  "topics": "your-topic",

  "iceberg.catalog.type": "rest",
  "iceberg.catalog.uri": "https://catalog:8181",
  "iceberg.catalog.warehouse": "s3://bucket/warehouse/",
  "iceberg.catalog.s3.access-key-id": "${env:AWS_ACCESS_KEY_ID}",
  "iceberg.catalog.s3.secret-access-key": "${env:AWS_SECRET_ACCESS_KEY}",

  "iceberg.tables": "namespace.tablename",
  "iceberg.tables.auto-create-enabled": "true",

  "key.converter": "org.apache.kafka.connect.storage.StringConverter",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter.schemas.enable": "true"
}
```

### What Doesn't Help (Random Jiggling)

These parameters were tested during troubleshooting but have **no effect**:

```json
{
  "iceberg.kafka.session.timeout.ms": "30000",
  "iceberg.kafka.heartbeat.interval.ms": "10000",
  "consumer.auto.offset.reset": "earliest"
}
```

**Why they don't work**:
- The first two parameters are **not recognized** by the connector (they appear in "unused configurations" warnings)
- `consumer.auto.offset.reset` only affects where to start reading, not commit behavior

These were investigated based on the hypothesis that Kafka consumer session timeouts were the issue, but testing proved:
1. Connector doesn't use these parameters
2. No amount of timeout tuning overcomes the coordination issue
3. The problem is architectural, not configurational

## Testing the Connector

**Don't do this** (will appear broken):
```bash
# Produce 5 records then stop
kafka-console-producer --topic test
> record1
> record2
> record3
^D

# Check results → 0 rows (appears broken!)
```

**Do this instead** (will work):
```bash
# Continuous producer
while true; do
  echo "{\"id\": $RANDOM, \"ts\": $(date +%s)}"
  sleep 1
done | kafka-console-producer --topic test

# Check results after 30-60 seconds → rows appear ✅
```

## Troubleshooting

### "committed to 0 table(s)" in logs

**Diagnosis**: Commit coordination failing

**Check**:
```bash
# Is data continuously flowing?
kafka-consumer-groups --describe --group connect-iceberg-* --bootstrap-server localhost:9092

# Look for LAG column - is it decreasing over time?
# If LAG stays at same number, no new data is arriving
```

**Fix**: Ensure topic has continuous message flow

### Data in S3 but not queryable

**Diagnosis**: Parquet files written but snapshot not committed

**Verify data exists**:
```bash
# Direct parquet read (bypasses Iceberg catalog)
duckdb -c "SELECT COUNT(*) FROM read_parquet('s3://bucket/path/data/*.parquet')"
```

**Check snapshot status**:
```bash
# Look at metadata
aws s3 cp s3://bucket/path/metadata/v1.metadata.json - | jq '.["current-snapshot-id"]'
# -1 = no snapshot committed
```

**Fix**: This confirms the continuous data issue. Start sending data continuously.

### Control consumer group errors

**Symptoms**: Logs show `UnknownMemberIdException` or "coordinator is not aware of this member"

**Diagnosis**: This is the root cause of commit failures

```
[Consumer clientId=..., groupId=cg-control-...]
JoinGroup failed: The coordinator is not aware of this member.
```

**Meaning**: Control consumer being evicted due to apparent inactivity (no data flowing)

**Fix**: Not a configuration issue - ensure continuous data flow


## Test Evidence

### Test Environment
- Connector: 1.9.2
- Kafka Connect: Confluent Platform 8.0.3
- Catalog: REST catalog
- Storage: S3-compatible (SeaweedFS)

See [https://github.com/rmoff/examples/main/kafka-connect](https://github.com/rmoff/examples/tree/main/kafka-connect)

### Continuous Data Test Results

**S3 Files Created**:
```
data/00001-*.parquet (1.3KB)
data/00001-*.parquet (931B)
metadata/00001-*.metadata.json (2.4KB)
metadata/00002-*.metadata.json (3.7KB)
metadata/snap-5988198648919712218-*.avro (4.4KB)
metadata/snap-6398507709946356664-*.avro (4.3KB)
```

**Commit Logs**:
```
[2026-02-11 17:01:04] INFO Commit 02b32fed complete,
  committed to 1 table(s), valid-through 2026-02-11T17:00:54.320Z
[2026-02-11 17:01:14] INFO Commit 75533f28 complete,
  committed to 1 table(s), valid-through 2026-02-11T17:01:06.542Z
```

**Query Results**:
```sql
SELECT COUNT(*), MIN(id), MAX(id)
FROM catalog.default.test_table;

-- Result: 80 rows, ids 1-80
```

### Static Data Test Results

**S3 Files Created**:
```
data/00001-*.parquet (943 bytes)
metadata/00000-*.metadata.json (1.1KB)
```

**Commit Logs**:
```
[timestamp] INFO Commit timeout reached. Commit ID: <uuid>
[timestamp] INFO Commit <uuid> complete, committed to 0 table(s)
```

**Direct Parquet Read** (bypassing Iceberg):
```sql
SELECT * FROM read_parquet('s3://warehouse/data/*.parquet');
-- Result: All 5 records present in parquet file
```

**Iceberg Query**:
```sql
SELECT * FROM catalog.default.test_table;
-- Result: 0 rows (no snapshot committed)
```

**Metadata**:
```json
{
  "current-snapshot-id": -1,
  "snapshots": []
}
```
