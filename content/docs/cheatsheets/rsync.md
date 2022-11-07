---
title: 'rsync'

---


## base rsync

```bash
rsync \
    --verbose \
    --info='progress2,stats3' \
    --no-inc-recursive \
    --partial \
    --archive \
    --hard-links \
    --perms \
    --xattrs \
    --acls \
    --one-file-system \
    --exclude 'stuff/_data' \
    -- \
    'SOURCE_OBJECT_1' \
    'SOURCE_OBJECT_2' \
    'SOURCE_OBJECT_3' \
    'TARGET'
```


## using ssh

```bash
rsync \
    --verbose \
    --info='progress2,stats3' \
    --no-inc-recursive \
    --partial \
    --archive \
    --hard-links \
    --perms \
    --xattrs \
    --acls \
    --one-file-system \
    --rsh='ssh -T -c chacha20-poly1305@openssh.com -o Compression=no -x' \
    user@server:~/data \
    ./
```
