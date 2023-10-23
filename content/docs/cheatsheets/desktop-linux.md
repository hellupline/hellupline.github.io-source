---
title: 'desktop-linux'

---


## seahorse keyring

```bash
secret-tool store --label='App' app username
secret-tool lookup app username
```


## notifications

```bash
notify-send --urgency=critical --app-name=hello-nurse TITLE "BODY"
```


## clipboard

```bash
xclip -out -selection clipboard > output.txt
xclip -in -selection clipboard < input.txt
```


## turn off display

```bash
xset dpms force suspend
```


## send clicks to window

```bash
eval "$(xdotool search --shell --name 'Minecraft\* 1.18.2 - Multiplayer \(3rd-party Server\)')"
for WINDOW in ${WINDOWS[@]}; do
	eval "$(xdotool getwindowgeometry --shell "${WINDOW}")"
	NX="$((WIDTH * 50 / 100))"
	NY="$((HEIGHT * 75 / 100))"
	xdotool mousemove --window "${WINDOW}" "${NX}" "${NY}"; sleep 1
	# xdotool click --window "${WINDOW}" 1; sleep 1
	xdotool key --window "${WINDOW}" Escape; sleep 1
	xdotool mousedown --window "${WINDOW}" 1; sleep 1
done
```


## set default browser

```bash
# gio mime x-scheme-handler/https brave-browser.desktop
# gio mime x-scheme-handler/http brave-browser.desktop
xdg-settings set default-url-scheme-handler https brave-browser.desktop
xdg-settings set default-url-scheme-handler http brave-browser.desktop
xdg-settings set default-web-browser brave-browser.desktop
xdg-mime default brave-browser.desktop x-scheme-handler/https x-scheme-handler/http
```


## add groups to user

```bash
usermod --append --groups 'docker' 'hellupline'
newgrp 'docker'
```


## sudo

```bash
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99_wheel_group_nopass
```


## disable pcspkr

```bash
echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf
```


## hardware clock

```bash
timedatectl set-local-rtc false
timedatectl set-ntp true
systemctl enable --now systemd-timesyncd.service
```


## manjaro packates

```bash
pamac install \
	aria2 \
	aws-cli \
	brave-browser \
	byobu \
	ctags \
	deno \
	dnsutils \
	docker \
	docker-buildx \
	docker-compose \
	feh \
	firefox \
	fzf \
	gamemode \
	github-cli \
	gnome-disk-utility \
	gnome-terminal \
	gnumeric \
	gsmartcontrol \
	helm \
	hugo \
	ipython \
	jq \
	keepassxc \
	kubectl \
	lib32-pipewire \
	libretro-overlays \
	libretro-shaders \
	lutris \
	maim \
	manjaro-pipewire \
	minetest \
	mpv \
	neovim \
	nmap \
	nodejs \
	npm \
	numlockx \
	obs-studio libva-intel-driver \
	openbsd-netcat \
	pandoc \
	pavucontrol \
	pipewire-pulse \
	pipewire-x11-bell \
	pkgfile \
	playerctl \
	podman \
	polybar \
	python-pip \
	python-pipx \
	python-pynvim \
	qemu-desktop \
	qemu-full \
	qemu-user-static \
	qemu-user-static-binfmt \
	redshift \
	retroarch \
	retroarch-assets-ozone \
	retroarch-assets-xmb \
	ripgrep \
	rofi \
	seahorse \
	steam \
	stow \
	stress \
	terraform \
	virt-manager \
	whois \
	wine \
	winetricks \
	wmctrl \
	xdg-desktop-portal-gtk \
	xdotool \
	xorg-xwininfo \
	yt-dlp \
	zip \
	zsh-autosuggestions \
	zsh-syntax-highlighting \
 	flatpak \
 	pipewire-x11-bell \
 	unzip \

pamac install libgnome-keyring wireplumber  # extras
pacman --database --asdeps libgnome-keyring wireplumber

pamac build \
	azure-cli \
	aws-sam-cli \
	aws-session-manager-plugin \
	google-cloud-cli \
	google-cloud-cli-gke-gcloud-auth-plugin \
	cloud-sql-proxy \
	minecraft-launcher \
	ijq

flatpak install flathub \
	com.authy.Authy \
	com.chatterino.chatterino \
	com.discordapp.Discord \
	com.slack.Slack \
	com.spotify.Client

python3 -m pip install \
	internetarchive \
	jupyter \
	jupyterlab \
	pandas \
	pyquery \
	requests

poetry add --group=dev \
	ipython \
	pynvim \
	black \
	isort \
	mypy \
	pyright

systemctl enable --now pkgfile-update.timer
systemctl enable --user pipewire-pulse
ln --relative --symbolic /usr/share/xdg-desktop-portal/gtk-portals.conf /usr/share/xdg-desktop-portal/portals.conf
# systemctl enable --user --now xdg-desktop-portal
# systemctl enable --user --now xdg-desktop-portal-gtk
```
