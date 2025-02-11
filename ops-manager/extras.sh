#!/bin/bash
echo Please choose some extras: 
platform_options=("pause" "un-pause" "more-servers" "oplog" "blockstore" "proxy" "load-balancer" "smtp" "s3" "kmip" "clean" "Quit")
select opt in "${platform_options[@]}"
do
  case $opt in
    pause)
      echo "Pausing"
      docker compose pause
      break
      ;;    
    un-pause)
      echo "Unpausing"
      docker compose unpause
      break
      ;;
    more-servers)
      echo "Starting node2 and node3"
      docker compose up -d node2 node3
      break
      ;;
    oplog)
      echo "Starting oplog store on oplog.om.internal"
      docker compose up -d oplog
      break
      ;;
    blockstore)
      echo "Starting blockstore on blockstore.om.internal"
      docker compose up -d blockstore
      break
      ;;
    proxy)
      echo "Starting proxy on proxy.om.internal"
      echo "You can configure OM or Agents or both to use this"
      docker compose up -d proxy
      break
      ;;
    load-balancer)
      echo "Starting load-balancer on lb.om.internal"
      echo "You may want:"
      echo "1. Update your centralUrl in OM to lb.om.internal"
      echo "2. update mongodb-mms/automation-agent.config to have this url"
      echo "3. docker compose restart node1"
      echo "This is in front of ops.om.internal, so you get a 503 if OM is down"
      docker compose up -d lb
      break
      ;;
    smtp)
      echo "Starting smtp on smtp.om.internal"
      echo "localhost:1025 is where you can send emails"
      echo "localhost:1080 is where you can read them"
      docker compose up -d smtp
      break
      ;;
    s3)
      echo "Starting metadata on mongodb://metadata.om.internal:27017"
      echo "Starting garage/s3 on http://s3.om.internal:3900"
      docker compose up -d metadata s3
      docker exec -it s3 ./garage bucket create oplog 2>&1
      docker exec -it s3 ./garage bucket create blockstore 2>&1
      echo "Go to Admin >> Backup, Enter '/head' and hit Set, then Enable Daemon"
      echo "Configure A S3 Blockstore, Advanced Setup then Create New S3 Blockstore or S3 Oplog"
      echo "Name: blockstore (or oplog if you selected S3 Oplog)"
      docker exec -it s3 ./garage key create my-key
      echo "S3 Bucket Name = blockstore (or oplog)"
      echo "Region override = docker"
      echo "S3 Endpoint = http://s3.om.internal:3900"
      echo "Server Side Encryption = On"
      echo "S3 Autorization Method = Keys"
      echo "AWS Access Key = (listed above)"
      echo "AWS Secret Key = (listed above)"
      echo "Datastore Type = Standalone"
      echo "MongoDB Hostname = metadata.om.internal"
      echo "MongoDB Port = 27017"
      echo "Username = (If you enabled auth on the project enter your user otherwise blank)"
      echo "Password = (If you enabled auth on the project enter your user otherwise blank)"
      echo "Encrypt Credentials = off"
      echo "Use TLS/SSL = if you enabled TLS in the project set this, default off"
      echo "New assignment Enabled = on"
      echo "Disable proxy settings = off"
      echo "Acknowledge = on"
      echo "Hit Create and if everything was entered correctly, the metadata and s3 containers are running, it should complete."
      docker exec -it s3 ./garage bucket allow oplog --key my-key --read --write --owner 2>&1
      docker exec -it s3 ./garage bucket allow blockstore --key my-key --read --write --owner 2>&1
      break
      ;;
    kmip)
      echo "Starting KMIP Server on kmip.om.internal:5696"
      docker compose up -d kmip
      break
      ;;
    clean)
      echo "cleaning up s3 data"
      docker exec -it s3 ./garage bucket delete --yes oplog
      docker exec -it s3 ./garage bucket delete --yes blockstore
      docker exec -it s3 ./garage key delete --yes my-key
      echo "Removing all containers"
      docker compose down
      docker image rm ops-manager-ops ops-manager-node1 ops-manager-node2 ops-manager-node3 metadata s3 smtp lb proxy blockstore oplog 2>&1
      break
      ;;
    Quit)
      echo "Bye."
      break
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
done
