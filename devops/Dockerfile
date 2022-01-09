FROM golang:1.17-alpine as builder

LABEL maintainer="Denis Roio <jaromil@dyne.org>" \
	  homepage="https://eth.dyne.org"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV GO111MODULE on
ENV GETH_VERSION 1.10.14
ENV SOLC_VERSION 0.8.11

RUN apk add --no-cache gcc g++ musl-dev linux-headers git make cmake \
    boost-dev boost-static curl

RUN go get -d github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && cd pkg/mod/github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && go install ./...

RUN git clone https://github.com/ethereum/solidity \
    && cd solidity && git checkout tags/v${SOLC_VERSION} \
    && mkdir build && cd build && cmake .. && make solc && make install -C solc

FROM alpine:latest

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache ca-certificates curl mawk shadow daemontools bash

RUN curl -so /usr/local/bin/zenroom \
    https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 \
    && chmod +x /usr/local/bin/zenroom
COPY --from=builder /go/bin/* /usr/local/bin/
COPY --from=builder /usr/local/bin/solc /usr/local/bin
COPY genesis.conf /etc/dyneth/genesis.conf
COPY init-geth.sh /
COPY start-geth-api.sh /
COPY start-geth-signer.sh /

ARG VERSION
ENV VERSION $VERSION
ARG NETWORK_ID
ENV CONF_NETWORK_ID $NETWORK_ID
ARG P2P_PORT
ENV CONF_P2P_PORT $P2P_PORT
ARG API_PORT
ENV CONF_API_PORT $API_PORT

EXPOSE $CONF_API_PORT $CONF_P2P_PORT $CONF_P2P_PORT/udp

RUN useradd -m geth --uid=1000 \
    && echo "geth:geth" | chpasswd \
    && mkdir -p /home/geth/.ethereum \
    && chown -R 1000:1000 /home/geth/.ethereum

CMD sh /start-geth-api.sh
