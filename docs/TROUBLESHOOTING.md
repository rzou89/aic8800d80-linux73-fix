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
