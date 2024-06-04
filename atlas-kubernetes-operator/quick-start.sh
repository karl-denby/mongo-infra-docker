#!/bin/bash
if ! minikube &> /dev/null
then 
  echo "minikube could not be found, please install or setup your own cluster"
  exit 1
else
  minikube start --cpus=2 --memory=2G --disk-size=5000mb -p atlas
  echo "=== Kubernetes Setup ==="
  echo "- profile = atlas"
  echo "- CPUs = 2"
  echo "- Memory = 2G"
  echo "- Disk space= 5G" 
fi

if ! atlas &> /dev/null
then 
  echo "Atlas CLI not found attempting to download"
  echo Please choose a platform: 
  platform_options=("M1-Mac" "Intel-Mac" "Linux" "Linux-ARM" "Quit")
  select opt in "${platform_options[@]}"
  do
    case $opt in
        M1-Mac)
        echo "Downloading Atlas CLI for an M1/M2/Mxxx Mac"
        curl -L https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_1.23.0_macos_arm64.zip -o atlas-cli.zip
        mkdir atlas-cli
        unzip atlas-cli.zip -d atlas-cli
        break
        ;;
        Intel-Mac)
        echo "Downloading Atlas CLI for an Intel Mac"
        curl -L https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_1.23.0_macos_x86_64.zip -o atlas-cli.zip
        mkdir atlas-cli
        unzip atlas-cli.zip -d atlas-cli
        alias atlas=atlas-cli/bin/atlas
        break
        ;;
        Linux)
        echo "Downloading Atlas CLI for Linux"
        curl -L https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_1.23.0_linux_x86_64.tar.gz -o atlas-cli.tar.gz
        mkdir atlas-cli
        tar -xzf atlas-cli.tar.gz -C atlas-cli --strip-components=1
        alias atlas=atlas-cli/bin/atlas
        break
        ;;
        Linux-ARM)
        echo "Downloading Atlas CLI for Linux-ARM"
        curl -L https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_1.23.0_linux_arm64.rpm -o atlas-cli.tar.gz
        mkdir atlas-cli
        tar -xzf atlas-cli.tar.gz -C atlas-cli --strip-components=1
        alias atlas=atlas-cli/bin/atlas
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
fi

echo "=== Using Atlas CLI to setup kubernetes operator"
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-atlas-kubernetes/v2.2.2/deploy/all-in-one.yaml
echo "Operator is installed"
echo ""
kubectl get pods -n mongodb-atlas-system
echo ""
echo "Please visit https://www.mongodb.com/docs/atlas/operator/stable/ak8so-quick-start/ to continue"
exit 0