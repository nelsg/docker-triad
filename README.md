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

Pour le lancer, se placer dans le répertoire _sample-01_:

```
docker-compose up
```

Pour créer 5 nouveaux noeuds (en tout 6):

```
docker-compose scale web=6
```

sample-03 : docker-compose jenkins+slaves
-----------------------------------------

Pour lancer jenkins avec un esclave, se placer dans le répertoire _sample-03_:

```
docker-compose up
```

Mettre 3 esclaves:

```
docker-compose scale worker=3
```

Vérifier que tout est OK et que les esclaves se connectent au maître

```
sudo docker-compose logs worker
```


Références
----------

* [https://github.com/docker/dockercloud-haproxy]
* [https://github.com/vegasbrianc/docker-compose-demo]
* [https://github.com/eea/eea.docker.jenkins/blob/master/docker-compose.yml]
* jenkins-master: [https://github.com/eea/eea.docker.jenkins.master]
* jenkins-slave: [https://github.com/eea/eea.docker.jenkins.slave-eea]
