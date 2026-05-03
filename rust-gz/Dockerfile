FROM rust:alpine AS builder
WORKDIR /app
COPY ./ .
RUN apk add --no-cache musl-dev gzip curl \
    && cargo build --release

# Download CSV files from GitHub and compress them
RUN mkdir -p ./data \
    && curl -L -o ./data/country-codes.csv https://raw.githubusercontent.com/datasets/un-locode/main/data/country-codes.csv \
    && curl -L -o ./data/code-list.csv https://raw.githubusercontent.com/datasets/un-locode/main/data/code-list.csv \
    && gzip -c ./data/code-list.csv > ./data/code-list.csv.gz \
    && gzip -c ./data/country-codes.csv > ./data/country-codes.csv.gz

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/target/release/find-unlocation .
COPY --from=builder /app/data/code-list.csv.gz ./data/code-list.csv.gz
COPY --from=builder /app/data/country-codes.csv.gz ./data/country-codes.csv.gz
ENTRYPOINT ["/app/find-unlocation"]
