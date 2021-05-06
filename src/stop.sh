#!/bin/bash
clear

RED='\033[0;31m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo "${RED}${BOLD}\nDeleting GRUPO25_MONGO_MASTER node ...${NOCOLOR}${NORMAL}"
docker stop GRUPO25_MONGO_MASTER && docker rm GRUPO25_MONGO_MASTER

echo "${RED}${BOLD}\nDeleting GRUPO25_MONGO_01 node ...${NOCOLOR}${NORMAL}"
docker stop GRUPO25_MONGO_01 && docker rm GRUPO25_MONGO_01

echo "${RED}${BOLD}\nDeleting GRUPO25_MONGO_02 node ...${NOCOLOR}${NORMAL}"
docker stop GRUPO25_MONGO_02 && docker rm GRUPO25_MONGO_02

echo "${RED}${BOLD}\nDeleting GRUPO25_MONGO_03 node ...${NOCOLOR}${NORMAL}"
docker stop GRUPO25_MONGO_03 && docker rm GRUPO25_MONGO_03

echo "${RED}${BOLD}\nDeleting GRUPO25_MONGO_04 node ...${NOCOLOR}${NORMAL}"
docker stop GRUPO25_MONGO_04 && docker rm GRUPO25_MONGO_04
