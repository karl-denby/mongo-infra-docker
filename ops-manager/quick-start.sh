#!/bin/bash

if [[ "$DOCKER_DEFAULT_PLATFORM" == linux/amd64 ]]
then
  echo "Looks like you've set DOCKER_DEFAULT_PLATFORM to force amd64:"
  echo " - We want to run a native aarch64 container for you, don't worry we will swap the jdk"
  echo " - You could try unset DOCKER_DEFAULT_PLATFORM, then run this again"
  echo " - More details https://github.com/karl-denby/mongo-infra-docker/issues/72"
  exit 1
fi

version_options=("8-0-0" "7-0-10" "6-0-25" "downloaded")
echo Please choose a version: 
select opt in "${version_options[@]}"
do
  case $opt in
    8-0-0)
      export version='8.0.0'
      export version_for_url='8.0'
      touch downloads/8.ver 2>&1
      rm downloads/7.ver 2>&1
      rm downloads/6.ver 2>&1
      break
      ;;
    7-0-10)
      export version='7.0.10'
      export version_for_url='7.0'
      rm downloads/8.ver 2>&1
      touch downloads/7.ver 2>&1
      rm downloads/6.ver 2>&1
      break
      ;;
    6-0-25)
      export version='6.0.25'
      export version_for_url='6.0'
      rm downloads/8.ver 2>&1
      rm downloads/7.ver 2>&1
      touch downloads/6.ver 2>&1
      break
      ;;    
    downloaded)
      if [ -e downloads/7.ver ]
      then
        export version='7.0.10'
        export version_for_url='7.0'
      else
        export version='6.0.25'
        export version_for_url='6.0'
      fi
      export skip_download='true'
      break
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
done

echo Please choose a platform: 
platform_options=("M1-Mac" "Intel-Mac" "Linux" "Linux-ARM" "Quit")
select opt in "${platform_options[@]}"
do
  case $opt in
    M1-Mac)
      echo "Configuring for an M1/M2/Mxxx Mac"
      sed -i '' 's/x86_64/aarch64/g' docker-compose.yml # weird mac sed
      export platform="aarch64"
      export distro="amzn2"
      break
      ;;
    Intel-Mac)
      echo "Configuring for an Intel Mac"
      sed -i '' 's/aarch64/x86_64/g' docker-compose.yml # weird mac sed
      export platform="x86_64"
      export distro="rhel8"
      break
      ;;
    Linux)
      echo "Configuring for Linux/Windows"
      sed -i 's/aarch64/x86_64/g' docker-compose.yml  # normal sed
      export platform="x86_64"
      export distro="rhel8"
      break
      ;;
    Linux-ARM)
      echo "Configuring for Generic-ARM"
      sed -i 's/x86_64/aarch64/g' docker-compose.yml  # linux dev server
      export platform="aarch64"
      export distro="amzn2"
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

# Set up urls based on the above parameters
if [[ "$version" == "8.0.0" ]] # Updates JDK to jdk-17.0.12+7.
then
  urls=("https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/${version_for_url}/${platform}/RPMS/mongodb-enterprise-server-7.0.0-1.el8.${platform}.rpm" "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-8.0.0.500.20240924T1611Z.x86_64.rpm" "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.4_7.tar.gz" "http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.${platform}.${distro}.rpm")
fi

if [[ "$version" == "7.0.10" ]] # Updates JDK to jdk-17.0.12+7.
then
  urls=("https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/${version_for_url}/${platform}/RPMS/mongodb-enterprise-server-7.0.0-1.el8.${platform}.rpm" "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-7.0.10.500.20240731T2149Z.x86_64.rpm" "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.12%2B7/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.12_7.tar.gz" "http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.${platform}.${distro}.rpm")
fi

if [[ "$version" == "6.0.25" ]] # Updates JDK to jdk-11.0.24+8
then
  urls=("https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/${version_for_url}/${platform}/RPMS/mongodb-enterprise-server-6.0.0-1.el8.${platform}.rpm" "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-6.0.25.100.20240807T1538Z.x86_64.rpm" "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%2B8/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.24_8.tar.gz" "http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.${platform}.${distro}.rpm")
fi

# echo === Downloading AppDB and Ops Manager ===
if [[ $skip_download != true ]]
then
  echo "Downloading AppDB from ${urls[0]}"
  curl -o downloads/mongodb-enterprise.${platform}.rpm -L "${urls[0]}"
  echo ""
  echo "Downloading Ops Manger from ${urls[1]}"
  curl -o downloads/mongodb-mms.x86_64.rpm -L "${urls[1]}"
  echo ""
  if [[ "$platform" == "aarch64" ]]
  then
    echo "Downloading JDK ${urls[2]}"
    curl -o downloads/jdk.${platform}.tar.gz -L "${urls[2]}"
  fi
  echo
fi 
# echo === Building/Running Ops Manager Container ===
docker compose up -d ops --build
echo
echo --- Waiting 5 minutes for Ops Manager to get going ---
echo
sleep 300
echo
echo --- Ops Manager setup ---
echo Please check http://localhost:8080 
echo If Ops Manager is running set central URL to http://ops.om.internal:8080
echo Please update 'mongodb-mms/automation-agent.config' with the correct values for
echo
echo mmsGroupId=xxxxxxxxxxxxxxxxxx
echo mmsApiKey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo
echo Press any key to attempt agent download from http://localhost:8080 using the above configuration settings
read -n 1 -p "Press Any Key to attempt Agent setup" mainmenuinput
echo
echo --- Downloading Agent ---
curl -o downloads/mongodb-agent.${platform}.rpm -L "${urls[3]}"
docker compose up -d node1
echo
echo --- Please check Ops Managers server tab for your running agents ---
echo Done