Construction d'un cluster Swarm puis load-balancer, webapp et base redis
========================================================================

hôtes utilisés:
* _consul_: il embarque le conteneur _consul-server_, un 'key-store' qui est
utilisé par Swarm pour faire communiquer et synchroniser ses noeuds
* _master_: le noeud maitre du cluster swarm
* _slave1_: un des noeuds esclave du cluster swarm

images utilisées:
* _nginx_: load balancer, il est notifié par _consul-server_ dès qu'un
conteneur est créé ou supprimé, il modifie la configuration du load-balancer en
conséquence
* _webapp_: l'application web
* _redis_: la base de données
* _consul-server_: le serveur consul
* _registrator_: un 'espion' installé sur tous les noeuds du cluster swarm et
qui notifie le _consul-server_ de tout changement concernant les conteneurs en
cours d'exécution.

Installation du service discovery
---------------------------------

Exécuter les commandes suivantes pour:
- Créer l'hôte _consul_ sur virtualbox
- Récupérer l'adresse IP de _consul_ dans `KV_IP`
- Se connecter au docker de cette machine
- Démarrer un conteneur _consul-server_

```
$ docker-machine create -d virtualbox consul
$ export KV_IP=$(docker-machine ip consul)
$ eval "$(docker-machine env consul)"
$ docker run -d \
  -p "${KV_IP}:8500:8500" \
  -h consul \
  --restart always \
  gliderlabs/consul-server -bootstrap
```

Vérifier avec la commande `docker ps` que le conteneur _consul-server_ existe

Créer un cluster Swarm avec 1 maître et 1 esclave
-------------------------------------------------

Création du maître avec les commandes suivantes:
- Se connecter au docker local
- Création du maître _master_
- Stoquer l'adresse IP de _master_ dans `MASTER_IP`

```
$ eval "$(docker-machine env -u)"
$ docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-master \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  master
$ export MASTER_IP=$(docker-machine ip master)
```

Création d'un ou plusieurs esclaves avec les commandes suivantes:
- Se connecter au docker local
- Création d'un esclave _slave1_
- stoquer l'adresse IP de _slave1_ dans `SLAVE1_IP`

```
$ eval "$(docker-machine env -u)"
$ docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://${KV_IP}:8500" \
  --engine-opt="cluster-store=consul://${KV_IP}:8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  slave1
$ export SLAVE1_IP=$(docker-machine ip slave1)
```

Installation d'un conteneur _registrator_ sur toutes les machines du cluster
Swarm. Celui-ci va notifier _consul_ à chaque fois qu'un conteneur sera modifié.

```
$ eval $(docker-machine env master)
$ docker run -d \
  --name=registrator \
  -h ${MASTER_IP} \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:v6 \
  consul://${KV_IP}:8500

$ eval $(docker-machine env slave1)
$ docker run -d \
  --name=registrator \
  -h ${SLAVE1_IP} \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:v6 \
  consul://${KV_IP}:8500
```

Lister les machine avec `docker-machine ls`, il devrait y avoir: _consul_,
_master_ et _slave1_

Création du réseau 'overlay'
----------------------------

> Cette étape ne semble nécessaire que si le driver de docker-machine est
VirtualBox

> Réseau overlay: Un réseau overlay ou réseau superposé, est un réseau
informatique bâti sur un autre réseau. Les noeuds du réseau superposé sont
interconnectés par des liens logiques du réseau sous-jacent. La complexité du
réseau sous-jacent n'est pas visible par le réseau superposé.

Se connecter sur le cluster Swarm pour configurer le réseau overlay:

```
$ eval $(docker-machine env --swarm master)
$ docker network create --driver overlay --subnet=10.0.9.0/24 my-overlay
$ docker network ls
```

Pour lister les machines:

```
docker-machine ls
```

Exécuter l'application sans load-balancer
-----------------------------------------

En exécutant ces commandes, on créé bien 10 conteneurs _webapp_ sur les deux
noeuds. Ils peuvent tous accéder à _redis_ mais il faut les atteindre
directement.

```
docker-compose -f docker-compose-nlb.yml up -d
docker-compose -f docker-compose-nlb.yml scale web=10
```

Exécuter l'application avec load-balancer
-----------------------------------------

```
docker-compose up -d
docker-compose scale web=10
```

Cette fois, on requête directement le load-balancer et il utilise bien tous les
_webapp_.

Références
----------

* [https://botleg.com/stories/load-balancing-with-docker-swarm/]
