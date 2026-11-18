# syntax=docker/dockerfile:1.7
ARG GOOSE_REF=main
ARG BUZZ_REF=main

FROM rust:1.82-bookworm AS builder
ARG GOOSE_REF
ARG BUZZ_REF

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    git \
    libclang-dev \
    libdbus-1-dev \
    libssl-dev \
    libsqlite3-dev \
    pkg-config \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${GOOSE_REF}" https://github.com/aaif-goose/goose.git /src/goose
WORKDIR /src/goose
RUN cargo build --release --package goose-cli

RUN git clone --depth 1 --branch "${BUZZ_REF}" https://github.com/block/buzz.git /src/buzz
WORKDIR /src/buzz
RUN cargo build --release --manifest-path crates/buzz-acp/Cargo.toml

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    libssl3 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 --shell /bin/bash coreteam

COPY --from=builder /src/goose/target/release/goose /usr/local/bin/goose
COPY --from=builder /src/buzz/target/release/buzz-acp /usr/local/bin/buzz-acp
COPY core-team.yaml /etc/core-team/agents.yaml
COPY entrypoint.sh /usr/local/bin/core-team-entrypoint

RUN mkdir -p /workspace /home/coreteam/.config/goose \
    && chown -R coreteam:coreteam /workspace /home/coreteam /etc/core-team \
    && chmod 0755 /usr/local/bin/core-team-entrypoint

ENV CORE_TEAM_CONFIG=/etc/core-team/agents.yaml
ENV CORE_TEAM_WORKSPACE=/workspace
ENV HOME=/home/coreteam
WORKDIR /workspace
VOLUME ["/workspace", "/home/coreteam/.config/goose"]
USER coreteam
ENTRYPOINT ["/usr/local/bin/core-team-entrypoint"]
