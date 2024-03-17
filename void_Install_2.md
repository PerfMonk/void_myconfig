
* * *
# WORK IN PROGRESS HERE #
# This part is going to change ...
# Some parts are not what I have done 
* * *

# This part is in french

# Définir Bash pour root et mon utilisateur (bt)

chsh -s /usr/bin/bash
su - bt -c 'chsh -s /usr/bin/bash'


# Installer Base OS

## Void Doc Full Disk Encryption

[Void FDE](https://docs.voidlinux.org/installation/guides/fde.html "FDE")
 Pour formatter le disque utiliser Void_install_1.sh
 
## Définition du temps (Optionnel)

ln -sf /usr/share/zoneinfo/America/Montreal /etc/localtime

## Définir la Langue fr_CA

sed -i "s@#fr_CA.utf8@fr_CA.utf8@g" /etc/default/libc-locales
vi /etc/locale.conf

LANG=fr_CA.UTF-8
LC_COLLATE=C
LC_ALL=fr_CA.UTF-8

xbps-reconfigure -f glibc-locales

xbps-install -Syv :
	poppler-data
	qt5-translations qt6-translations
	firefox-i18n-fr thunderbird-i18n-fr
	aspell-fr hunspell-fr_FR
	libreoffice-i18n-fr
	manpages-fr

## Logiciels installés sur l'image de base

gpm htop inxi neofetch
git
gnome-keyring
rtkit 
libarchive 
tar xz p7zip unzip zip gzip lz4 lzo zstd
linux-firmware linux-firmware-network
cpupower spectre-meltdown-checker
chrony cronie firefox firefox-i18n-fr
polkit
polkit-gnome
tlp
tracker
tty-clock
Thunar
xbps octoxbps 
NetworkManager
xdg-desktop-portal
xorg
libinput
libinput-gestures

# Installer Wayland + Wayfire 

	Waybar
	way-displays
	wayfire
	wayfire-plugins-extra
	wayland
	wayland-protocols
	wdisplays
	wlogout
	wlsunset
	wofi
	swayidle
	swaylock
	grim
	gammastep
	brightnessctl
	clipman
	dex
	elogind
	flatpak
	alacritty
	mako


# Les Thèmes,fontes,icones, bref: L'apparence

Adapta
awoken-icons
breeze-cursors
font-awesome5
font-fira-otf
gtkdatabox3
noto-fonts-cjk
nwg-launchers
nwg-look
paper-icon-theme



# Configuration de l'audio PulseAudio,Pipewire,WirePlumber

mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

pavucontrol-qt
playerctl
pulseaudio
pipewire 
alsa-pipewire
wireplumber
kanshi
mpv
mpv-mpris

# GPU AMD

void-repo-multilib
linux-firmware-amd
mesa
mesa-dri 
mesa-vdpau
mesa-vaapi
mesa-vulkan-radeon
libva libva-32bit
libva-vdpau-driver
mesa-demos glxinfo
xf86-video-amdgpu


# Installation des Services

ln -s /etc/sv/sshd /var/service/
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/NetworkManager /var/service/
ln -s /etc/sv/chronyd /var/service/
ln -s /etc/sv/cronie /var/service/
ln -s /etc/sv/bluetoothd /var/service/
ln -s /etc/sv/rtkit /var/service/
ln -s /var/lib/dbus/machine-id /etc/machine-id
ln -s /usr/share/applications/pipewire.desktop /etc/xdg/autostart/pipewire.desktop



# Création des dossiers Home

xbps-install -Syv xdg-user-dirs
su - void -c "xdg-user-dirs-update --force"

# Installer le Kernel 6.7 (Selon votre choix)

xbps-query --regex -Rs '^linux[0-9.]+-[0-9._]+'
xbps-install -Syv linux6.7


# Installer les dépendances

xbps-install -Syv alsa-plugins alsa-plugins-32bit alsa-lib alsa-lib-32bit \
FAudio FAudio-32bit \
freetype freetype-32bit \
libXft libXft-32bit \
flex \
fluidsynth libfluidsynth libfluidsynth-32bit \
libXrandr libXrandr-32bit xrandr \
libldap libldap-32bit \
mpg123 libmpg123 libmpg123-32bit \
libXcomposite libXcomposite-32bit \
libXi libXi-32bit \
libXinerama libXinerama-32bit \
libXScrnSaver libXScrnSaver-32bit \
libopenal libopenal-32bit \
alsa-pipewire alsa-pipewire-32bit pipewire pipewire-32bit libjack-pipewire libjack-pipewire-32bit \
mit-krb5 mit-krb5-32bit \
gnutls gnutls-32bit \
giflib giflib-32bit \
gst-libav gst-plugins-ugly1 \
gst-plugins-bad1 gst-plugins-bad1-32bit \
gst-plugins-base1 gst-plugins-base1-32bit \
gst-plugins-good1 gst-plugins-good1-32bit \
gstreamer1 gstreamer1-32bit \
libpng libpng-32bit \
v4l-utils v4l-utils-32bit \
vulkan-loader vulkan-loader-32bit \
libgpg-error libgpg-error-32bit \
libjpeg-turbo libjpeg-turbo-32bit \
libgcrypt libgcrypt-32bit \
ncurses ncurses-libs ncurses-libs-32bit \
ocl-icd ocl-icd-32bit \
libxslt libxslt-32bit \
libva libva-32bit \
glu glu-32bit \
sqlite sqlite-32bit \
gtk+3 gtk+3-32bit \
libpulseaudio libpulseaudio-32bit \
libnm libnm-32bit \
gamemode libgamemode libgamemode-32bit \
vkBasalt vkBasalt-32bit \
cabextract

# Installer Flatpak (Optionnel)

xbps-install -Syv flatpak xdg-desktop-portal xdg-user-dirs xdg-utils
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord

# Installer Discord (Optionnel)

xbps-install -Syv git xtools
git clone https://github.com/void-linux/void-packages
cd void-packages
./xbps-src binary-bootstrap
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
./xbps-src pkg discord
xi discord

# Installer des logiciels utiles

backup :  borg

