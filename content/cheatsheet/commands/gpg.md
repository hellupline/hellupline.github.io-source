---
title: gpg
weight: 140
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## list output format

```bash
# sec   rsa4096/xxxxxxxxxxxxxxxx 0000-00-00 [SC]
#       yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
# uid                 [ultimate] My Name <me@mail.com>
# ssb   rsa4096/zzzzzzzzzzzzzzzz 0000-00-00 [E]
```

## generate key

```bash
gpg --full-generate-key
```

## encrypt

```bash
gpg \
   --output file.txt.enc \
   --encrypt \
   --local-user user@example.com \
   --recipient another@example.com \
   file.txt
```

## encrypt with passphrase

```bash
gpg --output file.txt.enc --symmetric file.txt
```

## decrypt

```bash
gpg --output file.txt --decrypt file.txt.enc
```

## sign file

```bash
gpg --sign --armor file.txt
```

## clear sign file

```bash
gpg --clear-sign file.txt
```

## verify file

```bash
gpg --output file.txt --verify file.txt.gpg
```

## detach sign file

```bash
gpg --output file.txt.sig --detach-sig file.txt
```

## detach verify file

```bash
gpg --verify file.txt.sig file.txt
```

## list privkeys

```bash
gpg --list-secret-keys --keyid-format LONG
```

## list pubkeys

```bash
gpg --list-public-keys --keyid-format LONG
```

## export pubkey ( for github )

```bash
gpg --output pubkey.asc --armor --export user@example.com
```

## export privkey

```bash
gpg --output privkey.asc --armor --export-secret-keys user@example.com
```

## import privkey

```bash
gpg --import privkey.asc

gpg --edit-key user@example.com trust quit
```

## change privkey  passphrase

```bash
gpg --edit-key user@example.com passwd save
```

## delete privkey

```bash
gpg --delete-secret-key user@example.com
```

## delete pubkey

```bash
gpg --delete--key user@example.com
```


## ssl pinning key

```bash
openssl s_client -servername hellupline.dev -connect hellupline.dev:443 -showcerts < /dev/null 2> /dev/null \
   | openssl x509 -outform pem \
   | openssl x509 -pubkey -noout \
   | openssl pkey -pubin -outform der \
   | openssl dgst -sha256 -binary \
   | openssl enc -base64
```
