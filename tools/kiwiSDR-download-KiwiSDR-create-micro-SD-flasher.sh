#!/bin/bash -e
# Copyright (c) 2016 John Seamons, ZL/KF6VO

# NB: this distro image is a flasher

VER="v1.0"
DEBIAN_VER="8.4"
CKSUM="b50e01cba539a8d98aaa8aec30cfbd3ed661f5ebf76a066cab0856424504567c"

#VER="v0.20"
#DEBIAN_VER="8.4"
#CKSUM="3d8d77715a75c2192dc2cd6401d3024d7a912a6af35f99eaa26418d581811738"

#VER="v0.12"
#DEBIAN_VER="8.4"
#CKSUM="c49956c9514a76166b92e72efb4bd2483e30c999afcf8f613a2192692c03a24d"

# image files are available on both dropbox.com and kiwisdr.com
#DISTRO_HOST="kiwisdr.com/files"
DISTRO_HOST="dl.dropboxusercontent.com/u/68809050/KiwiSDR"
DISTRO="KiwiSDR_${VER}_BBB_Debian_${DEBIAN_VER}.img.xz"

echo "--- get KiwiSDR distro image from net and create micro-SD flasher"
echo -n "--- hit enter when ready:" ; read

rv=$(which xzcat || true)
if test "x$rv" = "x" ; then
	echo "--- get missing xz-utils"
	apt-get -y install xz-utils
fi

if test ! -f ${DISTRO} ; then
	echo "--- getting distro"
	wget https://${DISTRO_HOST}/${DISTRO}
else
	echo "--- already seem to have the distro file, verify checksum below to be sure"
fi
echo "--- computing checksum..."
sha256sum ${DISTRO}
echo ${CKSUM} " correct checksum"
echo "--- verify that the two checksums above match"
echo -n "--- hit enter when ready:" ; read

echo "--- insert micro-SD card"
echo -n "--- hit enter when ready:" ; read
echo "--- lsblk:"
lsblk

echo "--- copying to micro-SD card, will take several minutes"
echo -n "--- hit enter when ready:" ; read
time xzcat -v ${DISTRO} | dd of=/dev/mmcblk1

echo "--- when next booted with micro-SD installed, KiwiSDR image should be copied to Beagle eMMC flash"
echo -n "--- hit ^C to skip reboot, else enter when ready to reboot:" ; read

echo "--- rebooting with flasher micro-SD installed will COMPLETELY OVERWRITE THIS BEAGLE's FILESYSTEM!"
echo -n "--- ARE YOU SURE? enter when ready to reboot:" ; read

echo "--- okay, rebooting to re-flash Beagle eMMC flash from micro-SD"
echo "--- you should see a back-and-forth pattern in the LEDs during the copy"
echo "--- after all the LEDs go dark (Beagle is powered off), remove micro-SD and power up"
echo "--- you should now be running KiwiSDR distro"
echo "--- rebooting now..."
reboot
