#!/bin/bash
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=countries_grupo25.coleccion1_grupo25 /home/data/backup
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=patents_grupo25.coleccion2_grupo25 /home/data/backup
