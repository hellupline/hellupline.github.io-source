---
title: 'https'

---

{{< code file="/files/docs/configurations/nginx/https.conf" language="nginx" download="true" >}}

```bash
make-cacert org.local
make-cacert-certificate localhost
docker run --detach --name nginx-https \
    --volume "${PWD}/https.conf:/etc/nginx/conf.d/default.conf" \
    --volume "${PWD}/tls-certs/service.pem:/etc/letsencrypt/live/localhost/fullchain.pem" \
    --volume "${PWD}/tls-certs/service.pem:/etc/letsencrypt/live/localhost/chain.pem" \
    --volume "${PWD}/tls-certs/service.key:/etc/letsencrypt/live/localhost/privkey.pem" \
    --publish "4443:443" \
    --workdir "/usr/share/nginx/html/" \
    nginx
curl -SsD- --cacert tls-certs/rootca.cert https://localhost:4443/
docker stop nginx-https
docker rm nginx-https
```
