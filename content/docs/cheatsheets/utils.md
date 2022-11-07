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
    --expression='s#\s{2,}# #g' \
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
# `sed`, `grep` and `sort` are for demonstration, not required for `column`
echo '
    1 0 X A
    2 1 Y AA
    3 1 Z AB
    4 2 W AAA
    5 2 @ AAB
' \
| sed --regexp-extended --expression='s#\s{2,}# #g' \
| grep --invert-match '^$' \
| sort --field-separator=' ' --key='2,2n' --key='1,1n' \
| column \
    --table \
    --table-columns='ID,PARENT,NAME,DATA' \
    --table-hide='ID,PARENT' \
    --tree-id='ID' \
    --tree-parent='PARENT' \
    --tree='DATA' \
| less --chop-long-lines --RAW-CONTROL-CHARS
# NAME  DATA
# X     A
# Y     ├─AA
# W     │ ├─AAA
# @     │ └─AAB
# Z     └─AB
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


## get line by range

```bash
echo -e 'aaaa\nbbbb\ncccc\ndddd\neeee' | sed --quiet --expression='2,3p;4q'
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
