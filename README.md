# mongo-infra-docker

Currently confirmed working/tested, others may work also but have not been verified.
- [x] Cloud Manager MongoDB Agent for Mac M1/M2/M3
- [ ] Cloud Manager MongoDB Agent for Mac Intel*
- [x] Cloud Manager MongoDB Agent for Windows x86_64 
- [x] Cloud Manager MongoDB Agent for Linux x86_64
- [x] Ops Manager for Mac M1/M2/M3
- [x] Ops Manager for Mac Intel/x86_64
- [ ] Ops Manager for Windows x86_64*
- [x] Ops Manager for Linux x86_64
- [x] Ops Manager MongoDB Agent for Mac M1/M2/M3
- [x] Ops Manager MongoDB Agent for Mac Intel
- [ ] Ops Manager MongoDB Agent for Windows x86_64*
- [x] Ops Manager MongoDB Agent for Linux x86_64

'*' should work but not tested

---

## Usage

![](ops-manager/docs/images/Example.png)

**Example 1:** 

Ops Manager and one MongoDB Agent (Make sure docker has access to **12G of RAM** if you want to do backup testing)

1. Run `bash quick-start-intel.sh` or `bash quick-start-m1.sh` depending on what CPU type your system has

2. The script will download, build and deploy Ops Manager then pause while it is configured, enter these settings:
    ```
    URL To Access Ops Manager: http://ops.om.internal:8080
    "From" Email Address: something@nowhere.com
    "Reply To" Email Address: something@nowhere.com
    Admin Email Address: something@nowhere.com
    Transport: smtp
    SMTP Hostname: localhost
    SMTP Server Port: 25

    Continue, Continue, Continue, Continue, Continue
    ```

3. Once the project appears go to **Deployment >> Agents >> Downloads & Settings >> Select any operating system**
    1. On the wizard that appears click **+Generate Key**
    1. Take note of the values for
    ```
    mmsGroupId=123412341234123412341234
    
    mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234
    
    mmsBaseUrl=http://ops.om.internal:8080
    ```
    1. Update the file `ops-manager/mongod-mms/automation-agent.config` with these values, it will be used by the node container in the next step

4. Press any key to unpause the script, it will download an Agent and start up a container with it running inside that is connected to the Ops Manager you deployed earlier, your environment is setup.

## Hints and tips:

- Ops Manager needs 8G RAM to run reliably, an Agent 2.5G, so for Monitoring/Automation your looking at giving docker 10.5G
- We also provide a couple of extra nodes called 
  - oplog (0.75G) `docker compose up -d oplog` (`oplog.om.internal`)
  - and blockstore (0.75G) `docker compose up -d blockstore` (`blockstore.om.internal`)
  - these are perfect for standalones as backup infrastucture (12G total RAM)
  - If you are providing your own S3 and need a metadata store you can use one of those or `docker compose up -d metadata` (`metadata.om.internal`)
- Stopping/Starting Ops Manager and Containers
  - `docker compose pause` # will pause all the containers from running state
  - `docker compose unpause` # will get them all going again 
- Getting a Shell / SSH on the containers
  - `docker exec -it ops /bin/bash` runs bash as root on the **ops** container
  - `docker exec -it node1-om /bin/bash` runs bash as root on the **node1-om** container
  - you can just look at the docker-compose.yml to see what each container is called, or you can see it in `docker ps`
  - `docker stats` is a great way to see the cpu/memory usage and limits of each container 
- TLS certificates (testing use only) are available, please see [Enable TLS](/ops-manager/docs/tls-for-ops-manager.md) for more details

---

**Example 2:** 

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

4. `docker compose up -d n1cm n2cm n3cm` this will build three containers with all the tools and dependencies you need. It will install and configure the MongoDB Agent (for Cloud Manager) that you downloaded in step 2, and connect it to the group you setup in step 1. The container has systemd and behaves like an operating system and is visible in your Cloud Manager project under **Deployment >> Agents >> Servers**.

5. **Optional: if you need more nodes you can run `docker compose up -d n4cm n5cm n6cm`, they will appear in the same project**

=======

- TLS certificates (testing use only) are available, please see [Enable TLS](/ops-manager/docs/tls-for-ops-manager.md)
- If you do `docker compose up -d squid` a proxy will run on `http://squid.om.internal:3128`

---

## Changelog
- 2024-04-22 Single command needed to do everything, added oplog/blockstores/metadata with resonable sizes
- 2024-04-16 Confirmed working on ARM/M1/Aaarch64, updated docs, set aarch64 as default as most users of this project (80%) are using M1's to run test environments
- 2024-04-15 Make CM act more like the OM container, change container names so you can run OM/CM agents at the same time with no clash
- 2024-04-11 Initial x86_64 Ops Manager Proof of Concept aarch64 for Cloud Manager confirmed good on Windows/M-series mac
- 2024-04-10 Initial x86_64 Cloud Manager Proof of Concept, with an untested version for aarch64
