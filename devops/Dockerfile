FROM golang:1.17-alpine as builder

LABEL maintainer="Denis Roio <jaromil@dyne.org>" \
	  homepage="https://eth.dyne.org"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV GO111MODULE on
ENV GETH_VERSION 1.10.14

RUN apk add --no-cache gcc musl-dev linux-headers git make

RUN go get -d github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && cd pkg/mod/github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && go install ./...

FROM alpine:latest
RUN apk add --no-cache ca-certificates curl awk
RUN curl -o /usr/local/bin/zenroom \
    https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 \
    && chmod +x /usr/local/bin/zenroom
COPY --from=builder /go/bin/* /usr/local/bin/
COPY genesis.conf /etc/dyneth/genesis.conf
COPY init-geth.sh /
COPY start-geth-api.sh /
COPY start-geth-signer.sh /

EXPOSE 8545 8546 30303 30303/udp

CMD sh /start-geth-api.sh
