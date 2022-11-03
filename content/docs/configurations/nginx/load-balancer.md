---
title: 'load-balancer'

---

{{< code file="/files/docs/configurations/nginx/load-balancer.conf" language="nginx" download="true" >}}

```bash
docker run --detach --name nginx-load-balancer \
    --volume "${PWD}/load-balancer.conf:/etc/nginx/conf.d/default.conf" \
    --publish "8080:80" \
    --workdir "/usr/share/nginx/html/" \
    nginx
curl -SsD- http://localhost:8080/app01;
curl -SsD- http://localhost:8080/app02;
docker stop nginx-load-balancer
docker rm nginx-load-balancer
```
