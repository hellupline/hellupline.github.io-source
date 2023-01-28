---
title: 'nmcli'

---


## device status

```bash
nmcli device status

nmcli general
```


## wifi

### list access points

```bash
# refresh the available wifi connection list
nmcli device wifi rescan

# show all available wifi access points
nmcli device wifi list

# connect to a wireless access point - parameters:
# 	<wiface> -- the name of your wireless interface
#	<ssid> -- the SSID of the access point
#	<pass> -- the WiFi password
nmcli device wifi connect <ssid> password <pass> iface <wiface>

# disconnect from wifi - parameters:
#	<wiface> -- the name of your wireless interface
nmcli device wifi disconnect iface <wiface>

# show wifi password and qr code
sudo nmcli device wifi show
```


### enable/disable

```bash
# get wifi status
nmcli radio wifi

# enable wifi
sudo nmcli radio wifi on

# disable wifi
sudo nmcli radio wifi off
```


## connections

```bash
# show all available connections
nmcli connection show

# show only active connections
nmcli connection show --active

# add a dynamic ethernet connection - parameters:
#	<name> -- the name of the connection
#	<iface_name> -- the name of the interface
nmcli connection add type ethernet con-name <name> ifname <iface_name>
nmcli connection add type ethernet con-name <name> ifname <iface_name> ipv4.method manual ipv4.address 10.10.10.4/24 ipv4.gateway 10.10.10.1
nmcli connection add type ethernet con-name <name> ifname <iface_name> ipv4.method auto

# bring up the connection
nmcli connection up <name>

# bring down the connection
nmcli connection down <name>

# disable ipv6
nmcli connection modify <name> ipv6.method ignore

# modify dns server
nmcli connection modify <name> ipv4.dns 1.1.1.1

# append dns server
nmcli connection modify <name> +ipv4.dns 1.1.1.1

# remove dns server
nmcli connection modify <name> -ipv4.dns 1.1.1.1

# ignore dhcp dns server
nmcli connection modify <name> ipv4.ignore-auto-dns yes
```
