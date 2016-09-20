Load-balancer, webapp et base redis
===================================

images utilisées:
* _haproxy_: load balancer, il "écoute" sur l'API docker pour détecter tous les
nouveaux conteneurs _webapp_ et modifier la configuration du load-balancer en
conséquence
* _webapp_: l'application web
* _redis_: la base de données

Pour exécuter le multi-conteneur il faut lancer la commande
`docker-compose up -d`.

Cette fois, la commande `docker-compose scale web=2` fonctionne parce que le
port des _webapp_ n'est pas exposé, toutes les requêtes passent par _haproxy_.

Faire un test avec 10 conteneurs _webapp_:

```
$ docker-compose scale web=10
```
