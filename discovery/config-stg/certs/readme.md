
* Follow the steps below to create the certs for NGINX 

```
openssl genrsa -out ca.key 2048;
openssl req -x509 -new -nodes -key ca.key -days 1825 -out ca.crt -subj "/CN=ca";
openssl genrsa -out sc-npe.key 2048;
openssl req -new -key sc-npe.key -out sc-npe.csr -subj "/CN=discovery.spectrocloud.com" -config req.cnf;
openssl x509 -req -in sc-npe.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out sc-npe.crt -days 1825 -extensions v3_req -extfile req.cnf;
```

