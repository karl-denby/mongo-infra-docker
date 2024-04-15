#/bin/bash
openssl genrsa -out mongodb-ca.key 4096
openssl req -new -x509 -days 1826 -key mongodb-ca.key -out mongodb-ca.crt -config conf/openssl-ca.cnf  -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
cat mongodb-ca.crt mongodb-ca.key > mongodb-ca.pem

#n1
openssl genrsa -out n1om.om.internal.key 4096
openssl req -new -key n1om.om.internal.key -out n1om.om.internal.csr -config conf/openssl-n1om.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n1om.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n1om.om.internal.crt -extfile conf/openssl-n1om.cnf -extensions v3_req
cat n1om.om.internal.crt n1om.om.internal.key > n1om.om.internal.pem

#n2
openssl genrsa -out n2om.om.internal.key 4096
openssl req -new -key n2om.om.internal.key -out n2om.om.internal.csr -config conf/openssl-n2om.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n2om.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n2om.om.internal.crt -extfile conf/openssl-n2om.cnf -extensions v3_req
cat n2om.om.internal.crt n2om.om.internal.key > n2om.om.internal.pem

#n3
openssl genrsa -out n3om.om.internal.key 4096
openssl req -new -key n3om.om.internal.key -out n3om.om.internal.csr -config conf/openssl-n3om.cnf -subj "/C=IE/ST=Leinster/L=Dublin/O=Support Example/OU=Customer Engineering/CN=om.internal"
openssl x509 -req -days 365 -in n3om.om.internal.csr -CA mongodb-ca.crt -CAkey mongodb-ca.key -CAcreateserial -out n3om.om.internal.crt -extfile conf/openssl-n3om.cnf -extensions v3_req
cat n3om.om.internal.crt n3om.om.internal.key > n3om.om.internal.pem

#tidy
rm mongodb-ca.crt mongodb-ca.srl
rm n1om.om.internal.crt n1om.om.internal.key n1om.om.internal.csr
rm n2om.om.internal.crt n2om.om.internal.key n2om.om.internal.csr
rm n3om.om.internal.crt n3om.om.internal.key n3om.om.internal.csr