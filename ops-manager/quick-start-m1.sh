#!/bin/bash
echo === Downloading Ops Manager ===
bash assets/aarch64_OM-7.0.4.sh

echo === Building/Running Ops Manager Container ===
docker compose up -d om

echo === Waiting 6 minutes for Ops Manager to get going ===
sleep 360

echo === Please continue at step 5 ===