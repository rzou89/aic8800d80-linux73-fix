#!/usr/bin/env bash
echo "===== Kernel ====="
uname -r

echo ""
echo "===== DKMS ====="
dkms status | grep aic

echo ""
echo "===== Device PCIe ====="
sudo lspci -nn | grep -i aic

echo ""
echo "===== Device USB ====="
lsusb | grep -i aic

echo ""
echo "===== Wi-Fi ====="
ip -br addr show | grep -E "wlan|wl"
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null

echo ""
echo "===== Bluetooth ====="
rfkill list
timeout 5 bluetoothctl list 2>/dev/null

echo ""
echo "===== Firmware (fmacfwbt?) ====="
sudo dmesg | grep -iE "fmacfwbt|fmacfw_8800" | tail -5

echo ""
echo "===== dmesg BT ====="
sudo dmesg | grep -iE "btusb|hci|8d81" | tail -10
