# Cayley Docker (Cayley and nothing but cayley)

This project puts [Cayley](https://github.com/google/cayley) in scratch docker container. It is available on [Docker Hub](https://registry.hub.docker.com/u/alectolytic/cayley/) and can be pulled using the following command.

```sh
docker pull alectolytic/cayley
```

You will note that this is a tiny image.
```
$ docker images | grep docker.io/alectolytic/cayley
docker.io/alectolytic/cayley    latest  9f8c078ba15a    17 minutes ago  13.34 MB
```

## Persisted data deployment
In this example we deploy cayley with data persisted via a data container and mongo db or PostgreSQL as a backend.

#### Initialization - mongo db
```sh
# create data storage container
docker create -v /data -v /data/db -v /log --name cayley-data tianon/true

# start database container
docker run -d --volumes-from cayley-data --name cayley-mongo mongo

# initialize database
docker run --rm -it --name cayley \
  --volumes-from cayley-data \
  --link cayley-mongo:mongo \
  alectolytic/cayley init \
  -db="mongo" -dbpath="mongo:27017"

# start cayley as required
docker run -d --name cayley -p 64210:64210 \
  --volumes-from cayley-data \
  --link cayley-mongo:mongo \
  alectolytic/cayley http -host="0.0.0.0" \
  -db="mongo" -dbpath="mongo:27017"
```

#### Initialization - PostgreSQL
```sh
# create data storage container
docker create -v /data -v /data/db -v /log --name cayley-data tianon/true

# start database container
docker run -d --name cayley-postgres -e POSTGRES_PASSWORD=cayley --volumes-from cayley-data postgres

# initialize database
docker run --rm -it --name cayley \
  --link cayley-postgres:postgres \
  --volumes-from cayley-data \ 
  alectolytic/cayley init -db=sql \
  -dbpath="postgres://postgres:cayley@postgres:5432/?sslmode=disable"

# start cayley as required
docker run -d --name cayley -p 64210:64210 \
  --link cayley-postgres:postgres \
  --volumes-from cayley-data \ 
  alectolytic/cayley  http -host="0.0.0.0" -db=sql \
  -dbpath="postgres://postgres:cayley@postgres:5432/?sslmode=disable"
```

#### Starting and stopping
You can start or stop cayley using the following command.
```sh
# Starting
docker start cayley-[mongo|postgres] cayley
# stopping
docker stop cayley cayley-[mongo|postgres]
```

#### Accessing data
You can access data from the data container using any container of your choice.
```sh
# using alpine (tiny busybox)
docker run --rm -it --volumes-from cayley-data alpine sh

# using fedora
docker run --rm -it --volumes-from cayley-data fedora:latest bash
```

## Usage
#### Build
```sh
make
```
#### Show help
```sh
docker run --rm -it alectolytic/cayley -help
```
#### HTTP server with provided configuration file
```sh
docker run -d -name cayley -p 64210:64210 \
  -v /path/to/cayley.cfg:/cayley.cfg \
  alectolytic/cayley http -config="/cayley.cfg"
```
#### HTTP server with mongodb backend
```sh
# start mongo container
docker run -d --name cayley-mongo mongo

# start cayley
docker run -d -name cayley -p 64210:64210 \
    --link cayley-mongo:mongo \
    alectolytic/cayley http -host="0.0.0.0" \
      -db="mongo" -dbpath="mongo:27017"
```
#### HTTP server (foreground) with data from host
```sh
docker run --rm -it -p 64210:64210 \
  -v /path/to/data:/data \
  alectolytic/cayley http -host="0.0.0.0" \
    -db="memstore" -dbpath="/data/30kmoviedata.nq" -logtostderr=true
```
