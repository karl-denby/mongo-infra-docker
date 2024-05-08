#!/bin/bash

version_options=("7-0-5" "6-0-23")
echo Please choose a version: 
select opt in "${version_options[@]}"
do
  case $opt in
    7-0-5)
      export version='7.0.5'
      export version_for_url='7.0'
      break
      ;;
    6-0-23)
      export version='6.0.23'
      export version_for_url='6.0'
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
      echo "Configuring for Linux"
      sed -i 's/aarch64/x86_64/g' docker-compose.yml  # normal sed
      export platform="x86_64"
      export distro="rhel8"
      break
      ;;
    Linux-ARM)
      echo "Configuring for Linux-ARM"
      sed -i 's/x86_64/aarch64/g' docker-compose.yml  # linux dev server
      export platform="aarch64"
      export distro="amazn2"
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
if [[ "$version" == "7.0.5" ]]
then
  urls=("https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/${version_for_url}/${platform}/RPMS/mongodb-enterprise-server-7.0.0-1.el8.${platform}.rpm" "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-7.0.5.500.20240429T1414Z.x86_64.rpm" "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz" "http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.${platform}.${distro}.rpm")
fi

if [[ "$version" == "6.0.23" ]]
then
  urls=("https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/${version_for_url}/${platform}/RPMS/mongodb-enterprise-server-6.0.0-1.el8.${platform}.rpm" "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-6.0.23.100.20240402T1837Z.x86_64.rpm" "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22%2B7/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.22_7.tar.gz" "http://localhost:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.${platform}.${distro}.rpm")
fi


# echo === Downloading AppDB and Ops Manager ===
echo "Downloading AppDB from ${urls[0]}"
curl -o mongodb-enterprise.${platform}.rpm -L "${urls[0]}"
echo ""
echo "Downloading Ops Manger from ${urls[1]}"
curl -o mongodb-mms.x86_64.rpm -L "${urls[1]}"
echo ""
if [[ "$platform" == "aarch64" ]]
then
  echo "Downloading JDK ${urls[2]}"
  curl -o jdk.${platform}.tar.gz -L "${urls[2]}"
fi
echo 
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
curl -o mongodb-agent.${platform}.rpm -L "${urls[3]}"
docker compose up -d node1
echo
echo --- Please check Ops Managers server tab for your running agents ---
echo Done