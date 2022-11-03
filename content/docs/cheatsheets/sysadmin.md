---
title: sysadmin

---


## system stats

install: sysstat net-tools iotop iftop htop

### process stats

```bash
pidstat -p PID  # pidstat -p ALL
pidstat -p PID INTERVAL
pidstat -p PID INTERVAL QUANTITY
pidstat -C NAME  # by name

# custom stats
pidstat -p PID -r  # memory
pidstat -p PID -u  # cpu
pidstat -p PID -d  # io

# formatting
pidstat -p PID -t  # tree
pidstat -p PID -h  # horizontal ( for export )
```


### network stats

```bash
netstat --tcp --udp --listening --program --numeric  # netstat -tulpn
```


### monitoring tui

```bash
iotop

iftop

htop
```


### routing table

```bash
netstat --route --numeric  # netstat -rn
```


## services

### manage

```bash
systemctl enable --now SERVICE  # chkconfig SERVICE on
systemctl disable --now SERVICE  # chkconfig SERVICE off
systemctl is-enabled SERVICE  # chkconfig SERVICE
systemctl daemon-reload  # chkconfig SERVICE --add

systemctl start SERVICE  # service SERVICE start
systemctl stop SERVICE  # service SERVICE stop
systemctl status SERVICE  # service SERVICE status
systemctl restart SERVICE  # service SERVICE restart
systemctl reload SERVICE  # service SERVICE reload
```


### list

```bash
systemctl list-units --type=service --state=running --all  # service --status-all
```


### logs

```bash
journalctl --follow --since=today  # tail --follow /var/log/{messages,syslog}
journalctl --dmesg
journalctl --unit SERVICE

journalctl --list-boots
journalctl --boot BOOT_ID
```
