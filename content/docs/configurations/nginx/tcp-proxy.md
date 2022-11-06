---
title: 'tcp-proxy'

---

{{< code file="/files/docs/configurations/nginx/tcp-proxy.conf" language="nginx" download="true" >}}

```bash
docker run --detach --name nginx-tcp-proxy \
    --volume "${PWD}/tcp-proxy.conf:/etc/nginx/nginx.conf" \
    --publish "9000:9000" \
    --workdir "/usr/share/nginx/" \
    nginx
telnet localhost 9000
docker stop nginx-tcp-proxy
docker rm nginx-tcp-proxy
```
