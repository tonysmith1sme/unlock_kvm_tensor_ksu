#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

set -e

MAGISKBOOT="/data/adb/magisk/magiskboot"

err() {
        echo -e "\e[91m[!] $@\e[39m"
        exit 1
}

[[ ! -f "$MAGISKBOOT" ]] && err "Failed to find magiskboot binary. Exiting."

mkdir -p /data/local/tmp/cmdpatch
cd /data/local/tmp/cmdpatch

SLOT=`getprop ro.boot.slot_suffix`
BOOT="boot$SLOT"

BOOTIMG="/dev/block/by-name/$BOOT"

dd if=$BOOTIMG of=/sdcard/$BOOT.img.bk
$MAGISKBOOT unpack -h $BOOTIMG

for tweak in "$@"
do
        echo "=== $tweak ==="
        local cmdline=`cat header | grep cmdline=`
        [[ "$tweak" != *"$cmdline"* ]] &&
                sed -i "s/cmdline=/cmdline=$tweak /" header
done

$MAGISKBOOT repack $BOOTIMG new.img
dd if=new.img of=$BOOTIMG
rm -rf /data/local/tmp/cmdpatch