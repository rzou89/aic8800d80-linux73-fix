# AIC8800D80 Linux 7.3 Fix — Wi-Fi PCIe + Bluetooth

Patch untuk driver **AIC8800D80** (UGREEN CM958 dan kartu combo serupa) agar berfungsi penuh di **CachyOS / Arch Linux kernel 7.3**.

## Status

| Komponen | Status |
| :--- | :--- |
| Wi-Fi PCIe (`a69c:8d80`) | ✅ Berfungsi, 390 Mbit/s VHT |
| Bluetooth USB (`a69c:8d84`) | ✅ Berfungsi (dengan power drain) |

## Masalah yang Diselesaikan

Kernel **Linux 7.3** mengubah API `cfg80211` yang memecahkan driver ini:

1. `probe_client` → `probe_peer` (cookie by-value, bukan pointer)
2. `cfg80211_probe_status()` mendapat parameter `link_id` baru
3. `remain_on_channel()` / `mgmt_tx()` menerima cookie dari kernel

Selain itu, paket AUR memiliki `CONFIG_USB_BT=n` yang membuat **firmware Bluetooth tidak pernah dimuat**.

## Solusi

1. **Patch 7.3** (`patches/0007-linux-7.3-compat.patch`) — kompatibilitas `cfg80211` 7.3
2. **`CONFIG_USB_BT=y`** (`patches/CONFIG_USB_BT-enable.patch`) — agar driver memuat `fmacfwbt_8800D80_pcie.bin`
3. **Blacklist `aic_load_fw` & `aic_btusb`** — biarkan `btusb` standar kernel yang menangani BT
4. **Kernel parameter `pcie_port_pm=off pcie_aspm=off`** — cegah D3cold pada Wi-Fi PCIe

## Cara Pakai

```bash
git clone https://github.com/USERNAME/aic8800d80-linux73-fix.git
cd aic8800d80-linux73-fix
./scripts/install.sh
