#!/bin/bash
set -e
set -u

parent=$(dirname $0)
parent=$(cd $parent && pwd)
ssl_cert_dir="$parent/../certs"

: ${OPENSSL_BIN:="openssl"}

if [ "$#" -ne 1 ]
then
  echo "Usage: ${0##*/} host"
  exit 1
fi

target_host=$1
$OPENSSL_BIN s_client -connect $target_host -CAfile $ssl_cert_dir/ca.pem -showcerts -debug 
