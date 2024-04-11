#/bin/bash
openssl genrsa -out mongodb-ca.key 4096
openssl req -new -x509 -days 1826 -key mongodb-ca.key -out mongodb-ca.crt -config conf/openssl-ca.cnf  -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
cat mongodb-ca.crt mongodb-ca.key > mongodb-ca.pem

#n1
openssl genrsa -out n1.om.internal.key 4096
openssl req -new -key n1.om.internal.key -out n1.om.internal.csr -config conf/openssl-n1.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n1.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n1.om.internal.crt -extfile conf/openssl-n1.cnf -extensions v3_req
cat n1.om.internal.crt n1.om.internal.key > n1.om.internal.pem

#n2
openssl genrsa -out n2.om.internal.key 4096
openssl req -new -key n2.om.internal.key -out n2.om.internal.csr -config conf/openssl-n2.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n2.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n2.om.internal.crt -extfile conf/openssl-n2.cnf -extensions v3_req
cat n2.om.internal.crt n2.om.internal.key > n2.om.internal.pem

#n3
openssl genrsa -out n3.om.internal.key 4096
openssl req -new -key n3.om.internal.key -out n3.om.internal.csr -config conf/openssl-n3.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n3.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n3.om.internal.crt -extfile conf/openssl-n3.cnf -extensions v3_req
cat n3.om.internal.crt n3.om.internal.key > n3.om.internal.pem

#tidy
rm mongodb-ca.crt mongodb-ca.srl
rm n1.om.internal.crt n1.om.internal.key n1.om.internal.csr
rm n2.om.internal.crt n2.om.internal.key n2.om.internal.csr
rm n3.om.internal.crt n3.om.internal.key n3.om.internal.csr