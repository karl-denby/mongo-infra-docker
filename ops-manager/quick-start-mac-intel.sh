#!/bin/bash
echo === Setting Docker build images to aarch64 ===
sed -i '' 's/x86_64/aarch64/g' docker-compose.yml

echo === Downloading AppDB, Ops Manager and JDK ===
curl -o mongodb-enterprise.aarch64.rpm -L https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/aarch64/RPMS/mongodb-enterprise-server-7.0.8-1.el8.aarch64.rpm
curl -o mongodb-mms.x86_64.rpm -L https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-7.0.4.500.20240405T1431Z.x86_64.rpm 
curl -o jdk.aarch64.tar.gz -L https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz

echo === Building/Running Ops Manager Container ===
docker compose up -d ops

echo === Waiting 5 minutes for Ops Manager to get going ===
sleep 300

echo === Ops Manager setup ===
echo Please check http://localhost:8080
echo If Ops Manager is running set central URL to http://ops.om.internal:8080
echo Please update 'mongodb-mms/automation-agent.config' with the correct values for
echo mmsGroupId=xxxxxxxxxxxxxxxxxx
echo mmsApiKey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo Press any key to attempt agent download from http://localhost:8080
read -n 1 -p "Press Any Key to attempt Agent setup" mainmenuinput

echo === Downloading Agent ===
curl -o mongodb-agent.aarch64.rpm -L http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.aarch64.amzn2.rpm
docker compose up -d node1-om

echo === Please check Ops Manager servers tab for your running agents ===
