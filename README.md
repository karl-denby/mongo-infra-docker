# mongo-infra-docker

Currently confirmed working/tested, others may work also but have not been verified.
- [x] Cloud Manager MongoDB Agent for Mac M1/M2/M3
- [ ] Cloud Manager MongoDB Agent for Mac Intel*
- [x] Cloud Manager MongoDB Agent for Windows x86_64 
- [x] Cloud Manager MongoDB Agent for Linux x86_64
- [x] Ops Manager for Mac M1/M2/M3
- [ ] Ops Manager for Mac Intel/x86_64*
- [ ] Ops Manager for Windows x86_64*
- [x] Ops Manager for Linux x86_64
- [x] Ops Manager MongoDB Agent for Mac M1/M2/M3
- [x] Ops Manager MongoDB Agent for Mac Intel
- [ ] Ops Manager MongoDB Agent for Windows x86_64*
- [x] Ops Manager MongoDB Agent for Linux x86_64

'*' should work but not tested

## Usage

**Example 1:** 

3x MongoDB Agents for Cloud Manager (with systemd)

1. Create a Cloud Manager project
    1. Create a Cloud Manager project on https://cloud.mongodb.com and go to **Deployment >> Agents >> Downloads & Settings >> Select your operating system**
    2. Pick any OS and on the wizard that appears, click generate an API key
    3. Take note of the values for
    ``` 
    mmsGroupId=123412341234123412341234

    mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234
    ```
    4. Update the file `cloud-manager/mongod-mms/automation-agent.config` with these values
2. `cd cloud-manager` and run **only 1** of these download scripts to obtain the agent for your architechture 
```
bash assets/aarch64_CM-agent.sh # if your are on M1/ARM/Aarch64
bash assets/x86_64_CM-agent.sh  # if your are on Intel Mac/Windows/Linux
```
3. **Optional: update the `cloud-manager/docker-compose.yml` file, to select the right build file, the default is aarch64 for M1/ARM/Aarch64, you can change it to x86_64 for Intel Mac/Windows/Linux on line 6, 30, 54**
4. `docker compose up -d` this will build three containers with all the tools and dependencies you need. It will install and configure the MongoDB Agent (for Cloud Manager) that you downloaded in step 2, and connect it to the group you setup in step 1. The container has systemd and behaves like an operating system and is visible in your Cloud Manager project under **Deployment >> Agents >> Servers**.

---

**Example 2:** 

Ops Manager and one MongoDB Agent

1. Download all the binaries for Ops Manager
    1. change to the ops-manager folder `cd ops-manager`
    1. run **one** of these commands
    ```
    bash assets/aarch64_OM-7.0.4.sh # If you are on an M1/ARM/Aarch64

    bash assets/x86_64_OM-7.0.4.sh  # If you are on Intel
    ```
2. Now build and start the Ops Manager container with `docker compose up -d om`
    1. Keep an eye on the startup, **it can take 10 minutes for it to be ready** `docker exec -it ops tail -f /opt/mongodb/mms/logs/mms0.log` to check activity
    1. When its ready (listening on 8080) you can log into `http://localhost:8080` and **Sign Up** the 1st user (global admin) 
    1. Set these options on the configuration screens
    ```
    URL To Access Ops Manager: http://ops.om.internal:8080
    "From" Email Address: something@nowhere.com
    "Reply To" Email Address: something@nowhere.com
    Admin Email Address: something@nowhere.com
    Transport: smtp
    SMTP Hostname: localhost
    SMTP Server Port: 25
    Next, Next, Next, Continue
    ```
3. One the project that appears go to **Deployment >> Agents >> Downloads & Settings >> Select any operating system**
    1. On the wizard that appears generate an API key
    1. Take note of the values for
    ```
    mmsGroupId=123412341234123412341234
    
    mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234
    
    mmsBaseUrl=http://ops.om.internal:8080
    ```
    1. Update the file `ops-manager/mongod-mms/automation-agent.config` with these values, it will be used by the node container in the next step
4. `cd ops-manager` and run **only 1** of these download scripts to obtain the agent for your architechture from your Ops Manager
```
bash assets/aarch64_OM-7.0.4-agent.sh # If you are on M1/ARM/Aarch64

bash assets/x86_64_OM-7.0.4-agent.sh  # If you are on Intel
```
5. Now build and start the MongoDB Agent container with `docker compose up -d n1om`. After a couple of seconds go to http://localhost:8080 and navigate to **Deployment >> Agents >> Servers** and you'll see your server, you can add a monitoring/backup agent and standalone/replica set/sharded cluster as you see fit

## Hints and tips:

- You can add a Monitoring Agent and Backup on that same screen
- The containers have a hostname like `n1.cm.internal`, they also have an alternate name if you want to use preferred hostnames `n1.alt.internal`
- The containers have self-signed ssl certs available for use, the are in the `./certs` folder on your system and in the containers under `/certs`
- To stop one container, example n2, you would run `docker compose stop n1`
- To start one container, example n2, you would run `docker compose start n1` 
- to get a shell on a container, example n2, you would run `docker exec -it n1 /bin/bash`
- Memory limits are set in `docker-compose.yml` if you need to adjust them
- `docker compose down` will stop **and delete** the containers (including the agent and data dir)

---

## Changelog
- 2024-04-16 Confirmed working on ARM/M1/Aaarch64, updated docs, 
- 2024-04-15 Make CM act more like the OM container, change container names so you can run OM/CM agents at the same time with no clash
- 2024-04-11 Initial x86_64 Ops Manager Proof of Concept aarch64 for Cloud Manager confirmed good on Windows/M-series mac
- 2024-04-10 Initial x86_64 Cloud Manager Proof of Concept, with an untested version for aarch64
