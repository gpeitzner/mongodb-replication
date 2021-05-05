#!/bin/bash
docker run --rm -v $(pwd):/home/data --name GRUPO25_MONGO_MASTER -d mongo:latest
docker run --rm --name GRUPO25_MONGO_01 -d mongo:latest
docker run --rm --name GRUPO25_MONGO_02 -d mongo:latest
docker run --rm --name GRUPO25_MONGO_03 -d mongo:latest
docker run --rm --name GRUPO25_MONGO_04 -d mongo:latest
