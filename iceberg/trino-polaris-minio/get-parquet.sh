#!/bin/bash

# Check if filename argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    echo "Example: $0 snap-707189909035517389-1-e06e486c-1679-4b8c-807e-f97771d2098e.avro"
    exit 1
fi

FILENAME="$1"

# Extract just the filename without path
BASENAME=$(basename "$FILENAME")

echo "Processing file: $BASENAME"

# Copy file from minio to container tmp
echo "Copying from minio to container..."
docker compose exec minio-client mc cp "minio/warehouse/rmoff/customers/data/$BASENAME" "/tmp/$BASENAME"

# Copy file from container to local directory
echo "Copying from container to local directory..."
docker cp "trino-polaris-minio-minio-client-1:/tmp/$BASENAME" .

duckdb -c "select * from read_parquet('$BASENAME');"

echo "Done!"
