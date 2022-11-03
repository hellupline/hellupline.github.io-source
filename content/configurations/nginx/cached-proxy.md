---
title: 'cached-proxy'

---

{{< code file="/files/configurations/nginx/cached-proxy.conf" language="nginx" download="true" >}}

```bash
docker run --detach --name nginx-cached-proxy \
    --volume "${PWD}/cached-proxy.conf:/etc/nginx/conf.d/default.conf" \
    --publish "8080:80" \
    --workdir "/usr/share/nginx/html/" \
    nginx
curl -SsD- http://localhost:8080/
curl -SsD- http://localhost:8080/
curl -SsD- -H "No-Cache: 1" http://localhost:8080/
docker stop nginx-cached-proxy
docker rm nginx-cached-proxy
```
