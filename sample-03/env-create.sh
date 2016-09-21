#!/bin/sh
source ../scripts/env-fn.sh

START_TIME=$SECONDS

backup_all_needed_images
create_and_configure_consul_host
create_and_configure_swarm_master_node 1
create_and_configure_swarm_slave_node 1
create_overlay_network

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Elapsed time=${ELAPSED_TIME}s"
