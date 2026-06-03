#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 -y copr enable bigmenpixel/profile-sync-daemon

dnf5 install -y \
	atop \
	profile-sync-daemon \
	prometheus-node-exporter \
	yakuake

dnf5 -y copr disable bigmenpixel/profile-sync-daemon

### Setup profile-sync-daemon

#### waterfox-flatpak
cat <<EOF >/usr/share/psd/browsers/waterfox-flatpak
if ! flatpak override --user --show net.waterfox.waterfox | grep -q "/run/user/$UID/psd"; then
    flatpak override --user net.waterfox.waterfox --filesystem=/run/user/$UID/psd
fi

if [[ -d "$HOME"/.var/app/net.waterfox.waterfox/.waterfox ]]; then
    index=0
    PSNAME="$browser"
    while read -r profileItem; do
        if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
            # path is not relative
            DIRArr[$index]="$profileItem"
        else
            # we need to append the default path to give a
            # fully qualified path
            DIRArr[$index]="$HOME/.var/app/net.waterfox.waterfox/.waterfox/$profileItem"
        fi
        (( index=index+1 ))
    done < <(grep '[Pp]'ath= "$HOME"/.var/app/net.waterfox.waterfox/.waterfox/profiles.ini | sed 's/[Pp]ath=//')
fi

check_suffix=1
EOF

#### firefox-flatpak
cat <<EOF >/usr/share/psd/browsers/firefox-flatpak
if ! flatpak override --user --show org.mozilla.firefox | grep -q "/run/user/$UID/psd"; then
    flatpak override --user org.mozilla.firefox --filesystem=/run/user/$UID/psd
fi

if [[ -d "$HOME"/.var/app/org.mozilla.firefox/.mozilla/firefox ]]; then
    index=0
    PSNAME="$browser"
    while read -r profileItem; do
        if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
            # path is not relative
            DIRArr[$index]="$profileItem"
        else
            # we need to append the default path to give a
            # fully qualified path
            DIRArr[$index]="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$profileItem"
        fi
        (( index=index+1 ))
    done < <(grep '[Pp]'ath= "$HOME"/.var/app/org.mozilla.firefox/.mozilla/firefox/profiles.ini | sed 's/[Pp]ath=//')
fi

check_suffix=1
EOF

#### vivaldi-flatpak
cat <<EOF >/usr/share/psd/browsers/vivaldi-flatpak
if ! flatpak override --user --show com.vivaldi.Vivaldi | grep -q "/run/user/$UID/psd"; then
	flatpak override --user com.vivaldi.Vivaldi --filesystem=/run/user/$UID/psd
fi

DIRArr[0]="$HOME/.var/app/com.vivaldi.Vivaldi/config/$browser"
PSNAME="$browser"-bin
EOF

#### zen-flatpak
cat <<EOF >/usr/share/psd/browsers/zen-flatpak
if ! flatpak override --user --show app.zen_browser.zen | grep -q "/run/user/$UID/psd"; then
	flatpak override --user app.zen_browser.zen --filesystem=/run/user/$UID/psd
fi

if [[ -d "$HOME"/.var/app/app.zen_browser.zen/cache/zen ]]; then
	index=0
	PSNAME="$browser"
	while read -r profileItem; do
		if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
			# path is not relative
			DIRArr[$index]="$profileItem"
		else
			# we need to append the default path to give a
			# fully qualified path
			DIRArr[$index]="$HOME/.var/app/app.zen_browser.zen/cache/zen/$profileItem"
		fi
		(( index=index+1 ))
	done < <(grep '^[Pp]'ath= "$HOME"/.var/app/app.zen_browser.zen/.zen/profiles.ini | sed 's/^[Pp]ath=//')
fi

check_suffix=1
EOF

### systemd units

systemctl enable atop.service
systemctl enable atopacct.service
systemctl enable atop-rotate.timer
systemctl enable prometheus-node-exporter.service
systemctl disable cups.service
