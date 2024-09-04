#!/bin/bash
service slapd start

ldapsearch -x -w Password1! -D cn=admin,dc=om,dc=internal -b dc=om,dc=internal
ldapmodify -Y external -H ldapi:/// -f /tmp/slapdlog.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/memberof.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/refint.ldif
ldapadd -x -D cn=admin,dc=om,dc=internal -w Password1! -f /tmp/users.ldif
ldapadd -x -D cn=admin,dc=om,dc=internal -w Password1! -f /tmp/groups.ldif
# ldapmodify -Y external -H ldapi:/// -f /tmp/olcSSL.ldif
#rm -rf /tmp/*.conf /tmp/*.ldif
ldapsearch -x -w Password1! -D cn=admin,dc=om,dc=internal -b dc=om,dc=internal 

echo "==== LDAP INIT from script FINISHED ====" >> /var/log/system