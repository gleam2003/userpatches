#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {

	rm -f /etc/systemd/system/getty@.service.d/override.conf
	rm -f /etc/systemd/system/serial-getty@.service.d/override.conf
	systemctl daemon-reload

	echo root:abiuplayer | chpasswd

	rm /root/.not_logged_in_yet
	adduser pi --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
	echo pi:retroera | chpasswd

	tar -xhzvf /tmp/overlay/h3/mali.tar.gz -C /
	tar -xhzvf /tmp/overlay/retropie.tar.gz -C /
	cp -r /tmp/overlay/etc/ /

	#git clone https://github.com/gleam2003/RetroPie-Setup /home/pi/RetroPie-Setup

	su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh setup basic_install" - pi
	su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh autostart enable" - pi

} # Main

Main "$@"