# Getting started
We are using `redis` to count the number of connections. The keys used in redis are `logcli:timestamp` and `connection`.

Source the `init.sh` file to setup the environmental variables. The lua script could be slow, you can see the progress with `redis-cli get logcli:timestamp`.
