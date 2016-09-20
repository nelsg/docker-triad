#!/bin/sh
# usage: ./env-rm.sh
#    remove Swarm cluster

eval $(docker-machine env -u)
docker-machine rm -f -y consul master slave1
