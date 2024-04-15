#/bin/bash
openssl genrsa -out mongodb-ca.key 4096
openssl req -new -x509 -days 1826 -key mongodb-ca.key -out mongodb-ca.crt -config conf/openssl-ca.cnf  -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
cat mongodb-ca.crt mongodb-ca.key > mongodb-ca.pem

#n1
openssl genrsa -out n1cm.cm.internal.key 4096
openssl req -new -key n1cm.cm.internal.key -out n1cm.cm.internal.csr -config conf/openssl-n1cm.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n1cm.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n1cm.cm.internal.crt -extfile conf/openssl-n1cm.cnf -extensions v3_req
cat n1cm.cm.internal.crt n1cm.cm.internal.key > n1cm.cm.internal.pem

#n2
openssl genrsa -out n2cm.cm.internal.key 4096
openssl req -new -key n2cm.cm.internal.key -out n2cm.cm.internal.csr -config conf/openssl-n2cm.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n2cm.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n2cm.cm.internal.crt -extfile conf/openssl-n2cm.cnf -extensions v3_req
cat n2cm.cm.internal.crt n2cm.cm.internal.key > n2cm.cm.internal.pem

#n3
openssl genrsa -out n3cm.cm.internal.key 4096
openssl req -new -key n3cm.cm.internal.key -out n3cm.cm.internal.csr -config conf/openssl-n3cm.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=cm.internal"
openssl x509 -req -days 365 -in n3cm.cm.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n3cm.cm.internal.crt -extfile conf/openssl-n3cm.cnf -extensions v3_req
cat n3cm.cm.internal.crt n3cm.cm.internal.key > n3cm.cm.internal.pem

#tidy
rm mongodb-ca.crt mongodb-ca.srl
rm n1cm.cm.internal.crt n1cm.cm.internal.key n1cm.cm.internal.csr
rm n2cm.cm.internal.crt n2cm.cm.internal.key n2cm.cm.internal.csr
rm n3cm.cm.internal.crt n3cm.cm.internal.key n3cm.cm.internal.csr