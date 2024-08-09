# Mongo Cluster to Cluster Sync

### Using with Cloud Manager
- run `bash quick-start.sh` it will create a container with RHEL8 and mongosync 1.7.3
- exec to the container with `docker exec -it sync /bin/bash` then you can run `mongosync`
- you can run it directly with `docker exec -it sync mongosync`
- it can talk directly to anything on the `*.cm.internal`
- it will be known as `sync.cm.internal`
- It exposes the mongosync port on 27182 so you can send commands to it from your local workstation
