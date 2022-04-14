FROM mhart/alpine-node:10

RUN apk add git
RUN git clone https://github.com/goerli/ethstats-server ethstats-server
WORKDIR ethstats-server
RUN npm install
RUN npm install -g grunt-cli
RUN grunt

EXPOSE  3000
CMD ["npm", "start"]
