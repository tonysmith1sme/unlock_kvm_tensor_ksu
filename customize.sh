#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)
# Modify by TonySmith
REPLACE="
/system/bin/cmdpatch
"

ui_print "[*] Setting executable permissions..."
mkdir /data/adb/modules/.rw
mkdir /data/adb/modules/.rw/system
mkdir /data/adb/modules/.rw/system upperdir
mkdir /data/adb/modules/.rw/system workdir

ui_print "[*] Patching CMDLINE"
#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)
# Modify by TonySmith

set -e

MAGISKBOOT="/data/adb/magisk/magiskboot"

err() {
    echo -e "\e[91m[!] $@\e[39m"
    exit 1
}

[[ ! -f "$MAGISKBOOT" ]] && err "Failed to find magiskboot binary. Exiting."

mkdir -p /data/local/tmp/cmdpatch
cd /data/local/tmp/cmdpatch

SLOT=$(getprop ro.boot.slot_suffix)
BOOT="boot$SLOT"

BOOTIMG="/dev/block/by-name/$BOOT"

dd if=$BOOTIMG of=/sdcard/$BOOT.img.bk
$MAGISKBOOT unpack -h $BOOTIMG

# Replace kvm-arm.mode=protected with kvm-arm.mode=nvhe
tweak="kvm-arm.mode=nvhe"
protected="kvm-arm.mode=protected"

echo "=== Modifying cmdline ==="
cmdline=$(cat header | grep cmdline=)

# Replace protected mode with nvhe mode
if [[ "$cmdline" == *"$protected"* ]]; then
    sed -i "s/$protected/$tweak/g" header
fi

# If kvm-arm.mode=protected is not found, add kvm-arm.mode=nvhe
if [[ "$cmdline" != *"$protected"* && "$cmdline" != *"$tweak"* ]]; then
    sed -i "s/cmdline=/cmdline=$tweak /" header
fi

$MAGISKBOOT repack $BOOTIMG new.img
dd if=new.img of=$BOOTIMG

ui_print "[*] finished patching kvm mode..."
