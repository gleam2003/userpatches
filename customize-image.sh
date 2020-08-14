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
	echo pi:raspberry | chpasswd

	mkdir -p /etc/systemd/system/getty@tty1.service.d/
    cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<_EOF_
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
_EOF_

	git clone https://github.com/gleam2003/RetroPie-Setup /home/pi/RetroPie-Setup
	chown pi /home/pi/RetroPie-Setup -R

	tar -xhzvf /tmp/overlay/include.tar.gz -C /
	tar -xhzvf /tmp/overlay/maliuserpsace.tar.gz -C /

	cp -r /tmp/overlay/etc/ /

	#su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh retroarch" - pi
	#su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh emulationstation-dev" - pi

	echo abiuplayer | sudo -S su -l pi -c '__platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh retroarch'
	echo abiuplayer | sudo -S su -l pi -c '__platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh emulationstation'

} # Main

Main "$@"
