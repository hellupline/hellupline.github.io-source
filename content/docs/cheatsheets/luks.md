---
title: 'luks'

---


## create volume

```bash
cryptsetup luksFormat --type luks2 ~/luks-volume.data --verify-passphrase
```


## inspect

```bash
cryptsetup luksDump --type luks2 ~/luks-volume.data
```


## volume usage

### open

```bash
cryptsetup open --type luks2 ~/luks-volume.data my-volume --key-file ~/luks-volume.keyfile  # using keyfile
cryptsetup open --type luks2 ~/luks-volume.data my-volume # using password
```

### close

```bash
cryptsetup close my-volume
```


## key management

### add

```bash
cryptsetup luksAddKey --type luks2 ~/luks-volume.data ~/luks-volume.keyfile-new --key-file ~/luks-volume.keyfile  # add keyfile, using keyfile to open header
cryptsetup luksAddKey --type luks2 ~/luks-volume.data ~/luks-volume.keyfile-new  # add password, using password to open header
cryptsetup luksAddKey --type luks2 ~/luks-volume.data --verify-passphrase --key-file ~/luks-volume.keyfile  # add password, using keyfile to open header
cryptsetup luksAddKey --type luks2 ~/luks-volume.data --verify-passphrase  # add password, using password to open header
```

### remove

```bash
cryptsetup luksRemoveKey --type luks2 ~/luks-volume.data  --key-file ./luks-volume.keyfile  # remove keyfile
cryptsetup luksRemoveKey --type luks2 ~/luks-volume.data   # remove password
```


## header management

### backup

```bash
cryptsetup luksHeaderBackup ~/luks-volume.data --header-backup-file ~/luks-volume.header
```

### restore

```bash
cryptsetup luksHeaderRestore ~/luks-volume.data --header-backup-file ~/luks-volume.header
```
