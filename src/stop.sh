#!/bin/bash
docker stop GRUPO25_MONGO_MASTER && docker rm GRUPO25_MONGO_MASTER
docker stop GRUPO25_MONGO_01 && docker rm GRUPO25_MONGO_01
docker stop GRUPO25_MONGO_02 && docker rm GRUPO25_MONGO_02
docker stop GRUPO25_MONGO_03 && docker rm GRUPO25_MONGO_03
docker stop GRUPO25_MONGO_04 && docker rm GRUPO25_MONGO_04
