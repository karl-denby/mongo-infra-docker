# mongo-infra (in docker)

Goals:
- All quick spin up of mongod and related software (Agents, Connectors, Sync, CLIs, etc.)
- Support Mac (M-series and Intel), Linux (x86_64) and Windows (x86_64)
- Provide items needed for typical scenario troubleshooting, host, nslookup, ping, jq, openssl

## Usage

Example for setup of 3 Cloud Manager docker containers (with systemd)
1. Clone this repository if you haven't done so already
1. Change to the directory that matchines your machine architechture (aarch64 for mseries, x86_64 for intel) `cd cloud-manager-aarch64`
1. Create a Cloud Manager project on https://cloud.mongodb.com and go to **Deployment >> Agents >> Downloads & Settings >> Select your operating system**
1. Pick anything in the linux family and on the wizard that appears generate an API key
1. Take note of the `mmsGroupId=123412341234123412341234` and `mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234` values
1. Update the file `./mongod-mms/automation-agent.config` with these values, it will be used by the containers in the next step
1. `docker compose up -d` # This will build a container with the tools you need, and install and configure the MongoDB Agent (for Cloud Manager) to start with the container via systemd

## Hints and tips:
- Once the containers are running for a few seconds, they should appear in **Deployment >> Agents >> Servers** and will be configurable
- The containers have a hostname like `n1.cm.internal`, they also have an alternate name if you want to use preferred hostnames `n1.alt.internal`
- The containers have self-signed ssl certs available for use, the are in the `./certs` folder on your system and in the containers under `/certs`
- To stop one container, example n2, you would run `docker compose stop n2`
- To start one container, example n2, you would run `docker compose start n2` 
- to get a shell on a container, example n2, you would run `docker exec -it n2 /bin/bash`
- Memory limits are set in `docker-compose.yml` if you need to adjust them
- `docker compose down` will stop and delete the containers (including the agent and data dir)
- You need to clean up your cloud manager afterwards if anything is left 

## Changelog
2024-04-10 Initial x86_64 Cloud Manager Proof of Concept, with an untested version for aarch64
