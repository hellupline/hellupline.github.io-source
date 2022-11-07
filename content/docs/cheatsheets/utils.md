---
title: 'utils'

---


## column

```bash
sed 's/#.*//' /etc/fstab | column --table --table-columns='SOURCE,TARGET,TYPE' --table-hide='-'
```

```bash
cat /etc/passwd \
| sort \
    --field-separator=':' \
    --key='3,3n' \
    --key='4,4n' \
| column \
    --separator=':' \
    --table \
    --table-name='etc-passwd' \
    --table-columns='USERNAME,PASS,UID,GID,NAME,HOMEDIR,SHELL' \
    --table-right='UID,GID' \
    --table-hide='PASS' \
| less --chop-long-lines --RAW-CONTROL-CHARS
```

```bash
df --print-type --human-readable \
| sed \
    --regexp-extended \
    --expression='s#\s+# #g' \
    --expression='1d' \
| sort \
    --field-separator=' ' \
    --key '3,3h' \
    --key='4,4h' \
    --key='5,5h' \
    --key='7,7' \
    --key='2,2' \
    --key='1,1' \
| column \
    --table \
    --table-columns='Filesystem,Type,Size,Used,Avail,Use%,Mounted on' \
| less --chop-long-lines --RAW-CONTROL-CHARS
```

```bash
# tree mode, parent field 2, object id field 1, tree object field 3
echo -e '1 0 A\n2 1 AA\n3 1 AB\n4 2 AAA\n5 2 AAB' | column --tree-id 1 --tree-parent 2 --tree 3
# 1  0  A
# 2  1  ├─AA
# 4  2  │ ├─AAA
# 5  2  │ └─AAB
# 3  1  └─AB
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


## file allocation

```bash
fallocate --length $((20*1024**2)) luks-volume.data
```


## filesystem

```bash
# label = kiwi-storage-v2, reserved 0%
mkfs.ext4 -L kiwi-storage-v2 -m 0 /dev/mapper/kiwi-storage-v2
# get filesystem data
tune2fs -l /dev/mapper/kiwi-storage-v2
```


## download using headless chrome

```bash
# google-chrome-stable
brave --headless --dump-dom --disable-gpu 'https://hellupline.dev' 2> /dev/null
```
