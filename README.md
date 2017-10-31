![header image](header.jpg)

# fugazi
X509 certificates that are only useful for local development. This is not a best-practices repo, 
this is merely meant to help developers generate some certificates so they can test their software 
in a local environment with TLS enabled. If you need further re-iteration on this point see the 
[disclaimer](#disclaimer).

## Requirements
This project now requires [cfssl](https://github.com/cloudflare/cfssl) to run the main generation script `./bin/generate-certs.sh`.

Alternatively, you can run `./bin/generate-certs-openssl.sh` but it has nowhere near the functionality that you'll get from `cfssl`.

## Generating certificates
You can take a look at `bin/generate-certs.sh` and `cfssl-csr.json` to see if you want to specify any of the environment variables or change anything. Otherwise, just run it:

```
bin/generate-certs.sh
```

By default it will create a `certs` directory with everything it generated. The things you probably want are:

* ca.pem - self-signed CA certificate in PEM format
* ca-key.pem - CA private key
* server.pem - a "server" certificate in PEM format
* server-key.pem - a "server" private key
* client.pem - a "client" certificate in PEM format
* client-key.pem - a "client" private key

If you're using Java, this also generates some JKS files you can test things with too. Java supports PKCS12, so for the keystore use  ```.p12``` files, and truststores use ```.jks```.

* server.p12 - key store compatible PKCS12 format
* server-truststore.jks - trust store file containing imported ca.crt
* client.p12 - key store compatible PKCS12 format
* client-truststore.jks - trust store file containing imported ca.crt (same as server-truststore.jks)

The default password for everything is `123456`. 

## Tester Scripts
There are also some test scripts under the `bin` directory. One which will invoke `curl` and the other uses 
`openssl s_client`. They can be useful to dump certificate information to verify your software is responding correctly. If you already know what you're doing or have other methods, then feel free to ignore them.

## OCSP
Since this project now uses `cfssl` under the hood you can just use it run a quick OCSP server, like so:

```
cd certs && cfssl ocspserve -responses 'ocsp-responses'
```

See their project link below for more details.

## Disclaimer
For the love of God, this is not for production use. Don't do it.

## Projects for Production Deployments
- [Let's Encrypt clients](https://letsencrypt.org/docs/client-options/)
- [Vault](https://www.vaultproject.io/)
- [cfssl](https://github.com/cloudflare/cfssl)
