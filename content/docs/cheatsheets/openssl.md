---
title: 'openssl'

---


## ssl data

```bash
openssl s_client \
    -servername hellupline.dev \
    -connect hellupline.dev:443 \
    -showcerts \
    < /dev/null 2> /dev/null \
| openssl x509 \
    -nameopt sep_multiline \
    -noout \
    -subject \
    -issuer \
    -dates \
    -ext subjectAltName \
    -checkend 86400
```

## ssl pinning key

```bash
openssl s_client \
    -servername hellupline.dev \
    -connect hellupline.dev:443 \
    -showcerts \
    < /dev/null 2> /dev/null \
| openssl x509 -pubkey -noout \
| openssl pkey -pubin -outform der \
| openssl dgst -sha256 -binary \
| openssl enc -base64
```
