# Mongo Cluster to Cluster Sync

### Sorry Apple fans
If you want to use an M-series mac you can run mongosync locally (its available for arm64 mac):
- node 1 port 27017 maps to localhost:27171
- node 2 port 27017 maps to localhost:27172
- node 3 port 27017 maps to localhost:27173

So for example you could spin up Ops Manager, put a replica set on node 1, another on node 2 and sync between node1 and node2

### Using with Ops Manager
- run `bash quick-start.sh` it will create a container with RHEL8 and mongosync 1.7.3
- exec to the container with `docker exec -it sync /bin/bash` then you can run `mongosync`
- you can run it directly with `docker exec -it sync mongosync`
- it can talk directly to anything on the `*.om.internal`
- it will be known as `sync.om.internal`
