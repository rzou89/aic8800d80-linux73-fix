import os
import shutil
import subprocess

src_dir = "/usr/src/aic8800-6.4.3.0"
local_repo = "/home/rzou89/aic8800d80-linux73-fix/source/aic8800_fdrv"

print("==> 1. Menyiapkan direktori /usr/src...")
os.makedirs(src_dir, exist_ok=True)

print("==> 2. Menyalin source code dari GitHub...")
if os.path.exists(os.path.join(src_dir, "aic8800_fdrv")):
    shutil.rmtree(os.path.join(src_dir, "aic8800_fdrv"))
shutil.copytree(local_repo, os.path.join(src_dir, "aic8800_fdrv"))

print("==> 3. Membuat Makefile dan dkms.conf...")
with open(os.path.join(src_dir, "Makefile"), "w") as f:
    f.write("obj-m += aic8800_fdrv/\n")

dkms_conf = """PACKAGE_NAME="aic8800"
PACKAGE_VERSION="6.4.3.0"
MAKE[0]="make -C ${kernel_source_dir} M=${dkms_tree}/${PACKAGE_NAME}/${PACKAGE_VERSION}/build"
CLEAN="make -C ${kernel_source_dir} M=${dkms_tree}/${PACKAGE_NAME}/${PACKAGE_VERSION}/build clean"
BUILT_MODULE_NAME[0]="aic8800D80_fdrv"
BUILT_MODULE_LOCATION[0]="aic8800_fdrv/"
DEST_MODULE_LOCATION[0]="/kernel/drivers/net/wireless/aic8800D80"
AUTOINSTALL="yes"
"""
with open(os.path.join(src_dir, "dkms.conf"), "w") as f:
    f.write(dkms_conf)

print("==> 4. Menerapkan patch Wakelock (Anti-Hang)...")
pcie_c = os.path.join(src_dir, "aic8800_fdrv/aicwf_pcie.c")
with open(pcie_c, "r") as f:
    content = f.read()
content = content.replace("__pm_stay_awake(pci_ws);", "// __pm_stay_awake(pci_ws);")
with open(pcie_c, "w") as f:
    f.write(content)

print("✅ SUKSES! Source code telah disiapkan dan ditambal.")

