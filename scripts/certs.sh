#!/bin/bash

#Put your info here:
domain='yordomain'
st='Country'
o='Company'
email='your@email.com'
#

worDir=/magma/certs
days='3650'
rm $worDir/*
## GEnerating RSA private key

openssl genrsa -out $worDir/rootCA.key 2048
openssl req -x509 -new -nodes -key $worDir/rootCA.key -sha256 -days $days -subj "/C=NI/ST=$st/O=$o/OU=IT/CN=rootca.$domain/emailAddress=$email" -out $worDir/rootCA.pem
openssl genrsa -out $worDir/controller.key 2048
openssl req -new -key $worDir/controller.key -subj "/C=NI/ST=$st/O=$o/OU=IT/CN=*.$domain/emailAddress=$email" -out $worDir/controller.csr
openssl x509 -req -in $worDir/controller.csr -CA $worDir/rootCA.pem -CAkey $worDir/rootCA.key -CAcreateserial -out $worDir/controller.crt -days $days -sha256
rm $worDir/controller.csr $worDir/rootCA.key $worDir/rootCA.srl

openssl genrsa -out $worDir/certifier.key 2048
openssl req -x509 -new -nodes -key $worDir/certifier.key -sha256 -days $days -subj "/C=NI/ST=$st/O=$o/OU=IT/CN=certifier.$domain/emailAddress=$email" -out $worDir/certifier.pem
openssl genrsa -out $worDir/bootstrapper.key 2048
