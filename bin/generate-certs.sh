#!/bin/bash

set -e
set -u
set -x
parent=$(dirname $0)
parent=$(cd $parent && pwd)
ssl_cert_dir="$parent/../certs"

if [ -d "$ssl_cert_dir" ]; then
    cd $ssl_cert_dir
    # remove old certs
    echo "Removing old certs..."
    rm $ssl_cert_dir/*
else
    mkdir "$ssl_cert_dir"
    cd $ssl_cert_dir
fi

: ${PASSWORD:="123456"}

cfssl genkey -initca ../cfssl-csr.json | cfssljson -bare ca
cfssl gencert -ca ca.pem -ca-key ca-key.pem ../cfssl-csr.json | cfssljson -bare responder
cfssl gencert -ca ca.pem -ca-key ca-key.pem ../cfssl-csr.json | cfssljson -bare server
cfssl gencert -ca ca.pem -ca-key ca-key.pem ../cfssl-csr.json | cfssljson -bare client

cfssl ocspsign -ca ca.pem -responder responder.pem -responder-key responder-key.pem -cert server.pem | cfssljson -bare -stdout >> ocsp-responses

# make a Java JKS keystore from client certs
echo "Importing certs to Java keystore(s)..."

keytool -keystore server-truststore.jks -alias CARoot -import -file ca.pem -deststorepass "$PASSWORD" -noprompt
keytool -keystore client-truststore.jks -alias CARoot -import -file ca.pem -deststorepass "$PASSWORD" -noprompt

# convert to pkcs12 (Java can load pkcs12 as long as there is a password)
openssl pkcs12 -export -name server -passout pass:"$PASSWORD" -out server.p12 -inkey server-key.pem -in server.pem -certfile ca.pem -noiter -nomaciter
openssl pkcs12 -export -name server -passout pass:"$PASSWORD" -out client.p12 -inkey client-key.pem -in client.pem -certfile ca.pem -noiter -nomaciter
