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

## Sleep / Wakeup Freeze (PC hang saat tidur atau bangun)

**Penyebab:** Driver AIC8800 memiliki kebocoran *wakelock* (`__pm_stay_awake`) yang membuat sistem menolak tidur atau macet (hang) saat driver di-*unload* (`modprobe -r`). Selain itu, driver ini belum memiliki fungsi *resume* PCIe yang sempurna.

**Solusi Final:** Matikan fungsi wakelock di dalam *source code* driver menggunakan *patch*.

1. Pastikan Anda sudah mengunduh repo ini.
2. Terapkan patch wakelock:
   ```bash
   patch -d /usr/src/aic8800-6.4.3.0/aic8800_fdrv -p1 < patches/fix-wakelock-hang.patch

(Jika folder /usr/src/aic8800-6.4.3.0 belum ada, jalankan scripts/install_manual.py terlebih dahulu).

    Rebuild driver:
    bash

    sudo dkms install /usr/src/aic8800-6.4.3.0 -k $(uname -r) --force

    Gunakan skrip tidur standar bawaan AUR di /usr/lib/systemd/system-sleep/aic8800d80 (yang berisi perintah modprobe -r dan modprobe).

Catatan: Setelah bangun dari tidur, akan ada jeda sekitar 3 detik sebelum Wi-Fi menyala kembali. Ini normal, karena driver perlu mengunggah ulang file firmware (fmacfw_8800D80_pcie.bin) ke perangkat keras.
