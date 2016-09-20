Webapp et base redis
====================

images utilisées:
* _webapp_: l'application web
* _redis_: la base de données

Pour exécuter le multi-conteneur il faut lancer la commande
`docker-compose up -d`. La commande `docker-compose logs` permet d'afficher les
dernières traces.

Echec de la commande `docker-compose scale web=2` parce que le port est déjà
utilisé par un conteneur _webapp_.
