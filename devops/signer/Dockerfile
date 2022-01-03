FROM dyne/devuan:chimaera
ENV debian bullseye

LABEL maintainer="Denis Roio <jaromil@dyne.org>" \
	  homepage="https://eth.dyne.org"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV GO111MODULE on
ENV GETH_VERSION 1.10.14
ENV GO_VERSION 1.17

RUN apt-get update -y -q \
	&& apt-get install -y -q gcc build-essential supervisor daemontools curl \
	&& apt-get -y -q autoremove && apt-get -y -q clean

RUN wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -zxf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local/ \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

ENV GOBIN /usr/local/go/bin

RUN go get -d github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && cd go/pkg/mod/github.com/ethereum/go-ethereum@v$GETH_VERSION \
    && go install ./...

RUN mkdir -p  /var/lib/dyneth/log /var/lib/dyneth/keys /var/lib/dyneth/data \
    && useradd -d /var/lib/dyneth dyneth \
    && chown -R dyneth:dyneth /var/lib/dyneth \
    && echo "PS1='🅳 🆈 🅽 🅴 🆃 🅷 # '" >> /root/.bashrc


COPY ./conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./conf/geth.conf /etc/geth.conf
COPY ./conf/geth-genesis.conf /etc/genesis.conf
COPY ./scripts/start-geth.sh /usr/local/bin/start-geth.sh

CMD supervisord -c /etc/supervisor/supervisord.conf
