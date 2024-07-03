#!/bin/bash
echo Please choose some extras: 
extra_options=("pause" "un-pause" "more-servers-x86_64" "more-servers-aarch64" "Quit")
select opt in "${extra_options[@]}"
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
    more-servers-x86_64)
      echo "Starting n4cm n5cm n6cm"
      docker compose -f docker-compose-x86_64.yml up -d n4cm n5cm n6cm
      break
      ;;
    more-servers-aarch64)
      echo "Starting n4cm, n5cm & n6cm"
      docker compose -f docker-compose-aarch64.yml up -d n4cm n5cm n6cm
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
