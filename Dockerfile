FROM golang:latest as builder

WORKDIR $GOPATH/src/go.k6.io/k6

ADD . .

# Install system packages and dependencies.
RUN set -eux && \
    apt-get update && apt-get install -y --no-install-recommends --no-install-suggests && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/*

RUN go install go.k6.io/xk6/cmd/xk6@latest

RUN xk6 build --with github.com/grafana/xk6-output-influxdb=. --output /tmp/k6


FROM debian:stable-slim

RUN set -eux && \
    apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    ca-certificates && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/*

RUN addgroup --gid 12345 k6 && \
    adduser --disabled-password --gecos "" --uid 12345 --gid 12345 k6

COPY --from=builder /tmp/k6 /usr/bin/k6

USER 12345

WORKDIR /home/k6

ENTRYPOINT ["k6"]
