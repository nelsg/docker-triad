# docker-compose-samples

Exemples d'utilisation de docker-compose
========================================

Installation
------------

1. Installer [Docker](https://docs.docker.com/engine/installation/)

1. Installer [Docker Compose](https://docs.docker.com/compose/install/)

sample-01 : serveur http avec base redis
----------------------------------------

* Le _Dockerfile_ permet de créer une image avec les prérequis python (dans
  _requirements.txt_) pour faire fonctionner le script _app.py_ (Il utilise
  [flask](http://flask.pocoo.org/) et
  [redis](https://pypi.python.org/pypi/redis)).
* Le _docker-compose.yml_ créé un conteneur de cette image lié à un conteneur
contenant redis.

Pour le lancer, se placer dans le répertoire _sample-01_:

```
$ docker-compose up
```

Dans un autre terminal, la commande `docker-compose ps` permet de voir les deux
containeurs, de même que `docker ps`.

On peut voir les détails du réseau créé pour ces deux containeurs:

```
$ docker network ls # pour récupérer l'identifiant du réseau => id
$ docker network inspect <id>
```

sample-02 : docker-compose scale
--------------------------------

Même application que le _sample-01_, mais haproxy est installé en tant que
load-balancer et expose le port 80.

Pour le lancer, se placer dans le répertoire _sample-02_:

```
$ docker-compose up
```

Pour créer 5 nouveaux noeuds (en tout 6):

```
$ docker-compose scale web=6
```

sample-03 : docker-machine + swarm + docker-compose
---------------------------------------------------

Exactement le même code que le _sample-02_. Pour le lancer, se placer dans le
répertoire _sample-03_:

### Créer un magasin clé-valeur

Exécuter les commandes suivantes pour:
- Créer un machine sur virtualbox
- Récupérer l'adresse IP de la machine dans `KV_IP`
- Se connecter au docker de cette machine
- Démarrer un conteneur consul-server

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

Vérifier avec la commande `docker ps` que le conteneur existe

### Créer un cluster Swarm

Création du Swarm master avec les actions suivantes:
- Se connecter au docker local
- Création d'un master
- Récupérer l'adresse IP de la machine dans `MASTER_IP`

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

Création d'un ou plusieurs slave avec les actions suivantes:
- Se connecter au docker local
- Création d'un master
- Récupérer l'adresse IP de la machine dans `MASTER_IP`

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

Installation d'un service registrator sur toutes les machines du cluster Swarm.
Celui-ci va notifier consul à chaque fois qu'un conteneur sera démarré.

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

### Création du réseau 'overlay'

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

### Exécuter l'application sans load-balancer

En exécutant la commande suivante, on créé bien 10 conteneurs web sur les deux
noeuds. Ils peuvent tous accéder à redis.

```
docker-compose -f docker-compose-nlb.yml up -d
docker-compose -f docker-compose-nlb.yml scale web=10
```

### Exécuter l'application avec load-balancer

```
docker-compose up -d
docker-compose scale web=10
```



Problème: Tous les conteneurs sont créés sur le même noeud. C'est dû au fait que Swarm rapproche les conteneur liés (ici à travers `links`). Le problème est dû à l'exemple lui-même

Références
----------

* [https://github.com/docker/dockercloud-haproxy]
* [https://github.com/vegasbrianc/docker-compose-demo]
* [https://github.com/eea/eea.docker.jenkins/]
* [https://docs.docker.com/engine/userguide/networking/get-started-overlay/]
* [https://botleg.com/stories/load-balancing-with-docker-swarm/]
