# usage: source env-setup.sh [-q]
#    modifies environment for docker-machine and its hosts
KV_IP=$(docker-machine ip consul)
MASTER_IP=$(docker-machine ip master)
SLAVE1_IP=$(docker-machine ip slave1)
