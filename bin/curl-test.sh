#!/bin/bash
set -e
set -u

parent=$(dirname $0)
parent=$(cd $parent && pwd)
ssl_cert_dir="$parent/../certs"

if [ "$#" -ne 1 ]
then
  echo "Usage: ${0##*/} url"
  exit 1
fi

url=$1

# should work without using -k
curl -v -s --key $ssl_cert_dir/client.key --cert $ssl_cert_dir/client.crt --cacert $ssl_cert_dir/ca.crt $url
