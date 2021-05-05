#!/bin/bash
docker run -v $(pwd)/data:/home/data --name GRUPO25_MONGO_MASTER -d mongo:latest
docker run --name GRUPO25_MONGO_01 -d mongo:latest
docker run --name GRUPO25_MONGO_02 -d mongo:latest
docker run --name GRUPO25_MONGO_03 -d mongo:latest
docker run --name GRUPO25_MONGO_04 -d mongo:latest
docker exec -it GRUPO25_MONGO_MASTER sh /home/data/load.sh
docker exec -it GRUPO25_MONGO_MASTER mongo
