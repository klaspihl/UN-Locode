FROM rust:alpine AS builder
WORKDIR /app
COPY ./rust-bin/ .
RUN apk add --no-cache musl-dev curl \
    && mkdir -p ./data \
    && curl -L -o ./data/country-codes.csv https://raw.githubusercontent.com/datasets/un-locode/main/data/country-codes.csv \
    && curl -L -o ./data/code-list.csv https://raw.githubusercontent.com/datasets/un-locode/main/data/code-list.csv

# Copy CSVs into src for embedding
RUN cp ./data/code-list.csv ./src/code-list.csv && cp ./data/country-codes.csv ./src/country-codes.csv

RUN cargo build --release

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/target/release/find-unlocation .
ENTRYPOINT ["/app/find-unlocation"]
