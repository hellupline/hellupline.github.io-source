---
title: "find"
---

## datetime

### locate

```bash
find ./ -newermt '2022-11-03 17:30' -not -newermt '2022-11-03 17:30'
find ./ -mtime +5 # modified time more than 5 days ago
find ./ -mtime -5 # modified time less than 5 days ago
find ./ -mtime 5 # modified time exact than 5 days ago
# today files
find ./ -daystart -mtime 1 # use start of day as base instead of 24 hours
```

### print

```bash
find ./ -type f -printf '%TY-%Tm-%Td\t%TT%Tz\t%p\n' | sort -k1,2 | awk 'NR == 1 { print $3 " @ " $2; } END { print $3 " @ " $2; }' # newest and oldest file
find ./ -type f -printf '%TY-%Tm-%Td\t%TT%Tz\t%p\n'  # date time timezone
find ./ -type f -printf '%T@ %p\n'  # epoch timestamp
```

## size

### locate

```bash
find ./ -size +500M -not -size +1000M
find ./ -empty  # empty
```

### print

```bash
find ./ -type f -printf '%-10k %p\n'  # kbytes blocks
find ./ -type f -printf '%-10s %p\n'  # bytes
```

## permissions

### locate

```bash
find ./ -perm -u=w,g=w # have user = write and group = write
find ./ -perm /u=w,g=w # have user = write or group = write
find ./ -perm 755 # exact bits match
find ./ -perm -755 # all mask bits match
find ./ -perm /755 # any mask bits match
```

### print

```bash
find ./ -type f -printf '%M %#m %p\n'
```

## type

### locate

```bash
find ./ -type f # files
find ./ -type d # directories
find ./ -type l # links
```

### print

```bash
find ./ -type f -printf '%y %p\n'
```

## owner

### locate

```bash
find ./ -user myusername # user name
find ./ -uid 1000 # user id
find ./ -group mygroup # group name
find ./ -gid 1000 # group id
```

### print

```bash
find ./ -type f -printf '%u %-5U %g %-5G %p\n'
```

## locate items between depth

```bash
find ./ -mindepth 2 -maxdepth 5
```

## preserve path in output

```bash
find "${PWD}"
```

## regex

```bash
find ./ -regextype posix-egrep -regex '.*\.(avi|mkv|mp4|wmv|flv|webm)$'
```

## save to file

```bash
find ./ \
    \( -type f -fprintf output_file.txt '%#m %u %p\n' \) , \
    \( -type d -fprintf output_dir.txt '%#m %u %p\n' \)
```
