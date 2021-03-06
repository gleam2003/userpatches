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
BOARDFAMILY=$5

Main() {
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none

	mount --bind /dev/null /proc/mdstat

	rm /root/.not_logged_in_yet

	echo root:abiuplayer | chpasswd
	adduser pi --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
	echo pi:retroera | chpasswd

	rm -f /etc/systemd/system/getty@.service.d/override.conf
	rm -f /etc/systemd/system/serial-getty@.service.d/override.conf

	cp -r /tmp/overlay/etc/ /

	modules=(
		'setup basic_install'
	    'autostart enable'
	    'usbromservice'
	    'samba depends'
	    'samba install_shares'
	)

	case $BOARDFAMILY in
		"rk3399"|"rockchip64" )
			tar -xhzvf /tmp/overlay/rk3399/mali.tar.gz -C /
			platform = "rk3399"
			;;
		"sun8i" )
			tar -xhzvf /tmp/overlay/sun8i/mali.tar.gz -C /
			platform = "armv7-mali"
			;;
	esac

	git clone https://github.com/gleam2003/RetroPie-Setup /home/pi/RetroPie-Setup

	for module in "${modules[@]}"; do
	    su -c "sudo -S __platform=${platform} __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh ${module}" - pi
	done

	rm -rf /home/pi/RetroPie-Setup/tmp
	sudo apt-get clean

	umount /proc/mdstat
} # Main

Main "$@"