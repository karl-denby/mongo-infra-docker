# mongo-infra-docker

**Create a MongoDB Ops Manager (or Cloud Manager) environment on your Mac (M1/Intel) or PC (Windows/Linux) with a single command. Batteries included.**

## Features

| Feature | Supported | Notes |
| --- | --- | --- |
| Ops Manager | Yes | `cd ops-manager` |
| Cloud Manager |  Yes | `cd cloud-manager` If you have low RAM, consider this instead of Ops Manager |
| MongoDB Agent | Yes | - |
| BI Connector | Yes | [BI Connector](/ops-manager/docs/BICONNECTOR.md) |
| Blockstore Backup | Yes | - |
| S3 Backup | Yes | [S3 Backup](/ops-manager/docs/BACKUP.md) |
| File Backup | Yes | use `/filesystem` in Ops Manager |
| Snapshot Restore | Yes | - |
| PIT Restore | Yes | - |
| Queryable Restore | Yes | [Queryable](/ops-manager/docs/QUERY.md) |

For more complex tests the following have been included already. Nothing is stopping you using your own also, these will  be added based on demand.

| Optional Extras | Supported | Notes |
| --- | --- | --- |
| TLS Certificates | Yes | For Deployments see [Enable TLS](/ops-manager/docs/tls-for-ops-manager.md) |
| Load-balancer | Yes | Balancer in front of single Ops Manager |
| Proxy | Yes | Squid running on port `proxy.om.internal:3128` |
| SMTP | Yes | `smtp.om.internal` on 1025, web viewer in 1080 |
| Prometeus | No | Not included yet |
| LDAP | No | Not included yet |
| Kerberos | No | Not included yet |
| KMIP | No | Not included yet |

## Usage

### Example 1

Ops Manager and one MongoDB Agent (Make sure docker has access to **12G of RAM or more...** ...if you want to do backup testing)

1. `cd ops-manager` then `bash quick-start.sh`

2. The script will download, build and deploy Ops Manager, please click **Sign Up** and register your first user who will be the **Global Admin** then complete the Initial Setup screens (we have pre defined some values in conf-mms.properties, so you just need to click **Continue** until its done)

3. Once the project appears go to **Deployment >> Agents >> Downloads & Settings >> Select any operating system**
    a. On the wizard that appears click **+Generate Key**
    b. Take note of the values for

    ```console
    mmsGroupId=123412341234123412341234
    
    mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234
    
    mmsBaseUrl=http://ops.om.internal:8080
    ```

    c. Update the file `ops-manager/mongod-mms/automation-agent.config` with these values, it will be used by the node container in the next step

4. Press any key to unpause the script, it will download an Agent and start up a container with it running inside that is connected to the Ops Manager you deployed earlier, your environment is setup.

5. **Optional:** run `bash extras.sh` and select the option you would like setup, it looks like this:

```console
bash extras.sh 
Please choose some extras:
1) pause            3) more-servers    5) oplog           7) proxy           9) smtp           11) Quit
2) un-pause         4) metadata        6) blockstore      8) load-balancer  10) s3
#? 9
Starting smtp on smtp.om.internal
localhost:1025 is where you can send emails
localhost:1080 is where you can read them
[+] Running 5/5
 ✔ smtp 4 layers [⣿⣿⣿⣿]      0B/0B      Pulled 
   ✔ 619be1103602 Pull  
   ✔ d87a23ae4383 Pull 
   ✔ 49bc41facb3d Pull 
   ✔ de31bd6756d2 Pull 
[+] Building 0.0s
docker:default
[+] Running 1/1
 ✔ Container smtp  Started 0.1s 
```

### Result

If you followed steps 1 - 5 you should have something like this within 10 minutes:

![Ops Manager Example](ops-manager/docs/images/Example.png)

## Hints and tips

- Ops Manager needs 8G RAM to run reliably, an Agent 2.5G, so for Monitoring/Automation your looking at giving docker 10.5G
- TLS certificates (testing use only) are available, please see [Enable TLS](/ops-manager/docs/tls-for-ops-manager.md) for more details
- Stopping/Starting Ops Manager and Containers
  - `docker compose pause` # will pause all the containers from running state
  - `docker compose unpause` # will get them all going again
