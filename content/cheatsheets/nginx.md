---
title: 'nginx'

---


## run with configuration files

```bash
docker run --rm -it --name=static-site \
    --volume "${PWD}/conf.d:/etc/nginx/conf.d/" \
    --volume "${PWD}/public:/usr/share/nginx/html" \
    --publish 8080:80 \
    --workdir /usr/share/nginx/html \
    nginx
```
