FROM debian:9-slim AS builder

RUN set -ex && \
    apt-get update && apt-get install -y wget unzip && \
    wget https://download.java.net/java/GA/jdk10/10/binaries/openjdk-10_linux-x64_bin.tar.gz -O jdk.tar.gz -nv && \
    mkdir -p /opt/jdk && \
    tar zxvf jdk.tar.gz -C /opt/jdk --strip-components=1 && \
    rm jdk.tar.gz && \
    rm /opt/jdk/lib/src.zip

RUN /opt/jdk/bin/jlink \
    --module-path /opt/jdk/jmods \
    --verbose \
    --add-modules java.base,java.logging,java.xml,jdk.unsupported,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument,java.xml.bind \
    --output /opt/jdk-minimal \
    --compress 2 \
    --no-header-files

# Second stagep
FROM debian:9-slim
COPY --from=builder /opt/jdk-minimal /opt/jdk-minimal

ENV JAVA_HOME=/opt/jdk-minimal
ENV PATH="$PATH:$JAVA_HOME/bin"
