# BI Connector

* Check OM Release notes for RHEL8 x86/ARM support

In Order to allow BI Connector to run properly on Mx Macs, a little workaround is required:

1. Once the Ops Manager is up and running access its docker via
```
docker exec -it ops -- /bin/bash
```
2. In order replace the x86_x64 version of the bi connector with the arm64 version, run this command (and select yes to overwrite):
```
mv /opt/mongodb/mms/agent/biconnector/mongodb-bi-linux-arm64-rhel82-v2.14.13.tgz /opt/mongodb/mms/agent/biconnector/mongodb-bi-linux-x86_64-rhel80-v2.14.13.tgz
```
3. Now install the BI Connector on your node via Ops Manager, I suggest to configure it on port 27719.
4. Access localhost 27719 on your mac with a mysql client to access the bi connector on your node.
