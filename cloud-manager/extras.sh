#!/bin/bash
echo Please choose some extras: 
platform_options=("pause" "un-pause" "more-servers" "even-more-servers" "Quit")
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
      echo "Starting n2cm and n3cm"
      docker compose up -d n2cm n3cm
      break
      ;;
    even-more-servers)
      echo "Starting n4cm, n5cm & n6cm"
      docker compose up -d n4cm n5cm n6cm
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
