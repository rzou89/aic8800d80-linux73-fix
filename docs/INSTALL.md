# Instalasi

## Prasyarat

- Arch Linux / CachyOS
- Kernel 7.3.x + headers
- base-devel, git, dkms, clang

## Langkah

1. Install dependensi:

   sudo pacman -S --needed base-devel git dkms clang linux-cachyos-headers

2. Clone repo:

   git clone https://github.com/USERNAME/aic8800d80-linux73-fix.git
   cd aic8800d80-linux73-fix

3. Jalankan installer:

   chmod +x scripts/install.sh
   ./scripts/install.sh

4. Tambahkan kernel parameter di /etc/default/limine:

   pcie_port_pm=off pcie_aspm=off

   Lalu jalankan: sudo limine-update

5. Shutdown total, cabut kabel power 30 detik, lalu nyalakan kembali.

6. Verifikasi dengan: ./scripts/verify.sh
