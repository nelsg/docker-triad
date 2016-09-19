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
docker-compose up
```

Dans un autre terminal, la commande `docker-compose ps` permet de voir les deux
containeurs, de même que `docker ps`.

On peut voir les détails du réseau créé pour ces deux containeurs:

```
docker network ls # pour récupérer l'identifiant du réseau => id
docker network inspect <id>
```

sample-02 : docker-compose scale
--------------------------------

Même application que le _sample-01_, mais haproxy est installé en tant que
load-balancer et expose le port 80.

Pour le lancer, se placer dans le répertoire _sample-02_:

```
docker-compose up
```

Pour créer 5 nouveaux noeuds (en tout 6):

```
docker-compose scale web=6
```

sample-03 : docker-machine + swarm + docker-compose
---------------------------------------------------

Exactement le même code que le _sample-02_. Pour le lancer, se placer dans le répertoire _sample-03_:

### Création du cluster Swarm

Création d'un hôte qui va servire de service discovery :

```
docker-machine create -d virtualbox keystore
eval "$(docker-machine env keystore)"
docker run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap
```

Création de deux noeuds dans mon cluster swarm, dont un master :

```
docker-machine create -d virtualbox --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-master

docker-machine create -d virtualbox --swarm \
  --swarm-discovery="consul://$(docker-machine ip keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  swarm-01
```

Pour lister les machines:

```
docker-machine ls
```

### Création du réseau 'overlay'

On le créé uniquement sur un noeud :

```
eval $(docker-machine env --swarm swarm-master)
docker network create --driver overlay --subnet=10.0.9.0/24 swarm-net
```

L'afficher :

```
docker network ls
```

Si on se connecte sur un autre noeud, le réseau doit également être visible :

```
eval $(docker-machine env --swarm swarm-01)
docker network ls
```


Références
----------

* [https://github.com/docker/dockercloud-haproxy]
* [https://github.com/vegasbrianc/docker-compose-demo]
* [https://github.com/eea/eea.docker.jenkins/]
* [https://docs.docker.com/engine/userguide/networking/get-started-overlay/]
