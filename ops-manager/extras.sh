#!/bin/bash
echo Please choose some extras: 
platform_options=("pause" "un-pause" "more-servers" "metadata" "oplog" "blockstore" "proxy" "load-balancer" "smtp" "s3" "clean" "Quit")
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
    metadata)
      echo "Starting metadata store on metadata.om.internal"
      docker compose up -d metadata
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
      echo "Starting s3 on http://s3.om.internal:3900"
      docker compose up -d s3
      break
      ;;
    clean)
      echo "Removing all containers"
      docker compose down
      docker image rm ops-manager-ops ops-manager-node1 ops-manager-node2 ops-manager-node3
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
