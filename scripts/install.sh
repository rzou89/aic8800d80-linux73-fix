#!/usr/bin/env bash
# AIC8800D80 Linux 7.3 Fix Installer
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$HERE")"
WORK="${WORK:-$HOME/aic8800d80-pcie-dkms}"
KVER="$(uname -r)"

echo "==> [1/7] Cek dependensi"
for bin in git patch makepkg dkms; do
    command -v "$bin" >/dev/null || {
        echo "❌ Tidak ditemukan: $bin"
        echo "   Instal: sudo pacman -S base-devel git dkms"
        exit 1
    }
done

echo "==> [2/7] Clone AUR source ke $WORK"
if [[ -d "$WORK/.git" ]]; then
    git -C "$WORK" pull --ff-only || true
else
    rm -rf "$WORK"
    git clone https://aur.archlinux.org/aic8800d80-pcie-dkms.git "$WORK"
fi

echo "==> [3/7] Salin patch ke direktori AUR"
cp -f "$REPO_ROOT/patches/0007-linux-7.3-compat.patch" "$WORK/"
cp -f "$REPO_ROOT/patches/CONFIG_USB_BT-enable.patch" "$WORK/"

echo "==> [4/7] Patch PKGBUILD & source"
cd "$WORK"
if ! grep -q "0007-linux-7.3-compat.patch" PKGBUILD; then
    patch -p1 -i "$REPO_ROOT/patches/PKGBUILD.patch"
fi

echo "==> [5/7] Build dengan makepkg"
makepkg -sif --skipchecksums || {
    echo "❌ Build gagal. Cek output di atas."
    exit 1
}

echo "==> [6/7] Aktifkan CONFIG_USB_BT untuk Bluetooth"
DKMS_MAKEFILE="/usr/src/aic8800-6.4.3.0/Makefile"
if [[ -f "$DKMS_MAKEFILE" ]]; then
    sudo sed -i 's/^CONFIG_USB_BT = n$/CONFIG_USB_BT = y/' "$DKMS_MAKEFILE"
    echo "   CONFIG_USB_BT = y"
    sudo dkms remove aic8800/6.4.3.0 --all 2>/dev/null || true
    sudo dkms install aic8800/6.4.3.0 -k "$KVER" --force
else
    echo "⚠️  $DKMS_MAKEFILE tidak ditemukan — skip"
fi

echo "==> [7/7] Blacklist modul konflik + tambah kernel params"
echo "blacklist aic_load_fw" | sudo tee /etc/modprobe.d/blacklist-aic-loadfw.conf
echo "blacklist aic_btusb" | sudo tee /etc/modprobe.d/blacklist-aic-btusb.conf

echo ""
echo "🎉 Instalasi selesai! Tambahkan kernel parameter berikut di Limine:"
echo ""
echo "    pcie_port_pm=off pcie_aspm=off"
echo ""
echo "Cara: sudo nano /etc/default/limine"
echo "      # Edit baris KERNEL_CMDLINE[default]+=\"... pcie_port_pm=off pcie_aspm=off\""
echo "      sudo limine-update"
echo ""
echo "Lalu reboot. Setelah reboot, cek dengan:"
echo "    ip -br addr show | grep wlan"
echo "    rfkill list"
echo "    sudo dmesg | grep -iE 'fmacfwbt|btusb|hci' | tail -20"
