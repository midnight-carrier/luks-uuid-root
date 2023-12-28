#!/bin/sh

prefix=/usr/share/make-initrd
i=0

if [ -n "$1" ]; then
	prefix=$1
fi

if [ ! "$(id -u)" -eq "0" ]; then
	echo "Error! Not enough permissions! Try to run this script as root."
	exit 1
fi

if [ ! -e $prefix ]; then
	echo "Error! make-initrd is not installed!"
	exit 2
fi

chmod +x luks/bin/get-data luks/data/bin/crypttab-sh-functions luks/data/lib/initrd/cmdline.d/luks luks/data/lib/uevent/filters/* luks/data/lib/uevent/handlers/085-luks luks/guess/device
if [ -e $prefix/features/luks ]; then
	while [ 0 -ne 1 ]; do	
		i=$(($i+1))
		if [ ! -e $prefix/features/luks-def$i ]; then
			mv $prefix/features/luks $prefix/features/luks-def$i
			break
		fi
	done
fi
cp -r --preserve=mode luks $prefix/features/
