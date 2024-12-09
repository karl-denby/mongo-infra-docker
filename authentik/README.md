# This is in-progress don't expect much yet

## Work done so far

- setup docker compose and .env files so that `docker compose up -d` will get authentik running
- created a README.md for adding documentation, as this will need some
- update the main readme to reference this document
- create the branch and upload it to github

## Setup of Authentik

- complex stuff happens here

## Setup up Ops Manager LDAP

- First setup a user named akadmin (ak - admin) and make them a global owner, set your email address on this user
- Admin > Ops Manager Config > User Authentication
- User Authentication Method: LDAP
- LDAP URI: ldap://ldap.om.internal:3389
- LDAP Bind Dn: cn=akadmin,ou=users,dc=ldap,dc=goauthentik,dc=io
- LDAP Bind Password: `whatever you set in authentik`
- LDAP User Base Dn: dc=ldap,dc=goauthentik,dc=io
- LDAP User Search Attribute: could be `sAMAccountName` (if you gave a name like akaadmin for your user) or `mail` (if you gave your email address)
- LDAP User Group: member
- LDAP Global Role Owner: cn=authentik Admins,ou=groups,dc=ldap,dc=goauthentik,dc=io `if you used akadmin`
