---
title: 'utils'

---


## file allocation

```bash
fallocate --length $((20*1024**2)) luks-volume.data
```


## math in shell

```bash
DAYS=15
echo "scale=2; days=${DAYS}; hours=24; minutes=60; seconds=60; result = days * hours * minutes * seconds; result" | bc
```


## last exit status

```bash
echo ${?}
```


## simple smtp debug server

```bash
sudo python -m smtpd -n -c DebuggingServer localhost:25
```


## simple http server

```bash
python -m http.server
```


## prettify json

```bash
python -m json.tool
```


## rsync

```bash
rsync \
    --verbose \
    --no-inc-recursive \
    --info=progress2 \
    --human-readable \
    --progress \
    --stats \
    --partial \
    --archive \
    --exclude 'stuff/_data' \
    -- \
    'SOURCE_OBJECT_1' \
    'SOURCE_OBJECT_2' \
    'SOURCE_OBJECT_3' \
    'TARGET'
```


## date

```bash
# RFC-3339
date --date='1991-01-22 18:00:00 -0300'
date --rfc-3339=seconds
# Timestamp
date --date='@664578000'
date '+%s'
# Relative
date --date="next Friday"
date --date="2 days ago"
```


## filesystem

```bash
# label = kiwi-storage-v2, reserved 0%
mkfs.ext4 -L kiwi-storage-v2 -m 0 /dev/mapper/kiwi-storage-v2
# get filesystem data
tune2fs -l /dev/mapper/kiwi-storage-v2
```
