![header image](header.jpg)

# fugazi
X509 certificates that are only useful for local development. This is not a best-practices repo, 
this is merely meant to help developers generate some certificates so they can test their software 
in a local environment with TLS enabled. If you need further re-iteration on this point see the 
[disclaimer](#disclaimer).

## Generating certificates
You can take a look at `bin/generate-certs.sh` to see if you want to specify any of the environment variables 
or change anything. Otherwise, just run it:

```
bin/generate-certs.sh
```

By default it will create a `certs` directory with everything it generated. The things you probably want are:

* ca.crt - self-signed CA certificate in PEM format
* ca.key - CA private key
* server.crt - a "server" certificate in PEM format
* server.key - a "server" private key
* client.crt - a "client" certificate in PEM format
* client.key - a "client" private key

If you're using Java, don't worry it generated some JKS files you can test things with too. Java also supports PKCS12, 
so depending on your use case you could just reference the ```.p12``` files instead of the ```.jks``` ones.

* server.jks - key store containing server.p12 converted to JKS
* server-truststore.jks - trust store file containing imported ca.crt
* client.jks - key store containing client.p12 converted to JKS
* client-truststore.jks - trust store file containing imported ca.crt (same as server-truststore.jks)

The default password for everything is `123456`. 

## Tester Scripts
There are also some test scripts under the `bin` directory. One which will invoke `curl` and the other uses 
`openssl s_client`. They can be useful to dump certificate information to verify your software is responding 
correctly. If you already know what you're doing or have other methods, then feel free to ignore them.

## Disclaimer
For the love of God, never use anything like this for production use.
