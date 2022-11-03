---
title: 'curl'

---


## debug requests

```bash
curl \
    --silent \
    --show-error \
    --fail \
    --fail-early \
    --compressed \
    --location \
    --create-dirs \
    --dump-header - \
    --output /dev/null \
    --write-out '
=============  HOST:  ==========
           local_ip:  %{local_ip}
         local_port:  %{local_port}
          remote_ip:  %{remote_ip}
        remote_port:  %{remote_port}
=======  CONNECTION:  ==========
       http_version:  %{http_version}
          http_code:  %{http_code}
       http_connect:  %{http_connect}
       num_connects:  %{num_connects}
      num_redirects:  %{num_redirects}
       redirect_url:  %{redirect_url}
=============  FILE:  ==========
       content_type:  %{content_type}
 filename_effective:  %{filename_effective}
     ftp_entry_path:  %{ftp_entry_path}
      size_download:  %{size_download}
        size_header:  %{size_header}
       size_request:  %{size_request}
        size_upload:  %{size_upload}
     speed_download:  %{speed_download}
       speed_upload:  %{speed_upload}
  ssl_verify_result:  %{ssl_verify_result}
      url_effective:  %{url_effective}
===  TIME BREAKDOWN:  ==========
    time_appconnect:  %{time_appconnect}
       time_connect:  %{time_connect}
    time_namelookup:  %{time_namelookup}
   time_pretransfer:  %{time_pretransfer}
      time_redirect:  %{time_redirect}
 time_starttransfer:  %{time_starttransfer}
                      ----------
         time_total:  %{time_total}
' \
    --header 'User-Agent: curl-debug/0.1' \
    --request GET \
    --url https://example.com
```


## ip address

```bash
# curl https://ident.me/  # https://api.ident.me/
curl https://ident.me/json | jq
# curl https://checkip.amazonaws.com/
```


## dns resolve

```bash
curl https://dnsjson.com/hellupline.dev/A.json | jq '.results.records|sort'
```


## qr code

```bash
echo 'my text' | curl --form 'data=<-' https://qrenco.de/
```


## cheatsheets

```bash
curl https://cht.sh/tar
```


## weather

```bash
curl https://v2.wttr.in/curitiba
```
