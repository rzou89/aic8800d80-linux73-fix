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

## Sleep tidak berfungsi (PC tidak bisa suspend)

Jika PC tidak bisa sleep setelah install driver ini, kemungkinan besar **konfigurasi PowerDevil (KDE) korup**, bukan masalah driver.

### Gejala

- `systemd-inhibit --list` menampilkan PowerDevil dengan `MODE = block`
- Menu Sleep diklik tapi PC tidak tidur
- Sleep berhasil kalau PowerDevil dimatikan manual

### Solusi

Reset konfigurasi PowerDevil:

    mv ~/.config/powerdevilrc ~/.config/powerdevilrc.bak
    systemctl --user restart plasma-powerdevil.service

Tes suspend dari menu KDE. Jika berhasil, masalah teratasi.

Jika masih gagal, tambahkan workaround delay:

    mkdir -p ~/.config/systemd/user/plasma-powerdevil.service.d
    cat > ~/.config/systemd/user/plasma-powerdevil.service.d/override.conf <<'EOF'
    [Service]
    ExecStartPre=/bin/sleep 3
    Environment=POWERDEVIL_NO_DDCUTIL=1
    EOF
    systemctl --user daemon-reload
    systemctl --user restart plasma-powerdevil.service

Jika masih gagal juga, nonaktifkan PowerDevil sementara:

    systemctl --user disable --now plasma-powerdevil.service

Suspend akan ditangani `systemd-logind`. Fitur KDE (battery profile, brightness auto) hilang sementara.

Untuk mengembalikan:

    systemctl --user enable --now plasma-powerdevil.service
