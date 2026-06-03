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

cp -v firefox-flatpak vivaldi-flatpak waterfox-flatpak zen-flatpak /usr/share/psd/browsers/

### systemd units

systemctl enable atop.service
systemctl enable atopacct.service
systemctl enable atop-rotate.timer
systemctl enable prometheus-node-exporter.service
systemctl disable cups.service
