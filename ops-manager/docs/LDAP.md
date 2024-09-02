
## User and groups structure

All users have the same password, `Password1!`. The following users have been predefined:

### MongoDB database users
|User|MemberOf|
|-|-|
|uid=dba,ou=dbUsers,dc=tsdocker,dc=com|cn=dbAdmin,ou=dbRoles,dc=tsdocker,dc=com|
|uid=writer,ou=dbUsers,dc=tsdocker,dc=com|cn=readWriteAnyDatabase,ou=dbRoles,dc=tsdocker,dc=com|
|uid=reader,ou=DbUsers,dc=tsdocker,dc=com|cn=read,ou=dbRoles,dc=tsdocker,dc=com|

### Ops Manager Agents
|User|MemberOf|
|-|-|
|uid=mms-automation,ou=dbUsers,dc=tsdocker,dc=com|cn=automation,ou=dbRoles,dc=tsdocker,dc=com|
|uid=mms-monitoring,ou=dbUsers,dc=tsdocker,dc=com|cn=monitoring,ou=dbRoles,dc=tsdocker,dc=com|
|uid=mms-backup,ou=dbUsers,dc=tsdocker,dc=com|cn=backup,ou=dbRoles,dc=tsdocker,dc=com|

### Ops Manager users
|User|MemberOf|
|-|-|
|uid=owner,ou=omusers,dc=tsdocker,dc=com|cn=owners,ou=omgroups,dc=tsdocker,dc=com|
|uid=reader,ou=omusers,dc=tsdocker,dc=com|cn=readers,ou=omgroups,dc=tsdocker,dc=com|
|uid=admin,ou=omusers,dc=tsdocker,dc=com|cn=owners,ou=omgroups,dc=tsdocker,dc=com|

Use the extras.sh script and select "ldap" to start.

## How to Allow LDAP Auth in Ops Manager

* Access `Admin` At the top -> `Ops Manager Configiration` -> `User Authentication` and select
![](images/LDAP-01.png)
User Authentication Method: `LDAP`
LDAP URI: `ldap://ldap:389`
LDAP TLS/SSL CA File: `/certs/mongodb-ca.pem`
![](images/LDAP-02.png)
LDAP Bind Dn: `cn=admin,dc=tsdocker,dc=com`
LDAP Bind Password: `Password1!`
LDAP User Base Dn: `ou=omusers,dc=tsdocker,dc=com`
LDAP Group Base Dn: `ou=omgroups,dc=tsdocker,dc=com`
![](images/LDAP-03.png)
LDAP User Search Attribute: `uid`
LDAP Group Member Attribute: `member`
LDAP Global Role Owner: `cn=owners,ou=omgroups,dc=tsdocker,dc=com`
![](images/LDAP-04.png)
LDAP Users Eamil: `mail`
![](images/LDAP-05.png)
LDAP Global Role Read Only: `cn=readers,ou=omgroups,dc=tsdocker,dc=com`


## How to Allow LDAP Auth for Users in your deployments
1. Access your Organization -> Projects -> Security -> Settings -> Select `Username/Password (SCRAM-SHA-256)` & Click `Save Settings`.
![](images/LDAP-06.png)
2. Access the `MongoDB Users` tab and create an `admin@admin` user with `root@admin` role and the same password (`Password1!`).
![](images/LDAP-07.png)
3. `Review and Deploy` & `Approve and Deploy` the changes.
4. Access the `Settings` tab and select `LDAP` Then select `Native LDAP Authentication`.
![](images/LDAP-08.png)
![](images/LDAP-09.png)
Server URL (Required): `ladp:389`
Transport Security: `None`
Bind Method: `Simple`
SASL Mechanisms: `PLAIN`
Query User (LDAP Bind DN): `cn=admin,dc=tsdocker,dc=com`
Query Password (LDAP Bind DN): `Password1!`
![](images/LDAP-10.png)
[
        {
          match: "(.+)",
          substitution: "uid={0},ou=dbUsers,dc=tsdocker,dc=com"
        }
]
5. Click on `Validate LDAP Configuration` and make sure it returns Green and OK - if not retrace your steps and follow this guide to the T.
![](images/LDAP-11.png)

6. Under `LDAP Authorization` Turn on the `Acquire users and roles from LDAP` switch and fill in the following:
![](images/LDAP-12.png)
Authorization Query Template: `{USER}?memberOf?base`
7. Click `Save Settings`, `Review and Deploy` & `Confirm And Deploy` to enable your changes