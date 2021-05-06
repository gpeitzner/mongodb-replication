#!/bin/bash
clear

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo "\n${BOLD}${GREEN}Creating cluster network ...${NOCOLOR}${NORMAL}"
docker network create mongo-cluster

echo "\n${BOLD}${GREEN}Creating cluster node containers ...${NOCOLOR}${NORMAL}"
docker run --net mongo-cluster -p 27017:27017 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_MASTER -d mongo:latest mongod --replSet bd2_grupo25 --port 27017
docker run --net mongo-cluster -p 27018:27018 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_01 -d mongo:latest mongod --replSet bd2_grupo25 --port 27018
docker run --net mongo-cluster -p 27019:27019 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_02 -d mongo:latest mongod --replSet bd2_grupo25 --port 27019
docker run --net mongo-cluster -p 27020:27020 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_03 -d mongo:latest mongod --replSet bd2_grupo25 --port 27020
docker run --net mongo-cluster -p 27021:27021 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_04 -d mongo:latest mongod --replSet bd2_grupo25 --port 27021
sleep 5

echo "\n${BOLD}${GREEN}Waiting for cluster's healthy state ...${NOCOLOR}${NORMAL}"
docker exec -it GRUPO25_MONGO_MASTER mongo --eval 'rs.initiate({
	_id: "bd2_grupo25",
	members: [
		{ _id: 0, host: "GRUPO25_MONGO_MASTER:27017", priority: 5 },
		{ _id: 1, host: "GRUPO25_MONGO_01:27018", priority: 3 },
		{ _id: 2, host: "GRUPO25_MONGO_02:27019", priority: 4 },
		{ _id: 3, host: "GRUPO25_MONGO_03:27020", priority: 2 },
		{ _id: 4, host: "GRUPO25_MONGO_04:27021", priority: 1 },
	],
});
'

echo "\n${BOLD}${GREEN}Loading clusters settings to master node ...${NOCOLOR}${NORMAL}"
sleep 15
echo "OK"

echo "\n${BOLD}${GREEN}Loading data from the archives ...${NOCOLOR}${NORMAL}"
docker exec -it GRUPO25_MONGO_MASTER sh /home/data/load.sh

echo "\n${BOLD}${GREEN}Creating a full-backup on master node ...${NOCOLOR}${NORMAL}"
sh backup.sh

echo "\n${BOLD}${GREEN}Restoring data on master node ...${NOCOLOR}${NORMAL}"
sh restore.sh

echo "\n${BOLD}${GREEN}Launching master node mongo console ...${NOCOLOR}${NORMAL}"
docker exec -it GRUPO25_MONGO_MASTER bash
