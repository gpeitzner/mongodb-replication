# Grupo 25

- Guillermo Alfredo Peitzner Estrada - 201504468
- Juan Pablo Osuna de León - 201503911

## Replicación

1. Crear una red llamada `mongo-cluster` en docker que utilizaran los nodos del cluster.

```bash
docker network create mongo-cluster
```

2. Iniciar un contenedor por cada uno de los nodos que conforman el cluster dentro de la red `mongo-cluster`, exponiendo el puerto correspondiente en cada contenedor, montando la carpeta `$(pwd)/data` del sistema anfitrión en cada uno de los nodos y para finalizar configurar el nombre de la replica como `bd2_grupo25` e ingresar el puesto con el que funcionará la instancia.

```bash
docker run --net mongo-cluster -p 27017:27017 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_MASTER -d mongo:latest mongod --replSet bd2_grupo25 --port 27017
docker run --net mongo-cluster -p 27018:27018 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_01 -d mongo:latest mongod --replSet bd2_grupo25 --port 27018
docker run --net mongo-cluster -p 27019:27019 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_02 -d mongo:latest mongod --replSet bd2_grupo25 --port 27019
docker run --net mongo-cluster -p 27020:27020 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_03 -d mongo:latest mongod --replSet bd2_grupo25 --port 27020
docker run --net mongo-cluster -p 27021:27021 -v $(pwd)/data:/home/data --name GRUPO25_MONGO_04 -d mongo:latest mongod --replSet bd2_grupo25 --port 27021
```

3. Cargar configuración del cluster en el nodo principal utilizando el comando `rs.initiate({<config>})`, definiendo el nombre de la replica set y configurando cada uno de los nodos con su respectiva prioridad dentro del cluster.

```bash
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
```

## Copia de seguridad

1. Haciendo uso del comando `mongodump` definir el nombre de la base de datos (`--db`), la colección (`--collection`) y el destino (`--out`) en donde se realizá la copia de seguridad.

```bash
docker exec -it GRUPO25_MONGO_MASTER mongodump --db=countries_grupo25 --collection=coleccion1_grupo25 --out=/home/data/backup
docker exec -it GRUPO25_MONGO_MASTER mongodump --db=patents_grupo25 --collection=coleccion2_grupo25 --out=/home/data/backup
```

2. Se procede a eliminar las bases de datos existentes en el nodo principal utilizando **Mongo-Shell** pasando el comando a ejecutar por medio del parametro `--eval` y el nombre de la base de datos en la que se ejecturá el comando.

```bash
docker exec -it GRUPO25_MONGO_MASTER mongo --eval 'db.dropDatabase()' countries_grupo25
docker exec -it GRUPO25_MONGO_MASTER mongo --eval 'db.dropDatabase()' patents_grupo25
```

3. Para resturar las bases de datos se hace uso de la herramienta `mongorestore`, se define el parametro `--nsInclude` para definir el nombre y la colección a resturar. Al final del comando se define la ruta donde se encuentra dicha colección.

```bash
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=countries_grupo25.coleccion1_grupo25 /home/data/backup
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=patents_grupo25.coleccion2_grupo25 /home/data/backup
```

## Flujo de la aplicación

En la aplicación encontramos los siguientes scripts:

| Archivo        | Función                                                                             |
| -------------- | ----------------------------------------------------------------------------------- |
| src/start.sh   | Despliega y configura los contenedores que conforman al cluster                     |
| src/backup.sh  | Crea la copia de seguridad de las bases de datos y elimina el contenido del cluster |
| src/restore.sh | Restaura las colecciones de las copias de seguridad creadas por **backup.sh**       |
| src/stop.sh    | Detiene y elimina los contenedores que conforman el cluster                         |

Para iniciar la aplicación utilizar los siguientes comandos en la carpeta raiz:

```bash
cd src/
sh start.sh
```

Para detener la aplicación utilizar los siguientes comandos en la carpeta raiz:

```bash
cd src/
sh stop.sh
```

## start.sh

```bash
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
```

## backup.sh

```bash
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
```

## restore.sh

```bash
#!/bin/bash
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=countries_grupo25.coleccion1_grupo25 /home/data/backup
docker exec -it GRUPO25_MONGO_MASTER mongorestore --nsInclude=patents_grupo25.coleccion2_grupo25 /home/data/backup
```

## stop.sh

```bash
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
```
