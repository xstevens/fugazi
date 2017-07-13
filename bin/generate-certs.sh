# This script is not intended to be secure. For development purposes only.
set -e
set -u

parent=$(dirname $0)
parent=$(cd $parent && pwd)
ssl_cert_dir="$parent/../certs"
echo "SSL_CERT_DIR: $ssl_cert_dir"

if [ -d "$ssl_cert_dir" ]; then
    cd $ssl_cert_dir
    # remove old certs
    echo "Removing old certs..."
    rm $ssl_cert_dir/*.{key,crt,csr,p12,jks,crl}
else
    mkdir "$ssl_cert_dir"
    cd $ssl_cert_dir
fi

: ${PASSWORD:="123456"}
: ${STATE="NY"}
: ${LOCALITY="New York"}
: ${ORGANIZATION="E Corp"}
: ${ORGANIZATION_UNIT="E Corp Security"}
: ${COMMON_NAME="localhost"}

echo "Generating certs..."
# generate CA key/cert
openssl genrsa -aes256 -passout pass:"$PASSWORD" -out ca.key 4096
openssl req -new -sha256 -passin pass:"$PASSWORD" -key ca.key -x509 -days 1095 -subj "/C=US/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT" -out ca.crt

# generate server key/cert
openssl genrsa -aes256 -passout pass:"$PASSWORD" -out server.key 2048
openssl req -new -sha256 -passin pass:"$PASSWORD" -key server.key -out server.csr -subj "/C=US/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"
openssl x509 -req -passin pass:"$PASSWORD" -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
openssl pkcs12 -export -name server -passin pass:"$PASSWORD" -passout pass:"$PASSWORD" -out server.p12 -inkey server.key -in server.crt -certfile ca.crt -noiter -nomaciter

# generate client key/cert
openssl genrsa -aes256 -passout pass:"$PASSWORD" -out client.key 2048
openssl req -new -sha256 -passin pass:"$PASSWORD" -key client.key -out client.csr -subj "/C=US/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"
openssl x509 -req -passin pass:"$PASSWORD" -days 365 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt
openssl pkcs12 -export -name client -passin pass:"$PASSWORD" -passout pass:"$PASSWORD" -out client.p12 -inkey client.key -in client.crt -certfile ca.crt -noiter -nomaciter
openssl rsa -in client.key -out client-nopass.key -passin pass:"$PASSWORD"

# Default SSH conf files always specify a directory of demoCA.
# We'll piggyback on that here to save a bit of work.
if [ ! -d "./demoCA" ]; then
    mkdir demoCA
    touch demoCA/index.txt
    echo 01 > demoCA/crlnumber
fi
# This isn't really necessary, but why not
openssl ca -passin pass:"$PASSWORD" -cert ca.crt -keyfile ca.key -gencrl -out ca.crl

# make a Java JKS keystore from client certs
echo "Importing certs to Java keystore(s)..."

keytool -keystore server-truststore.jks -alias CARoot -import -file ca.crt -deststorepass "$PASSWORD" -noprompt
keytool -keystore client-truststore.jks -alias CARoot -import -file ca.crt -deststorepass "$PASSWORD" -noprompt

keytool -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -srcstorepass "$PASSWORD" -destkeystore server.jks -deststorepass "$PASSWORD"
keytool -importkeystore -srckeystore client.p12 -srcstoretype pkcs12 -srcstorepass "$PASSWORD" -destkeystore client.jks -deststorepass "$PASSWORD"
