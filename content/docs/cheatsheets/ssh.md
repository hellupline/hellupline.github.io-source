---
title: 'ssh'

---


## generate key

```bash
ssh-keygen -t rsa -b 4096 -C "me@mail.com"
```


## shell through bastion

```bash
ssh -J me@reachable.com me@unreacheable.com
```


## reach server behind bastion

```bash
ssh -Nnf -L localhost:8080:remote.example.com:5000 me@example.com
# cancel forward
ssh -O cancel -L localhost:8080:remote.example.com:5000 me@example.com
# close opportunistic master
ssh -O exit me@example.com
```


## reach localhost from bastion

```bash
ssh -Nnf -R localhost:8080:remote.example.com:5000 me@example.com
# cancel forward
ssh -O cancel -R localhost:8080:remote.example.com:5000 me@example.com
# close opportunistic master
ssh -O exit me@example.com
```


## create a socks proxy

```bash
ssh -Nnf -D 8080 me@example.com
# cancel forward
ssh -O cancel -D 8080 me@example.com
# close opportunistic master
ssh -O exit me@example.com
```


## change key passphrase

```bash
ssh-keygen -p -f ~/.ssh/id_rsa
```


## test key passphrase

```bash
ssh-keygen -y -f ~/.ssh/id_rsa
```


## escape codes

```txt
 ~.   - terminate connection (and any multiplexed sessions)
 ~B   - send a BREAK to the remote system
 ~C   - open a command line
 ~R   - request rekey
 ~V/v - decrease/increase verbosity (LogLevel)
 ~^Z  - suspend ssh
 ~#   - list forwarded connections
 ~&   - background ssh (when waiting for connections to terminate)
 ~?   - this message
 ~~   - send the escape character by typing it twice
(Note that escapes are only recognized immediately after newline.)
```


## ssh-config

```txt
Host *
    ControlMaster auto
    ControlPath ~/.ssh/cm_socket/%r@%h:%p
Host github.com
    Hostname github.com
    User git
Host gitlab.com
    Hostname gitlab.com
    User git
Host bitbucket.org
    Hostname bitbucket.org
    User git
```
