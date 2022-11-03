---
title: 'static-files'

---

{{< code file="/files/docs/configurations/nginx/static-files.conf" language="nginx" download="true" >}}

```bash
curl -Ss --create-dirs -o files/Helmet1.png  https://hellupline.dev/uploads/gallery/Helmet1_Sign.png
echo "hello" > files/index.html
docker run --detach --name nginx-static-files \
    --volume "${PWD}/static-files.conf:/etc/nginx/conf.d/default.conf" \
    --volume "${PWD}/files:/var/www/static-files" \
    --publish "8080:80" \
    --workdir "/var/www/static-files" \
    nginx
curl -SsD- -o Helmet1.png http://localhost:8080/Helmet1.png
curl -SsD- http://localhost:8080/
curl -SsD- http://localhost:8080/app
docker stop nginx-static-files
docker rm nginx-static-files
```
