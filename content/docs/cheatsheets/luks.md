---
title: 'luks'

---


## create volume

```bash
cryptsetup --type luks2 luksFormat ./luks-volume.data
```


## open volume

```bash
cryptsetup open --type luks2 ./luks-volume.data my-volume --key-file ./luks-volume.keyfile  # using key-file
cryptsetup open --type luks2 ./luks-volume.data my-volume # using password
```


## close volume

```bash
cryptsetup close my-volume
```


## add key

```bash
cryptsetup luksAddKey --type luks2 ~/luks-volume.data --key-file ./luks-volume.keyfile  # using key-file
cryptsetup luksAddKey --type luks2 ~/luks-volume.data --verify-passphrase  # using passowrd
```


## remove key

```bash
cryptsetup luksRemoveKey --type luks2 ~/luks-volume.data --key-file ./luks-volume.keyfile  # using key-file
cryptsetup luksRemoveKey --type luks2 ~/luks-volume.data --verify-passphrase  # using passowrd
```


## header backup

```bash
cryptsetup luksHeaderBackup ~/luks-volume.data --header-backup-file ~/luks-volume.header
```


## header restore

```bash
cryptsetup luksHeaderRestore ~/luks-volume.data --header-backup-file ~/luks-volume.header
```
