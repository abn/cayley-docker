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

# Usage

### Build
```sh
make
```

### Run
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
docker run --rm -it \
  -p 64210:64210 \
  -v /path/to/data:/data \
  alectolytic/cayley http -host="0.0.0.0" \
    -db="memstore" -dbpath="/data/30kmoviedata.nq" -logtostderr=true
```

### Example: Persisted data deployment
In this example we deploy cayley with data persisted via a data container and mongo db as a backend.

#### Initialization
```sh
# start mongo container
docker run -d --name cayley-mongo mongo

# create data container
docker create  --entrypoint=_ -v /data -v /tmp -v /log --name cayley-data scratch

# initialize database
docker run --rm -it --name cayley \
  --volumes-from cayley-data \
  --link cayley-mongo:mongo \
  alectolytic/cayley init -host="0.0.0.0" \
  -db="mongo" -dbpath="mongo:27017"

# start cayley as required
docker run -d --name cayley \
  --volumes-from cayley-data \
  --link cayley-mongo:mongo \
  alectolytic/cayley http -host="0.0.0.0" \
  -db="mongo" -dbpath="mongo:27017"
```

#### Starting and stopping
You can start or stop cayley using the following command.
```sh
docker [start|stop] cayley
```

#### Accessing data
You can access data from the data container using any container of your choice.
```sh
# using alpine (tiny busybox)
docker run --rm -it --volumes-from cayley-data alpine sh

# using fedora
docker run --rm -it --volumes-from cayley-data fedora:latest bash
```
