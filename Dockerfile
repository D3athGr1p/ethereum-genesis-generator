FROM golang:1.19 as builder
RUN git clone https://github.com/protolambda/eth2-testnet-genesis.git \
    && cd eth2-testnet-genesis \
    && git checkout v0.8.0 \
    && go install . 
RUN go install github.com/protolambda/eth2-val-tools@v0.1.1
RUN go install github.com/protolambda/zcli@v0.6.0

FROM debian:latest
WORKDIR /work
VOLUME ["/config", "/data"]
EXPOSE 8000/tcp
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates build-essential python3 python3-dev python3-pip gettext-base jq wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY apps /apps
RUN cd /apps/el-gen && pip3 install --break-system-packages -r requirements.txt
COPY --from=builder /go/bin/eth2-testnet-genesis /usr/local/bin/eth2-testnet-genesis
COPY --from=builder /go/bin/eth2-val-tools /usr/local/bin/eth2-val-tools
COPY --from=builder /go/bin/zcli /usr/local/bin/zcli
COPY config-example /config
COPY entrypoint.sh .
ENTRYPOINT [ "/work/entrypoint.sh" ]
