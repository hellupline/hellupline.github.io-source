---
title: 'ffmpeg'

---


## stream desktop to udp address

will stream a window, webcam, microfone and desktop audio

```bash
eval "$(xdotool search --shell --name 'utils | hellupline notes - Brave')"
WINDOW="${WINDOWS[1]}"
eval "$(xdotool getwindowgeometry --shell "${WINDOW}")"
ffmpeg \
    -hide_banner -loglevel info \
    -hwaccel_output_format vaapi -threads 4 -probesize 5M -re \
    -thread_queue_size 512 -f x11grab -s "${WIDTH}x${HEIGHT}" -video_size "${WIDTH}x${HEIGHT}" -framerate 60 -show_region 1 -draw_mouse 1 -window_id "${WINDOW}" -i ':0.0+0,0' \
    -thread_queue_size 512 -f v4l2 -framerate 60 -i '/dev/video0' \
    -thread_queue_size 512 -f pulse -ac 1 -channel_layout stereo -i 'default' \
    -thread_queue_size 512 -f pulse -ac 2 -channel_layout stereo -i 'default' \
    -filter_complex '
        [1]pad=width=in_w+10:height=in_h+10:x=5:y=5:color=black[b];
        [b]scale=width=in_w*1.5:height=in_h*1.5[s];
        [0][s]overlay=x=(main_w-overlay_w-10)*0.90:y=(main_h-overlay_h-10)*0.90:format=yuv444[v];
        [2][3]amerge=inputs=2,pan=stereo|FL<c0+c1|FR<c2+c3[a]
    ' \
    -map '[v]:v:0' -map '[a]:a:0' \
    -c:v libx265 -c:a aac \
    -pix_fmt yuv444p -crf 0 -cq 10 -qp 0 \
    -preset faster -tune zerolatency \
    -f mpegts udp://127.0.0.1:2000
```

```bash
mpv udp://127.0.0.1:2000
```
