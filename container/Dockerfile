ARG GETH_VERSION
ARG SOLC_VERSION
ARG ALPINE_VERSION
FROM scratch

FROM dyne/geth:$GETH_VERSION as geth
FROM dyne/solc:$SOLC_VERSION as solc
FROM alpine:$ALPINE_VERSION

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV GO111MODULE on
LABEL maintainer="Denis Roio <jaromil@dyne.org>" \
	  homepage="https://eth.dyne.org"

# echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
RUN apk add --no-cache ca-certificates curl mawk shadow bash libgcc libstdc++ \
    py3-pip gcc python3-dev musl-dev linux-headers ## python3 web3
RUN pip install web3 && pip cache purge

RUN curl -so /usr/local/bin/zenroom \
    https://files.dyne.org/zenroom/nightly/zenroom-linux-amd64 \
    && chmod +x /usr/local/bin/zenroom
COPY --from=geth /go/bin/* /usr/local/bin/
COPY --from=solc /usr/local/bin/solc /usr/local/bin
COPY genesis.conf /etc/dyneth/genesis.conf
COPY init-geth.sh /
COPY start-geth-api.sh /
COPY start-geth-signer.sh /
ARG VERSION
ENV VERSION $VERSION

# EXPOSE $CONF_API_PORT $CONF_P2P_PORT $CONF_P2P_PORT/udp

RUN mkdir -p /var/mail && useradd -m geth --uid=1000 \
    && echo "geth:geth" | chpasswd \
    && mkdir -p /home/geth/.ethereum \
    && chown -R 1000:1000 /home/geth/.ethereum \
    && mkdir /contracts

USER geth
WORKDIR /home/geth
CMD sh /start-geth-api.sh
