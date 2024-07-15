#!/bin/bash

version_options=("1-7-3")
echo Please choose a version: 
select opt in "${version_options[@]}"
do
  case $opt in
    1-7-3)
      export version='1.7.3'
      export version_for_url='1.7'
      break
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
done

# Set up urls based on the above parameters
if [[ "$version" == "1.7.3" ]]
then
  urls=("https://fastdl.mongodb.org/tools/mongosync/mongosync-rhel80-x86_64-1.7.3.tgz")
fi

# echo === Downloading Mongo Sync ===
echo "Downloading Cluster-to-Cluster Sync from ${urls[0]}"
curl -o mongodb-sync.tgz -L "${urls[0]}"
mkdir mongosync-${version}
tar -xf mongodb-sync.tgz -C mongosync-${version} --strip-components 1
alias mongosync=mongosync-${version}/bin/mongosync
echo ""
docker compose up -d sync --build
echo Done