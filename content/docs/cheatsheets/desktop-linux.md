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
sudo timedatectl set-local-rtc 0
systemctl enable --now systemd-timesyncd.service
```


## manjaro packates

```bash
pamac install \
	aria2 \
	aws-cli \
	brave-browser \
	byobu \
	playerctl \
	ctags \
	dnsutils \
	docker \
	docker-buildx \
	docker-compose \
	feh \
	firefox \
	gnome-disk-utility \
	gnome-terminal \
	gnumeric \
	gsmartcontrol \
	helm \
	hugo \
	pandoc \
	ipython \
	jq \
	podman \
	keepassxc \
	kubectl \
	lib32-pipewire \
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
	github-cli \
	obs-studio libva-intel-driver \
	openbsd-netcat \
	pavucontrol \
	pipewire-pulse \
	pipewire-x11-bell \
	pkgfile \
	polybar \
	python-pip \
	python-pynvim \
	qemu-desktop \
	qemu-full \
	qemu-user-static \
	qemu-user-static-binfmt \
	redshift \
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
	xdotool \
	xorg-xwininfo \
	yt-dlp \
	zip \
	zsh-autosuggestions \
	zsh-syntax-highlighting
pamac build \
	azure-cli \
	aws-sam-cli \
	aws-session-manager-plugin \
	google-cloud-cli \
	google-cloud-cli-gke-gcloud-auth-plugin
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
	pyquery
poetry add --group=dev \
	ipython \
	pynvim \
	black \
	isort \
	flake8 \
	mypy \
	pyright

sudo systemctl enable --now pkgfile-update.timer
```
