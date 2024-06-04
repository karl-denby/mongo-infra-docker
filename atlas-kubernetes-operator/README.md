# Atlas Kubernetes Operator and Minikube

Get a kubernetes cluster, the MongoDB Atlas Kubernetes Operator and and Atlas Project/Database setup in minimal time/effor

## Requirements
- minikube if you want this script to setup a cluster for you
- An Atlas account (where you will deploy your cluster)
- An Atlas API Key (how the operator talks to Atlas)

## Usage
Simply run this command (from this folder) and follow the prompts:
```
bash quick-start.sh
```

## Atlas Setup

Normally you would setup an org key and create a project using the operator, our atlas org is a bit special in how each of use has a project called firstname.lastname so we will use a project key, within our own project with **Project Owner** rights

Go to your project create a key with project owner, it should look like this:
- imfzknhz # (run through echo imfzknhz | base64 ) aW1memtuaHoK
- 332b4675-0d21-455c-be51-81bad9b69726 # (run through echo imfzknhz | base64 ) MzMyYjQ2NzUtMGQyMS00NTVjLWJlNTEtODFiYWQ5YjY5NzI2Cg==
- 77.107.233.162 (Dublin Office)

## Atlas CLI this seems to fail as in the next step this key is used to create another key but fails as its a project key not a org key
```
[karl@nixos:~/Kubernetes/atlas]$ atlas config init
You are configuring a profile for atlas.

All values are optional and you can use environment variables (MONGODB_ATLAS_*) instead.

Enter [?] on any option to get help.

? Public API Key: ufigwqhw
? Private API Key: [? for help] ************************************
? Default Output Format: plaintext

Your profile is now configured.
You can use [atlas config set] to change these settings at a later time.
```

## Install Operator (for a specific project)
```
[karl@nixos:~/Kubernetes/atlas]$ atlas kubernetes operator install --projectName karl.denby

[karl@nixos:~/Kubernetes/atlas]$ kubectl get secrets
NAME                                 TYPE     DATA   AGE
mongodb-atlas-karldotdenby-api-key   Opaque   3      17m
```

We will need that secret name `mongodb-atlas-karldotdenby-api-key` in the next step. For now go to atlas, find this key and add an ip to it as we restrict by IP in our org.

## Create a project in k8s to match up the Atlas project
```
[karl@nixos:~/Kubernetes/atlas]$ cat <<EOF | kubectl apply -f -
apiVersion: atlas.mongodb.com/v1
kind: AtlasProject
metadata:
  name: karl.denby
  labels:
    app.kubernetes.io/version: 1.6.0
spec:
  connectionSecretRef:                          ### add this
    name: mongodb-atlas-karldotdenby-api-key    ### and this from above
  name: karl.denby
  projectIpAccessList:
    - ipAddress: "77.107.233.162"               ### adjust this
      comment: "Allowing access from Dublin office"
EOF
```

The end result of this should be not much happens in `kubectl get atlasprojects.atlas.mongodb.com -o yaml` you should see ValidationSucceeded True, projectready true, I also get a warning about AtlasDeleteProtection for IPAccessListReady but I'm choosing to ignore that for now

## Create a deployment in our K8s Project, which should created a database in the matching Atlas Project
```
[karl@nixos:~/Kubernetes/atlas]$ cat <<EOF | kubectl apply -f -
apiVersion: atlas.mongodb.com/v1
kind: AtlasDeployment
metadata:
  name: my-atlas-cluster
  labels:
    app.kubernetes.io/version: 2.0.1
spec:
  projectRef:
    name: karl.denby
  deploymentSpec:
    clusterType: "REPLICASET"
    name: K8sCluster
    mongoDBMajorVersion: "6.0"
    replicationSpecs:
      - regionConfigs:
        - electableSpecs:
            instanceSize: M10
            nodeCount: 3
          providerName: AWS
          regionName: EU_WEST_1
          priority: 7
EOF
```

This could take a while, because all the work is happening in Atlas/AWS

## If we delete the kubernetes object we are no longer managing this cluster with the operator, its detached and as if we just set it up with the API directly

```
[karl@nixos:~/Kubernetes/atlas]$ kubectl get atlasdeployments.atlas.mongodb.com 
NAME               AGE
my-atlas-cluster   40m

[karl@nixos:~/Kubernetes/atlas]$ kubectl delete atlasdeployments.atlas.mongodb.com/my-atlas-cluster 
atlasdeployment.atlas.mongodb.com "my-atlas-cluster" deleted

[karl@nixos:~/Kubernetes/atlas]$ kubectl logs deployments/mongodb-atlas-operator | grep "Not removing"
{"level":"INFO","time":"2024-03-14T09:27:28.984Z","msg":"Not removing Atlas deployment from Atlas as per configuration","atlasdeployment":"default/my-atlas-cluster"}
```

Try add a tag to your cluster to prove that you can do this without it being removed or reverted by the operator.

## Import this cluster back under the control of the operator 
We want to do this when we have an existing cluster that we want to bring into the control of our kubernetes operator, this allows our devops teams that work in kubernetes all day to be able to see everything they need in kubernetes without having to log into the atlas cluster

```
atlas kubernetes config generate --projectId=658d47720a60ee48e5396a9d \
--includeSecrets --targetNamespace=default
```

All this **generate** subcommand does it spit out a yaml file, the idea is that you can validate what is going to be setup, it also way more verbose than our initial config file so it almost acts as a template for every single setting you could every want, you could pipe this to a file, change some things then apply it

If we change **generate** to **apply** (and remove includeSecrets) it will create this config on our operator, as it matches what is configured in atlas already it shouldn't generate any kind of changes

```
[karl@nixos:~/Kubernetes/atlas]$ atlas kubernetes config apply --projectId=658d47720a60ee48e5396a9d --targetNamespace=default
Error: version '2.1.0' is not supported
```

## You should not see your project in the list of atlasdeployments
```
[karl@nixos:~]$ kubectl get atlasdeployments.atlas.mongodb.com 
NAME                      AGE
karldotdenby-k8scluster   10m
```

note the new name, we can edit this and remove the tag we added earlier
```
kubectl edit atlasdeployments.atlas.mongodb.com karldotdenby-k8scluster
atlasdeployment.atlas.mongodb.com/karldotdenby-k8scluster edited
```

## Clean up
To remove the minikube cluster and any tools that where downloaded to this directory simply run

`bash clean-up.sh`