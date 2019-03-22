#!/bin/sh
source ../scripts/env-fn.sh

START_TIME=$SECONDS

backup_all_needed_images
create_and_configure_node manager1
create_and_configure_node worker1
create_and_configure_node worker2
# create_overlay_network

# Init swarm master
eval $(docker-machine env manager1)
docker swarm init --advertise-addr $(docker-machine ip manager1)
# docker info
# docker node ls
# # manager1 commands
# # eval $(docker-machine env -u)
# docker-machine ssh manager1
# tce-load -wi python python-dev openssl gcc
# wget https://bootstrap.pypa.io/get-pip.py
# sudo python get-pip.py
# sudo pip install docker-py crypto suds bigsuds jinja2 PyYAML pycrypto>=2.6 paramiko MarkupSafe pyasn1 idna six enum34 ipaddress cffi pycparser
# git clone https://github.com/ansible/ansible.git --recursive

eval $(docker-machine env worker1)
# docker swarm join \
#    --token SWMTKN-1-16d2ils5df5r858qpn5yioij14afvcc9z0xgjccwpsaov1etez-5fabyhrw8jn90rxazqynz66lw \
#    192.168.99.101:2377

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Elapsed time=${ELAPSED_TIME}s"
