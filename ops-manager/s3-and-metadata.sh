#!/bin/bash
echo === Bring up the metadata store and s3 ===
docker compose up -d metadata s3

echo === Grab the clusterid ===
docker exec s3 /garage layout show

echo === Enter the ID ===
read -n 16 -p "Please enter the id from above" clusterid
read -p "How much storage would you like to give S3, for example, 1g, 2g, 5g: " storagesize

echo === Configuring s3 store, buckets, keys, acl ===
docker exec s3 /garage layout assign -z dc1 -c $storagesize $clusterid
docker exec s3 /garage layout apply --version 1
docker exec s3 /garage bucket create oplog
docker exec s3 /garage bucket create blockstore
docker exec s3 /garage key create backup-key
docker exec s3 /garage bucket allow --read --write --owner oplog --key backup-key
docker exec s3 /garage bucket allow --read --write --owner blockstore --key backup-key

