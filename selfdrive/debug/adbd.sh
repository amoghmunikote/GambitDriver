#!/bin/sh
set -e

case "$1" in
  start)
    echo -n "Starting USB configuration: " > /dev/kmsg
    /selfdrive/debug/usb.sh start
    echo "Starting adbd service..." > /dev/kmsg
    start-stop-daemon -S -b -x /sbin/adbd
    echo "adbd service started." > /dev/kmsg
    ;;
  stop)
    echo "Stopping adbd service..." > /dev/kmsg
    start-stop-daemon -K -n adbd
    echo "adbd service stopped." > /dev/kmsg
    ;;
  *)
    echo "Usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac

exit 0