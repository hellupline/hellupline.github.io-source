---
title: utils
weight: 110
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## fuck you and everyone around you alarm...

```bash
{ [ -s ~/.fuckyou.m4a ] || wget -O ~/.fuckyou.m4a https://hellupline.dev/uploads/alarms/c5Ul18ZmBao.m4a; } && {
    # play alarm if fail
    curl -Ss https://if-someone-buys-this-i-will-be-really-pissed ||
    mpv --no-video --loop ~/.fuckyou.m4a ; }
```

## math in shell

```bash
echo 'scale=2; days=15; hours=24; minutes=60; seconds=60; result = days * hours * minutes * seconds; result' | bc
```

## last exit status

```bash
echo ${?}
```

## prettify json

```bash
python -m json.tool
```

## simple smtp debug server

```bash
sudo python -m smtpd -n -c DebuggingServer localhost:25
```

## simple http server

```bash
python -m http.server
```

## rsync

```bash
rsync --verbose --human-readable --progress --stats --partial --archive \
      --exclude 'stuff/_data' \
      -- 'SOURCE_OBJECT_1' 'SOURCE_OBJECT_2' 'SOURCE_OBJECT_3' 'TARGET'
```

## random password

```bash
openssl rand -base64 33
```

## date

```bash
# RFC-3339
date --date='1991-01-22 19:00:00 +300'
date --rfc-3339=seconds

# Timestamp
date --date='@664581600'
date '+%s'

# Relative
date --date="next Friday"
date --date="2 days ago"
```

## download audio from video

```bash
youtube-dl \
    --audio-format mp3 \
    --audio-quality 320k \
    --extract-audio
```

## stream desktop to address

```bash
ffmpeg -f x11grab -s 1600x900 -framerate 15 -i :0.0 -c:v libx264 -preset fast -s 1600x900 -threads 0 -f mpegts udp://127.0.0.1:2000
```

```bash
mpv udp://127.0.0.1:2000
```
