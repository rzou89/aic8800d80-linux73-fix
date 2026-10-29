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

## (Khusus KDE) PC tidak bisa sleep setelah driver aktif

**Ini BUKAN bug dari driver AIC8800.** Ini adalah bug lama dari KDE PowerDevil yang memblokir suspend manual. Masalah ini sering muncul setelah driver Wi-Fi aktif di lingkungan KDE Plasma.

### Gejala
- Klik menu "Sleep" di KDE tapi PC tidak tidur.
- `systemctl suspend` biasa juga gagal.
- Sleep **berhasil** jika menggunakan perintah `systemctl suspend --ignore-inhibitors`.

### Solusi: Buat Skrip dan Shortcut `Meta+Enter`

Karena menu bawaan KDE bermasalah, kita buat jalan pintas sendiri.

**1. Buat skrip sleep:**
```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/sleep-ignore-inhibitors.sh <<'EOF'
#!/bin/sh
systemctl suspend --ignore-inhibitors
EOF
chmod +x ~/.local/bin/sleep-ignore-inhibitors.sh

2. Pasang shortcut di KDE:

    Buka System Settings → Keyboard → Shortcuts.

    Klik Custom Shortcuts → Edit → New → Global Shortcut → Command/URL.

    Beri nama "Sleep FIX", isi Command dengan: /home/USERNAME/.local/bin/sleep-ignore-inhibitors.sh (ganti USERNAME dengan nama user Anda).

    Pindah ke tab Trigger, klik Add, lalu tekan Meta+Enter.

    Klik Apply.

Sekarang, setiap kali Anda menekan Meta+Enter, PC akan langsung tidur tanpa hambatan.


---

### 💾 Langkah 3: Simpan dan Upload

1. Simpan file: tekan `Ctrl+O`, lalu `Enter`, lalu `Ctrl+X` untuk keluar.
2. Jalankan perintah ini satu per satu untuk upload ke GitHub:
   ```fish
   git add docs/TROUBLESHOOTING.md
