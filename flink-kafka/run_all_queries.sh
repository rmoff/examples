#!/bin/bash

# Directory for logs
LOG_DIR="query_logs"
mkdir -p "$LOG_DIR"

# Function to run a query with timeout
run_query() {
    local sql_file=$1
    local filename=$(basename "$sql_file")
    local log_file="${LOG_DIR}/${filename%.sql}.log"

    echo "Running query: $sql_file"
    echo "Logging output to: $log_file"

    # Run the SQL client with timeout
    docker compose exec -it jobmanager bash -c "./bin/sql-client.sh -i /data/startup_upsert_append.sql -f $sql_file" > "$log_file" 2>&1

    # Sleep a bit between queries
    echo "Completed: $sql_file"
    echo "----------------------------------------"
}

# Regular joins
echo "Running regular join queries..."
run_query "/data/queries/a-a-reg-inner.sql"
run_query "/data/queries/a-a-reg-left-outer.sql"
run_query "/data/queries/a-a-reg-right-outer.sql"
run_query "/data/queries/a-a-reg-full-outer.sql"

run_query "/data/queries/a-u-reg-inner.sql"
run_query "/data/queries/a-u-reg-left-outer.sql"
run_query "/data/queries/a-u-reg-right-outer.sql"
run_query "/data/queries/a-u-reg-full-outer.sql"

run_query "/data/queries/u-a-reg-inner.sql"
run_query "/data/queries/u-a-reg-left-outer.sql"
run_query "/data/queries/u-a-reg-right-outer.sql"
run_query "/data/queries/u-a-reg-full-outer.sql"

run_query "/data/queries/u-u-reg-inner.sql"
run_query "/data/queries/u-u-reg-left-outer.sql"
run_query "/data/queries/u-u-reg-right-outer.sql"
run_query "/data/queries/u-u-reg-full-outer.sql"

# Temporal joins
echo "Running temporal join queries..."
run_query "/data/queries/a-a-temporal-inner.sql"
run_query "/data/queries/a-a-temporal-left-outer.sql"
run_query "/data/queries/a-a-temporal-right-outer.sql"
run_query "/data/queries/a-a-temporal-full-outer.sql"

run_query "/data/queries/a-u-temporal-inner.sql"
run_query "/data/queries/a-u-temporal-left-outer.sql"
run_query "/data/queries/a-u-temporal-right-outer.sql"
run_query "/data/queries/a-u-temporal-full-outer.sql"

run_query "/data/queries/u-a-temporal-inner.sql"
run_query "/data/queries/u-a-temporal-left-outer.sql"
run_query "/data/queries/u-a-temporal-right-outer.sql"
run_query "/data/queries/u-a-temporal-full-outer.sql"

run_query "/data/queries/u-u-temporal-inner.sql"
run_query "/data/queries/u-u-temporal-left-outer.sql"
run_query "/data/queries/u-u-temporal-right-outer.sql"
run_query "/data/queries/u-u-temporal-full-outer.sql"

echo "All queries completed"
