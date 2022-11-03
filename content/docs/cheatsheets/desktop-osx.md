---
title: 'desktop-osx'

---

## homebrew

### install homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


### install packages

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew install ...
HOMEBREW_NO_AUTO_UPDATE=1 brew install --cask  ...
```


## notifications

```bash
osascript -e 'display notification "Body" with title "Title"'
```


## text to voice

```bash
say "Hello World"
```


## clipboard

```bash
pbpaste > output.txt
pbcopy < input.txt
```
