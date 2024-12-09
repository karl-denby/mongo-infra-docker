# This is in-progress don't expect much yet

## Work done so far

- setup docker compose and .env files so that `docker compose up -d` will get authentik running
- created a README.md for adding documentation, as this will need some
- update the main readme to reference this document
- create the branch and upload it to github

## Setup of Authentik for LDAP

- Setup an OM first as that is what will create the network for us
  - Sign up as the first user `akadmin` (AK Admin)
  - you can set whatever password you like
  - you can proceed to setup ops manager or wait on the authentication configuration page
- Make sure you are in the authentik folder (you are probably still in the ops-manager folder `cd ../authentik`)
- `docker compose up -d`
- Once its done visit http://localhost:9000
  - If you where here before you can use the user you setup previously
  - Otherwise setup a new user
  - if you forgot how to log in a previous user run this to generate the recovery
  - `docker compose run --rm server create_recovery_key 10 akadmin`
  - add whatever it outputs to the url
  - Click the settings gear cog
  - Click **Change Password** and set something you will remember
- Click **Admin Interface**
- Navigate to Applications > Providers  > Create
  - LDAP provider
  - name: ldap-for-om
  - defaults for everything else
- Navigate to Applications > Applications  > Create
  - Name: om
  - Slug: om
  - provider: ldap-for-om
  - backchannel: ldap-for-om
- Navigate to Applications > outposts  > Create
  - Name: ldap-provider
  - Type: ldap
  - Move application om from left side to right side
  - Create
- Click on your new ldap-provider 'View Deployment Info'
- Click to copy token
- Update the docker-compose.yml file with this token, its near the end `AUTHENTIK_TOKEN: s4vflFdXrrs8aX3kp98n6NoQbM8G63I1dNfSkh76cUYvGmz5DL74up9RSo01`
- Run `docker compose up -d` to apply this change
- Wait a few seconds and then refresh the outpost page, you want to see the status of ldap-provider is now green and not 'not available'
- I want to start again `docker volume ls` will show you athentic volumes
  - remove them with `docker volume rm <volume>`
  - `docker volume prune` will clean up lots of stuff (maybe too much in some cases)

## Testing LDAP with ldapsearch

- The Ops Manager host is a good place to start
- `docker exec -it ops /bin/bash`
- `yum install openldap-clients`
- `ping ldap`
- `ldapsearch -x -b "dc=ldap,dc=goauthentik,dc=io" -H ldap://ldap:3389 -D "cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io" -W`

## Setup up Ops Manager LDAP

- First setup a user named akadmin (A..K...admin) and make them a global owner, set your email address on this user
- Admin > Ops Manager Config > User Authentication
- User Authentication Method: LDAP
- LDAP URI: ldap://ldap.om.internal:3389
- LDAP Bind Dn: cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io
- LDAP Bind Password: `whatever you set in authentik`
- LDAP User Base Dn: dc=ldap,dc=goauthentik,dc=io
- LDAP User Search Attribute: could be `sAMAccountName` (if you gave a name like akadmin for your user) or `mail` (if you gave your email address)
- LDAP User Group: member
- LDAP Global Role Owner: cn=authentik Admins,ou=groups,dc=ldap,dc=goauthentik,dc=io `if you used akadmin`

## Setup LDAP for an MongoDB Deployment

- Go to Deployment > Security > Settings of you project
- Turn on LDAP > Native LDAP Authentication
- Server URL: ldap.om.internal:3389
- Transport Security: None
- Bind Method: Simple
- Query User: cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io
- Query Password: `whatever you set in authentik`
- Validate the LDAP setup, you want to see `Validated: LDAP Connectivity test successful on node1.om.internal`
- Set the Agent username and password to the same values as Query User/Password above
- Save Setting

## Doing an LDAP test login with mongosh

- docker exec -it node1 /bin/bash
- cd /var/lib/mongodb-mms-automation/mongosh-linux-x86-x.x.x/bin
- ./mongosh --username cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io --password  --authenticationDatabase '$external' --authenticationMechanism "PLAIN"  --host "localhost" --port 27017
- It should look like this:

```console
[root@node1 bin]# ./mongosh --username cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io --password  --authenticationDatabase '$external' --authenticationMechanism "PLAIN"  --host "localhost" --port 27017
Enter password: *********
Current Mongosh Log ID: 67570b495208d2538f079057
Connecting to:          mongodb://<credentials>@localhost:27017/?directConnection=true&serverSelectionTimeoutMS=2000&authSource=%24external&authMechanism=PLAIN&appName=mongosh+2.2.4
Using MongoDB:          7.0.15
Using Mongosh:          2.2.4

For mongosh info see: https://docs.mongodb.com/mongodb-shell/

 
Deprecation warnings:
  - Using mongosh with OpenSSL versions lower than 3.0.0 is deprecated, and support may be removed in a future release.
See https://www.mongodb.com/docs/mongodb-shell/install/#supported-operating-systems for documentation on supported platforms.
Enterprise myReplicaSet [direct: primary] test> 
```

## Extra

You can navigate to Directory and:

- Users: Create other users
- Groups: Create other groups
