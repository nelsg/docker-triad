# docker-compose-samples

Exemples d'utilisation de docker-compose
========================================

Installation
------------

1. Installer [Docker](https://docs.docker.com/engine/installation/)

1. Installer [Docker Compose](https://docs.docker.com/compose/install/)

Notes
-----

Dans ces exemples, on lance une application web python qui incrémente un
compteur à chaque fois qu'elle est appelé.
La valeur du compteur est persisté dans une base redis.

Dans le répertoire _app_ se trouve le fichier _app.py_ qui contient le code
de l'application web et un fichier _Dockerfile_ qui permet d'en créer une image
nommée par la suite _webapp_.

L'image redis s'appelle tout simplement _redis_.

Exemples
--------

* 01: Lancement de redis et webapp avec docker-compose
* 02: Idem 01 avec un load-balancer avec prise en compte dynamique des nouveaux
conteneurs
* 03: Idem 02 mais sur un cluster Swarm (n'utilise pas tous les noeuds, et c'est
normal)
* 04: Idem 02 avec cette fois l'utilisation d'un service discovery pour
configurer le load-balancer

Références
----------

* [https://github.com/docker/dockercloud-haproxy]
* [https://github.com/vegasbrianc/docker-compose-demo]
* [https://github.com/eea/eea.docker.jenkins/]
* [https://docs.docker.com/engine/userguide/networking/get-started-overlay/]
