#!/bin/sh
# usage: ./env-rm.sh
#    remove Swarm cluster

docker-machine rm -f -y consul master slave1
