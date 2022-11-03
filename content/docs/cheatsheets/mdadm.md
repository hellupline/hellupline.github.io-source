---
title: 'mdadm'

---


## create raid

```bash
mdadm \
    --verbose \
    --create '/dev/md/kiwi-storage-v2' \
    --name 'kiwi-storage-v2' \
    --level 6 \
    --raid-devices 8 \
    /dev/sd[c-j]1
```


##  query raid

```bash
mdadm --query '/dev/md/kiwi-storage-v2'
```


##  detail raid

```bash
# mdadm --detail --scan > /etc/mdadm.conf
mdadm --query '/dev/md/kiwi-storage-v2'
```


##  examine raid

```bash
mdadm --examine /dev/sd[c-j]1
```


## resync progress

```bash
watch -n1 cat /proc/mdstat
```


## add disk from raid

```bash
mdadm --manage '/dev/md/kiwi-storage-v2' --add '/dev/sdc1'
```


## remove disk from raid

```bash
mdadm --manage '/dev/md/kiwi-storage-v2' --set-faulty '/dev/sdc1'
```


## reassemple raid

```bash
mdadm --assemble --run --update=resync '/dev/md/kiwi-storage-v2' /dev/sd[c-j]1
```


## delete raid

```bash
mdadm --stop '/dev/md/kiwi-storage-v2'
```
