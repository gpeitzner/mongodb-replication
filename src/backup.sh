#!/bin/bash
RED='\033[0;31m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

docker exec -it GRUPO25_MONGO_MASTER mongodump --db=countries_grupo25 --collection=coleccion1_grupo25 --out=/home/data/backup
docker exec -it GRUPO25_MONGO_MASTER mongodump --db=patents_grupo25 --collection=coleccion2_grupo25 --out=/home/data/backup

echo "\n${BOLD}${RED}Deleting all databases on master node ...${NOCOLOR}${NORMAL}"
docker exec -it GRUPO25_MONGO_MASTER mongo --eval 'db.dropDatabase()' countries_grupo25
docker exec -it GRUPO25_MONGO_MASTER mongo --eval 'db.dropDatabase()' patents_grupo25
