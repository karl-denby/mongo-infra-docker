# Atlas Local with Search and Vector Search

## Features
Single command that starts a database container and a search container and sets then up to talk to each other. **Note this is possible with the `atlas cli` and podman**, this is an alternative way that leverages docker compose tooling as might be more typical for some developers.

## Requirements
This assumes you have the following installed
- A recent `docker` that includes `docker compose`
- `mongosh` so that the db can be initalized
- `curl` so that we can download sample data
- `mongorestore` so that we can load sample data

## Usage
1. `cd atlas-local` # if your not already here
2. `bash quick-start.sh` # to start containers and configure them

## Next Steps
If all goes well you can use `mongosh` or **Compass** to connect to
- `mongodb://root:MzY0MzYyNmMtMjFkZS00Y2Q4LWEyNzQtNzVmZDdjOWU3NjA5@localhost:27778/?directConnection=true&authMechanism=DEFAULT`
- In Compass the **Search Indexes** tab should be availble

![](docs/images/compass.png)

## Hints and Tips
- If you want to pause this from the `atlas-local` folder run a `docker compose pause`, later you can resume with `docker compose unpause`
- If your done and want to completely remove the environment do `docker compose down` cached images can be removed also with `docker system prune -a`