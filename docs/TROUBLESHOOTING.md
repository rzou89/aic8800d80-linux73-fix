# Troubleshooting

## Wi-Fi mati setelah update kernel

Jalankan:

   sudo dkms remove aic8800/6.4.3.0 --all
   sudo dkms install aic8800/6.4.3.0 -k $(uname -r) --force

## Kernel panic saat boot

Boot ke LTS mode atau snapshot Limine sebelum instalasi.

## Bluetooth tidak muncul

Cek firmware BT dengan: sudo dmesg | grep fmacfwbt

Jika kosong, CONFIG_USB_BT masih n. Cek dengan:

   grep CONFIG_USB_BT /usr/src/aic8800-6.4.3.0/Makefile

Ubah ke y jika perlu, lalu rebuild:

   sudo dkms remove aic8800/6.4.3.0 --all
   sudo dkms install aic8800/6.4.3.0 -k $(uname -r) --force

## Power drain wajib

Setiap install driver, wajib power drain total (cabut kabel 30 detik).

## USB error -110

Chip USB BT crash. Power drain total (cabut kabel 30 detik) satu-satunya solusi.

## (Khusus KDE) PC tidak bisa sleep atau layar mati tapi PC tetap menyala

Setelah driver Wi-Fi aktif, beberapa pengguna KDE Plasma mengalami masalah tidur. Ini **BUKAN bug dari driver AIC8800**, melainkan kombinasi bug dari KDE PowerDevil dan systemd v256+.

Ada dua masalah berbeda yang harus diatasi:

### Masalah 1: PowerDevil memblokir suspend (PC tidak mau tidur)
KDE PowerDevil terkadang menahan inhibitor `block` saat Anda meminta sleep, sehingga sistem menolak tidur.

**Solusi:** Gunakan skrip khusus yang mengabaikan inhibitor.
1. Buat skrip:
   ```bash
   mkdir -p ~/.local/bin
   cat > ~/.local/bin/sleep-ignore-inhibitors.sh <<'EOF'
   #!/bin/sh
   systemctl suspend --ignore-inhibitors
   EOF
   chmod +x ~/.local/bin/sleep-ignore-inhibitors.sh

2. Pasang di System Settings → Keyboard → Shortcuts → Custom Shortcuts (misal dengan shortcut Meta+Enter) dan arahkan ke skrip tersebut.

Masalah 2: Systemd Freeze Hang (Layar mati tapi PC tetap menyala)

Systemd v256+ mencoba membekukan semua proses sebelum tidur. Pada kombinasi GPU Intel Xe + Wi-Fi PCIe tertentu, proses ini macet (hang), membuat layar mati tetapi kipas dan lampu PC tetap menyala.

Solusi: Nonaktifkan pembekuan sesi pengguna di systemd.
Jalankan perintah:
bash

sudo systemctl edit systemd-suspend.service

Lalu tambahkan baris berikut ke dalam file tersebut:
ini

[Service]
Environment="SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"

Simpan, lalu jalankan sudo systemctl daemon-reload. Sekarang sleep seharusnya berfungsi normal.
