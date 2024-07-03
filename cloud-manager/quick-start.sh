#!/bin/bash

echo Please choose a platform: 
platform_options=("M1-Mac" "x86_64-Other")
select opt in "${platform_options[@]}"
do
  case $opt in
    M1-Mac)
      echo "Configuring for an M1/M2/Mx Mac"
      export asset="./assets/aarch64_CM-agent.sh"
      export platform=aarch64
      break
      ;;
    x86_64-Other)
      echo "Configuring for x86_64 (Windows/Linux/Mac)"
      export asset="./assets/x86_64_CM-agent.sh"
      export platform=x86_64
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

echo *** Downloading Latest Cloud Manager Agent for "$opt" ***
bash "$asset"
echo
echo --- Cloud Manager setup ---
echo Please check https://cloud.mongodb.com/ and access your CM
echo
echo "(Access your Project --> Agents --> Downloads & Settings --> Select Your Operating System --> ANY --> Generate API Key)"
echo
echo Please update 'mongodb-mms/automation-agent.config' with the correct values for
echo
echo mmsGroupId=xxxxxxxxxxxxxxxxxx
echo mmsApiKey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
echo
read -r -n 1 -p "Press Any Key to attempt Agent setup" mainmenuinput
docker compose -f docker-compose-$platform.yml up -d n1cm n2cm n3cm
echo
echo --- Please check Cloud Managers server tab for your running agents ---
echo Done