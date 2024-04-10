#/bin/bash
openssl genrsa -out mongodb-ca.key 4096
openssl req -new -x509 -days 1826 -key mongodb-ca.key -out mongodb-ca.crt -config conf/openssl-ca.cnf  -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
cat mongodb-ca.crt mongodb-ca.key > mongodb-ca.pem

#n1
openssl genrsa -out n1.cm.internal.key 4096
openssl req -new -key n1.cm.internal.key -out n1.cm.internal.csr -config conf/openssl-n1.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n1.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n1.cm.internal.crt -extfile conf/openssl-n1.cnf -extensions v3_req
cat n1.cm.internal.crt n1.cm.internal.key > n1.cm.internal.pem

#n2
openssl genrsa -out n2.cm.internal.key 4096
openssl req -new -key n2.cm.internal.key -out n2.cm.internal.csr -config conf/openssl-n2.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n2.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n2.cm.internal.crt -extfile conf/openssl-n2.cnf -extensions v3_req
cat n2.cm.internal.crt n2.cm.internal.key > n2.cm.internal.pem

#n3
openssl genrsa -out n3.cm.internal.key 4096
openssl req -new -key n3.cm.internal.key -out n3.cm.internal.csr -config conf/openssl-n3.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n3.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n3.cm.internal.crt -extfile conf/openssl-n3.cnf -extensions v3_req
cat n3.cm.internal.crt n3.cm.internal.key > n3.cm.internal.pem

#tidy
rm mongodb-ca.crt mongodb-ca.srl
rm n1.cm.internal.crt n1.cm.internal.key n1.cm.internal.csr
rm n2.cm.internal.crt n2.cm.internal.key n2.cm.internal.csr
rm n3.cm.internal.crt n3.cm.internal.key n3.cm.internal.csr