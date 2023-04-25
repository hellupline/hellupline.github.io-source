---
title: 'cloudflare'

---


## export pagerules

```bash
curl --silent --show-error \
    --request GET \
    --url 'https://api.cloudflare.com/client/v4/zones/ZONE_ID/pagerules' \
    --header 'X-Auth-Email: AUTH' \
    --header 'X-Auth-Key: AUTH' \
    --header 'Content-Type: application/json' \
| jq --raw-output '
    .result[]
    | select(first(.targets[] | select(.constraint.value | contains("DOMAIN"))))
    | select(first(.targets[] | select(.target == "url")))
    | select(first(.actions[] | select(.id == "forwarding_url")))
    | [
        ([.targets[] | select(.target == "url") | .constraint.value] | join(",")),
        ([.actions[] | select(.id == "forwarding_url") | .value | "\(.url) - \(.status_code)"] | join(","))
      ]
    | @csv
'
```
