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

	#mkdir -p /etc/systemd/system/getty@tty1.service.d/
    #cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<_EOF_
#[Service]
#ExecStart=
#ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
#_EOF_

	git clone https://github.com/gleam2003/RetroPie-Setup /home/pi/RetroPie-Setup
	chown pi /home/pi/RetroPie-Setup -R

	tar -xhzvf /tmp/overlay/usr.tar.gz -C /
	tar -xhzvf /tmp/overlay/etc.tar.gz -C /
	#tar -xhzvf /tmp/overlay/opt.tar.gz -C /
	#tar -xhzvf /tmp/overlay/home.tar.gz -C /

	cp -r /tmp/overlay/etc/ /

	#dpkg -i /tmp/overlay/rk3399/sdl2/libsdl2-2.0-0_2.0.10+5_arm64.deb  /tmp/overlay/rk3399/sdl2/libsdl2-dev_2.0.10+5_arm64.deb
	

cat >/home/pi/install.sh <<_EOF_
#!/bin/bash
cd
sudo apt-get update
sudo apt-get -y install git dialog xmlstarlet joystick
git clone https://github.com/gleam2003/RetroPie-Setup.git
cd RetroPie-Setup
modules=(
    'setup basic_install'
    'autostart enable'
)
for module in "\${modules[@]}"; do
    sudo __platform=rk3399 __nodialog=1 ./retropie_packages.sh \$module
done
rm -rf tmp
sudo apt-get clean
_EOF_

#su -c "sudo -S /home/pi/install.sh" - pi	

	su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh setup basic_install" - pi
	su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh autostart enable" - pi
	#su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh retropiemenu" - pi
	#su -c "sudo -S __platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh runcommand" - pi

	#echo abiuplayer | sudo -S su -l pi -c '__platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh retroarch'
	#echo abiuplayer | sudo -S su -l pi -c '__platform=rk3399 __nodialog=1 /home/pi/RetroPie-Setup/retropie_packages.sh emulationstation'

} # Main

Main "$@"
