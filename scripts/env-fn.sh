#!/bin/sh
# usage: ./env-create.sh $1 $2
#    create a key-value store (consul) and a Swarm cluster with one master and
#    one slave
# $1: number of masters
# $2: number of slaves

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

function backup_all_needed_images() {
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
}

# Create a swarm node
# $1: 1=master else slave
# $2: id
function create_and_configure_swarm_node() {
  # Build docker-machine options and node name
  SWARM_NAME="slave"
  SWARM_OPTS="--swarm"
  if [[ $1 == 1 ]]; then
    SWARM_NAME="master"
    SWARM_OPTS="--swarm --swarm-master"
  fi
  SWARM_NAME=$SWARM_NAME$2
  echo "Create node $SWARM_NAME"
  eval "$(docker-machine env -u)"
  docker-machine create \
    -d virtualbox \
      --virtualbox-memory=512 \
      --virtualbox-disk-size=5000 \
    $SWARM_OPTS \
    --swarm-discovery="consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    $SWARM_NAME
  eval $(docker-machine env $SWARM_NAME)
  # Preload images
  load_image "../img/registrator.img" "gliderlabs/registrator:v6"
  load_image "../img/redis.img" "redis:latest"
  load_image "../img/webapp.img" "webapp:latest"
  load_image "../img/nginx-lb.img" "nginx/lb:latest"
  # Run registrator container
  docker run -d \
    --name=registrator \
    -h $(docker-machine ip $SWARM_NAME) \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:v6 \
    consul://$(docker-machine ip consul):8500
  eval "$(docker-machine env -u)"
}

# Create a swarm master node
# $1: master id
function create_and_configure_swarm_master_node() {
  create_and_configure_swarm_node 1 $1
}

# Create a swarm slave node
# $1: slave id
function create_and_configure_swarm_slave_node() {
  create_and_configure_swarm_node 2 $1
}

# Create a consul host
function create_and_configure_consul_host() {
  echo Create and configure 'consul'
  docker-machine create \
    -d virtualbox \
      --virtualbox-memory=512 \
      --virtualbox-disk-size=5000 \
    consul
  eval "$(docker-machine env consul)"
  load_image "../img/consul-server.img" "gliderlabs/consul-server:latest"
  docker run -d -p "$(docker-machine ip consul):8500:8500" -h consul --restart always gliderlabs/consul-server -bootstrap
  eval $(docker-machine env -u)
}

#
function create_overlay_network() {
  echo Create overlay network on Swarm cluster
  eval $(docker-machine env --swarm master1)
  docker network create --driver overlay --subnet=10.0.9.0/24 my-overlay
  eval $(docker-machine env -u)
}
