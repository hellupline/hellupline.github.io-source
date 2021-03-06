---
title: curl
weight: 130
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

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

### cheatsheets

```bash
curl https://cht.sh/COMMAND
```

### ip address

```bash
curl https://ifconfig.co/
```

### dns resolve

```bash
curl -s https://dnsjson.com/hellupline.dev/A.json | jq '.results.records|sort'
```

### qr code

```bash
echo "my text" | curl --form 'data=<-' https://qrenco.de/
```

### weather

```bash
curl https://wttr.in/curitiba
```
