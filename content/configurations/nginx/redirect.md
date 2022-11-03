---
title: 'redirect'

---

{{< code file="/files/configurations/nginx/redirect.conf" language="nginx" download="true" >}}

```bash
docker run --detach --name nginx-redirect \
    --volume "${PWD}/redirect.conf:/etc/nginx/conf.d/default.conf" \
    --publish "8080:80" \
    --workdir "/usr/share/nginx/html/" \
    nginx
curl -SsD- http://localhost:8080/
curl -SsD- -H "Host: www.example.com" http://localhost:8080/wrong-path
curl -SsD- -H "Host: www.example.com" http://localhost:8080/others
docker stop nginx-redirect
docker rm nginx-redirect
```
