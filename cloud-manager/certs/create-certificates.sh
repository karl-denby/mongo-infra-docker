#/bin/bash
openssl genrsa -out mongodb-ca.key 4096
openssl req -new -x509 -days 1826 -key mongodb-ca.key -out mongodb-ca.crt -config conf/openssl-ca.cnf  -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
cat mongodb-ca.crt mongodb-ca.key > mongodb-ca.pem

#n1
openssl genrsa -out servers.cm.internal.key 4096
openssl req -new -key servers.cm.internal.key -out servers.cm.internal.csr -config conf/openssl-servers.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in servers.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out servers.cm.internal.crt -extfile conf/openssl-servers.cnf -extensions v3_req
cat servers.cm.internal.crt servers.cm.internal.key > servers.cm.internal.pem

#tidy
rm mongodb-ca.crt mongodb-ca.srl
rm servers.cm.internal.crt servers.cm.internal.key servers.cm.internal.csr
