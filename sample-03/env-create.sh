#!/bin/sh
# usage: ./env-create.sh
#    create a key-value store (consul) and a Swarm cluster with one master and
#    one slave

# Save image from current local registry to local file
# $1: image:tag name
# $2: output filename
function save_image() {
  if docker history -q $1 >/dev/null 2>&1; then
    if [ ! -f $2 ]; then
      echo "Save image $1 to $2"
      docker save $1 -o $2
    else
      echo "File $2 already exists"
    fi
  else
    echo "Image $1 not exists"
  fi
}

# Load image file from local to current local registry
# $1: input filename
# $2: image:tag name. To remove, this variable is unnecessary
function load_image() {
  if docker history -q $1 >/dev/null 2>&1; then
    echo "Image $2 exists"
  else
    if [ ! -f $1 ]; then
      echo "File $1 not exists"
    else
      echo "Load $1 to $2"
      docker load -i $1
    fi
  fi
}

# Configure a Swarm by installing 'registrator' and needed images
# $1 machine name
# $2 machine ip
# $3 consul ip
function configure_swarm_node() {
  eval $(docker-machine env $1)
  load_image "../img/registrator.img" "gliderlabs/registrator:v6"
  load_image "../img/redis.img" "redis:latest"
  load_image "../img/webapp.img" "webapp:latest"
  docker run -d \
    --name=registrator \
    -h $2 \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:v6 \
    consul://$3:8500
}

#
echo Create image backup
if [ ! -d ../img ]; then
  mkdir -p ../img;
fi
eval "$(docker-machine env -u)"
save_image "gliderlabs/consul-server:latest" "../img/consul-server.img"
save_image "nginx/lb:latest" "../img/nginx-lb.img"
save_image "redis:latest" "../img/redis.img"
save_image "gliderlabs/registrator:v6" "../img/registrator.img"
save_image "webapp:latest" "../img/webapp.img"

#
echo Create and configure 'consul'
docker-machine create -d virtualbox consul
export KV_IP=$(docker-machine ip consul)
eval "$(docker-machine env consul)"
load_image "../img/consul-server.img" "gliderlabs/consul-server:latest"
docker run -d -p "${KV_IP}:8500:8500" -h consul --restart always gliderlabs/consul-server -bootstrap

#
echo Create and configure Swarm master
eval "$(docker-machine env -u)"
docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-master \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  master
export MASTER_IP=$(docker-machine ip master)
configure_swarm_node "master" ${MASTER_IP} ${KV_IP}

#
echo Create and configure Swarm slave1
eval "$(docker-machine env -u)"
docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  slave1
export SLAVE1_IP=$(docker-machine ip slave1)
configure_swarm_node "slave1" ${SLAVE1_IP} ${KV_IP}

#
echo Create overlay network on Swarm cluster
eval $(docker-machine env --swarm master)
docker network create --driver overlay --subnet=10.0.9.0/24 my-overlay
docker network ls
