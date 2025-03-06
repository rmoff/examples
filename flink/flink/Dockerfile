FROM apache/flink:1.20.1-java17
SHELL ["/bin/bash", "-c"]

# Install some useful tools
RUN apt-get update && \
    apt-get install -y neovim tree lnav unzip

RUN echo "Purge apt artifacts" && \
    apt-get purge -y --auto-remove $build_deps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/duckdb/duckdb/releases/download/v1.2.1/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-amd64.zip

USER flink

WORKDIR /opt/flink

# Set the launch command
CMD ./bin/start-cluster.sh && sleep infinity