- Getting a Shell / SSH on the containers
  - `docker exec -it ops /bin/bash` runs bash as root on the **ops** container
  - `docker exec -it node1 /bin/bash` runs bash as root on the **node1** container
  - you can just look at the docker-compose.yml to see what each container is called, or you can see it in `docker ps`
  - `docker stats` is a great way to see the cpu/memory usage and limits of each container

### Example 2

3x MongoDB Agents for Cloud Manager (with systemd)

1. Create a Cloud Manager project
    a. Create a Cloud Manager project on <https://cloud.mongodb.com> and go to **Deployment >> Agents >> Downloads & Settings >> Select your operating system**
    b. Pick any OS and on the wizard that appears, click generate an API key
    c. Take note of these values

    ```console
    mmsGroupId=123412341234123412341234

    mmsApiKey=123412341234123412341234123412341234123412341234123412341234123412341234
    ```

    d. Update the file `cloud-manager/mongod-mms/automation-agent.config` with these values

2. `cd cloud-manager` and run **only 1** of these download scripts to obtain the agent for your architechture

    ```console
    bash assets/aarch64_CM-agent.sh # if your are on M1/ARM/Aarch64
    bash assets/x86_64_CM-agent.sh  # if your are on Intel Mac/Windows/Linux
    ```

3. **Optional: update the `cloud-manager/docker-compose.yml` file, to select the right build file, the default is aarch64 for M1/ARM/Aarch64, you can change it to x86_64 for Intel Mac/Windows/Linux on line 6, 30, 54**

4. `docker compose up -d n1cm n2cm n3cm` this will build three containers with all the tools and dependencies you need. It will install and configure the MongoDB Agent (for Cloud Manager) that you downloaded in step 2, and connect it to the group you setup in step 1. The container has systemd and behaves like an operating system and is visible in your Cloud Manager project under **Deployment >> Agents >> Servers**.

5. **Optional:** if you need more nodes you can run `docker compose up -d n4cm n5cm n6cm`, they will appear in the same project. Each uses about 2.5GB of Memory.

## Disclaimer

This software is not supported by [MongoDB, Inc](https://www.mongodb.com) under any of their commercial support subscriptions or otherwise. Any usage of this tool is at your own risk. It's intended only to serve as a quick test/reproduction environment.

## Changelog

- 2024-09-30 Initial support for Ops Manager 8.0
- 2024-09-03 BI Connector on ARM documented
- 2024-06-05 Added `extras.sh` to streamline addisions to the basic environment
- 2024-06-04 Queryable works on ARM by default with 6.0.15 being available for queryable instance
- 2024-05-30 Queryable pem SANs have localhost, `ops.om.internal`, `lb.om.internal`, support for ARM by renaming x86 binaries
- 2024-05-29 Added Queryable Backup support for x86_64, set certs to expire every 28 days
- 2024-05-20 Atlas Local testing complete on M1, update from 7.0.5 to 7.0.6, BIC, filesystem backup
- 2024-05-10 Added Atlas Local on Docker Compose (not podman)
- 2024-05-07 Added a single script with menu to select platform/arch
- 2024-05-03 Added disclaimer and feature tables to README.md
- 2024-05-01 Initial run at a simplified s3 setup
- 2024-04-25 Set some defaults in conf-mms.properties so initial startup is faster, add smtp catcher, initial attempt at s3 support
- 2024-04-23 Added working nginx loadbalancer and squid proxy
- 2024-04-22 Single command needed to do everything, added oplog/blockstores/metadata with resonable sizes
- 2024-04-16 Confirmed working on ARM/M1/Aaarch64, updated docs, set aarch64 as default as most users of this project (80%) are using M1's to run test environments
- 2024-04-15 Make CM act more like the OM container, change container names so you can run OM/CM agents at the same time with no clash
- 2024-04-11 Initial x86_64 Ops Manager Proof of Concept aarch64 for Cloud Manager confirmed good on Windows/M-series mac
- 2024-04-10 Initial x86_64 Cloud Manager Proof of Concept, with an untested version for aarch64

Copyright 2024 Karl Denby
