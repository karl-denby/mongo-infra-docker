#!/bin/bash
echo === Setting Docker build images to x86_64 ===
sed -i 's/aarch64/x86_64/g' docker-compose.yml

echo === Downloading AppDB and Ops Manager ===
curl -o mongodb-enterprise.x86_64.rpm -L https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/7.0/x86_64/RPMS/mongodb-enterprise-server-7.0.8-1.el8.x86_64.rpm
curl -o mongodb-mms.x86_64.rpm -L https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-7.0.4.500.20240405T1431Z.x86_64.rpm 

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
curl -o mongodb-agent.x86_64.rpm -L http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.x86_64.rhel8.rpm
docker compose up -d node1

echo === Please check Ops Manager servers tab for your running agents ===
