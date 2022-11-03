---
title: 'network'

---



## locate servers in network

```bash
nmap -p22 --open '192.168.100.0/24'
# nmap '192.168.100.0/24'
```


## list open ports

```bash
lsof -nP -i'TCP:22' -i'TCP:1313' -s'TCP:LISTEN'
# lsof -nP -i'TCP' -s'TCP:LISTEN'
```


## list active connections

```bash
lsof -nP -i'TCP' -s'TCP:ESTABLISHED'
```


## dns query records

```bash
# dig @1.1.1.1 +trace example.com AAAA
dig @1.1.1.1 +short example.com AAAA
```


## curl

### debug requests

```bash
curl \
   --silent --show-error \
   --fail --fail-early \
   --compressed --location \
   --create-dirs \
   --dump-header - --output - \
   --write-out '
           time_namelookup:  %{time_namelookup}
              time_connect:  %{time_connect}
           time_appconnect:  %{time_appconnect}
          time_pretransfer:  %{time_pretransfer}
             time_redirect:  %{time_redirect}
        time_starttransfer:  %{time_starttransfer}
                           ----------
                time_total:  %{time_total}
    ' \
   --request GET --url https://example.com
```


### ip address

```bash
# curl https://ident.me/  # https://api.ident.me/
curl https://ident.me/json | jq
# curl https://checkip.amazonaws.com/
```


### qr code

```bash
echo "my text" | curl --form 'data=<-' https://qrenco.de/
```


### weather

```bash
curl https://v2.wttr.in/curitiba
# curl https://wttr.in/curitiba
```


## netcat

### listen to port

```bash
netcat -vvv -l -p 8000 -s localhost
```


### connect to server

```bash
netcat -vvv localhost 8000
```


### port tunnel

```bash
netcat -vvv -L "localhost:8001" -p 8000 -s localhost
```
