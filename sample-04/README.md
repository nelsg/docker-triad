Construction d'un cluster Swarm (2 maitres/4 esclaves) puis load-balancer, webapp et base redis
===============================================================================================

hôtes utilisés:
* _consul_: il embarque le conteneur _consul-server_, un 'key-store' qui est
utilisé par Swarm pour faire communiquer et synchroniser ses noeuds
* _master1_/_master2_: les noeuds maitre du cluster swarm
* _slave1_/_slave2_/_slave3_/_slave4_: les noeuds esclave du cluster swarm

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

Installation
------------

Je passe cette étape, elle est largement décrite dans le sample_03 et est
totalement gérée par le script _env-create.sh_

Exécution
---------

```
docker-compose up -d
docker-compose scale web=20
```

Cette fois, on requête directement le load-balancer et il utilise bien tous les
_webapp_.

Tests
-----

* Arrêté un slave puis le redémarrer pour voir ce qui se passe
* Arrêté un master puis le redémarrer pour voir ce qui se passe

Références
----------

* [https://botleg.com/stories/load-balancing-with-docker-swarm/]
