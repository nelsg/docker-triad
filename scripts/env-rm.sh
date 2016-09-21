#!/bin/sh
# usage: ./env-rm.sh
#    remove Swarm cluster

eval $(docker-machine env -u)
docker-machine ls | grep virtualbox | awk '{print $1}' | xargs docker-machine rm -f -y
