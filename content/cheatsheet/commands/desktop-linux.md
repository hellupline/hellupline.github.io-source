---
title: desktop-linux
weight: 999
type: docs
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## notifications

```bash
notify-send --urgency=critical --app-name=hello-nurse TITLE "BODY"
```

## clipboard

```bash
xclip -out -selection clipboard > output.txt

xclip -in -selection clipboard < input.txt
```
