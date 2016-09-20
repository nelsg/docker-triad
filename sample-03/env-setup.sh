# usage: source env-setup.sh [-q]
#    modifies environment for docker-machine and its hosts

export KV_IP=$(docker-machine ip consul)
export MASTER_IP=$(docker-machine ip master)
export SLAVE1_IP=$(docker-machine ip slave1)
