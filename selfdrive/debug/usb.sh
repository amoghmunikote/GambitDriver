#!/bin/sh
set -e

case "$1" in
  start)
    echo "Configuring USB for ADB..." > /dev/kmsg
    # Ensure ConfigFS is mounted
    if ! mountpoint -q /sys/kernel/config; then
      mount -t configfs none /sys/kernel/config
    fi

    # Configure USB Gadget
    cd /sys/kernel/config/usb_gadget
    mkdir -p g1
    cd g1
    mkdir -p strings/0x409 configs/c.1 functions/ffs.adb
    echo "0x18D1" > idVendor  # Google Vendor ID
    echo "0x4EE7" > idProduct # ADB Product ID
    echo "OpenPilot" > strings/0x409/manufacturer
    echo "OpenPilot Device" > strings/0x409/product
    echo "1234567890" > strings/0x409/serialnumber
    ln -s functions/ffs.adb configs/c.1
    mkdir -p /dev/usb-ffs/adb
    mount -t functionfs adb /dev/usb-ffs/adb
    echo "USB configuration complete." > /dev/kmsg
    ;;
  stop)
    echo "Removing USB configuration..." > /dev/kmsg
    cd /sys/kernel/config/usb_gadget/g1
    rm configs/c.1/ffs.adb
    umount /dev/usb-ffs/adb
    rmdir /dev/usb-ffs/adb
    cd /sys/kernel/config/usb_gadget
    rmdir g1
    echo "USB configuration removed." > /dev/kmsg
    ;;
  *)
    echo "Usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac

exit 0