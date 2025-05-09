FROM apache/flink:2.0.0-java21
SHELL ["/bin/bash", "-c"]

# Install some useful tools
RUN apt-get update && \
    apt-get install -y neovim tree lnav unzip

RUN echo "Purge apt artifacts" && \
    apt-get purge -y --auto-remove $build_deps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER flink

WORKDIR /opt/flink

# Set the launch command
CMD ./bin/start-cluster.sh && sleep infinity
