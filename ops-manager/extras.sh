#!/bin/bash
echo Please choose some extras: 
platform_options=("pause" "un-pause" "more-servers" "oplog" "blockstore" "proxy" "load-balancer" "smtp" "s3" "kmip" "minio-S3" "clean" "Quit")
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
    minio-S3)
      MINIO_CONTAINER=minio
      ENDPOINT=http://minio.om.internal:9000
      ACCESS_KEY=minioadmin
      SECRET_KEY=minioadmin
      ALIAS=infra-minio
      docker compose up -d minio metadata
      echo "Configuring MinIO S3 ..."
      until docker exec "$MINIO_CONTAINER" \
      mc alias set "$ALIAS" "$ENDPOINT" "$ACCESS_KEY" "$SECRET_KEY" >/dev/null 2>&1
      do
        echo "MinIO not ready yet..."
        sleep 2
      done
      docker exec "$MINIO_CONTAINER" mc mb "$ALIAS"/snapshot-store
      docker exec "$MINIO_CONTAINER" mc mb "$ALIAS"/oplog-store
      docker exec "$MINIO_CONTAINER" mc mb --with-lock "$ALIAS"/immutable-snapshot-store
      echo "  "
      echo "Configure Ops Manager Backup to use MinIO S3 bucket:"
      echo " - Go to Admin >> Backup, Enter '/head' and hit Set, then Enable Daemon"
      echo " - Configure A S3 Blockstore, Advanced Setup then Create New S3 Blockstore or S3 Oplog"
      echo " - S3 Bucket Name = snapshot-store  (or oplog-store or immutable-snapshot-store)"
      echo " - S3 Endpoint = http://minio.om.internal:9000"
      echo " - Path Style Access = Enabled"
      echo " - Server Side Encryption = Disabled"
      echo " - AWS Access Key = minioadmin"
      echo " - AWS Secret Key = minioadmin"
      echo " - Object Lock = Disabled  (if you created the immutable-snapshot-store bucket set this to on, otherwise off)"
      echo " - If you require the immutable-snapshot-store to have a default retention policy, run this command:"
      echo "   docker exec minio sh -c \"mc alias set infra-minio http://minio.om.internal:9000 minioadmin minioadmin && mc retention set --default COMPLIANCE 30d infra-minio/immutable-snapshot-store\""  
      break
      ;; 
    clean)
      echo "cleaning up s3 data"
      docker exec -it s3 ./garage bucket delete --yes oplog
      docker exec -it s3 ./garage bucket delete --yes blockstore
      docker exec -it s3 ./garage key delete --yes my-key
      docker exec minio sh -c "mc alias set infra-minio http://minio.om.internal:9000 minioadmin minioadmin && mc rb --force infra-minio/snapshot-store && mc rb --force infra-minio/oplog-store && mc rb --force infra-minio/immutable-snapshot-store"
      echo "Removing all containers"
      docker compose down
      docker image rm ops-manager-ops ops-manager-node1 ops-manager-node2 ops-manager-node3 metadata s3 minio smtp lb proxy blockstore oplog 2>&1
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
