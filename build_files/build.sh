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

### systemd units

systemctl enable atop.service
systemctl enable atopacct.service
systemctl enable atop-rotate.timer
systemctl enable prometheus-node-exporter.service
systemctl disable cups.service
