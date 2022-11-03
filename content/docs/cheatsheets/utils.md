---
title: 'utils'

---


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


## stream desktop to address

```bash
eval "$(xdotool search --shell --name 'utils | hellupline notes - Brave')"
WINDOW="${WINDOWS[1]}"
ffmpeg \
    -re \
    -thread_queue_size 8192 \
    -threads 0 \
    \
    -f x11grab \
    -window_id "${WINDOW}" \
    -show_region 1 \
    -draw_mouse 0 \
    -framerate 30 \
    -i :0.0+0,0 \
    \
    -f pulse \
    -ac 2 \
    -i default \
    \
    -preset ultrafast \
    -crf 10 \
    -cq 10 \
    -c:v libx264 \
    -c:a aac \
    -b:v 2048K \
    -b:a 256K \
    -map '0:v:0' \
    -map '1:a:0' \
    \
    -f mpegts udp://127.0.0.1:2000
```

```bash
mpv udp://127.0.0.1:2000
```
