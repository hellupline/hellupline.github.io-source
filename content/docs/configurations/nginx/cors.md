---
title: 'cors'

---

{{< code file="/files/docs/configurations/nginx/cors.conf" language="nginx" download="true" >}}

```bash
docker run --detach --name nginx-cors \
    --volume "${PWD}/cors.conf:/etc/nginx/conf.d/default.conf" \
    --volume "${PWD}/files:/var/www/cors" \
    --publish "8080:80" \
    --workdir "/var/www/cors" \
    nginx
curl -SsD- -X OPTIONS -D- http://localhost:8080/
docker stop nginx-cors
docker rm nginx-cors
```
