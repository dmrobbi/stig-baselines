#!/usr/bin/env bash
# Regenerate every baseline CKL from sources/ (idempotent).
set -euo pipefail
cd "$(dirname "$0")/.."

FF=sources/firefox/U_MOZ_Firefox_V6R8_Manual_STIG/U_MOZ_Firefox_STIG_V6R8_Manual-xccdf.xml
FF_CKL=U_MOZ_Firefox_STIG_V6R8_Manual-baseline.ckl

echo '== RHEL baselines =='
python3 tools/xccdf2ckl.py sources/rhel7/U_RHEL_7_V3R15_Manual_STIG/U_RHEL_7_STIG_V3R15_Manual-xccdf.xml  baselines/rhel7/U_RHEL_7_STIG_V3R15_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/rhel8/U_RHEL_8_V2R8_Manual_STIG/U_RHEL_8_STIG_V2R8_Manual-xccdf.xml    baselines/rhel8/U_RHEL_8_STIG_V2R8_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/rhel9/U_RHEL_9_V2R9_Manual_STIG/U_RHEL_9_STIG_V2R9_Manual-xccdf.xml    baselines/rhel9/U_RHEL_9_STIG_V2R9_Manual-baseline.ckl

echo '== ESXi / vCenter 6.7 baselines =='
python3 tools/xccdf2ckl.py sources/vsphere67/U_VMW_vSphere_6-7_ESXi_V1R3_Manual_STIG/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-xccdf.xml        baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/vsphere67/U_VMW_vSphere_6-7_vCenter_V1R4_Manual_STIG/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-xccdf.xml  baselines/vsphere67/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-baseline.ckl

echo '== Ubuntu baselines (Wayback-archived DISA releases; see sources/README skew note) =='
python3 tools/xccdf2ckl.py sources/ubuntu/20.04/U_CAN_Ubuntu_20-04_LTS_V2R2_Manual_STIG/U_CAN_Ubuntu_20-04_LTS_STIG_V2R2_Manual-xccdf.xml baselines/ubuntu20.04/Canonical_Ubuntu_20.04_LTS_STIG_V2R2_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/ubuntu/22.04/U_CAN_Ubuntu_22-04_LTS_V2R4_Manual_STIG/U_CAN_Ubuntu_22-04_LTS_STIG_V2R4_Manual-xccdf.xml baselines/ubuntu22.04/Canonical_Ubuntu_22.04_LTS_STIG_V2R4_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/ubuntu/24.04/U_CAN_Ubuntu_24-04_LTS_V1R1_Manual_STIG/U_CAN_Ubuntu_24-04_LTS_STIG_V1R1_Manual-xccdf.xml baselines/ubuntu24.04/Canonical_Ubuntu_24.04_LTS_STIG_V1R1_Manual-baseline.ckl

echo '== macOS baselines =='
python3 tools/xccdf2ckl.py sources/macos/26-tahoe/U_Apple_macOS_26_V1R1_Manual_STIG/U_Apple_macOS_26_V1R1_STIG_Manual-xccdf.xml baselines/macos/Apple_macOS_26_Tahoe_STIG_V1R1_Manual-baseline.ckl --asset-type Workstation
python3 tools/xccdf2ckl.py sources/macos/15-sequoia/U_Apple_macOS_15_V1R6_Manual_STIG/U_Apple_macOS_15_V1R6_STIG_Manual-xccdf.xml baselines/macos/Apple_macOS_15_Sequoia_STIG_V1R6_Manual-baseline.ckl --asset-type Workstation

echo '== Windows baselines =='
python3 tools/xccdf2ckl.py sources/windows/win10/U_MS_Windows_10_V3R6_Manual_STIG/U_MS_Windows_10_STIG_V3R6_Manual-xccdf.xml baselines/windows/MS_Windows_10_STIG_V3R6_Manual-baseline.ckl --asset-type Workstation --role Workstation
python3 tools/xccdf2ckl.py sources/windows/win11/U_MS_Windows_11_V2R9_Manual_STIG/U_MS_Windows_11_STIG_V2R9_Manual-xccdf.xml baselines/windows/MS_Windows_11_STIG_V2R9_Manual-baseline.ckl --asset-type Workstation --role Workstation
python3 tools/xccdf2ckl.py sources/windows/server2019/U_MS_Windows_Server_2019_V3R9_Manual_STIG/U_MS_Windows_Server_2019_STIG_V3R9_Manual-xccdf.xml baselines/windows/MS_Windows_Server_2019_STIG_V3R9_Manual-baseline.ckl --role 'Member Server'
python3 tools/xccdf2ckl.py sources/windows/server2022/U_MS_Windows_Server_2022_V2R10_Manual_STIG/U_MS_Windows_Server_2022_STIG_V2R10_Manual-xccdf.xml baselines/windows/MS_Windows_Server_2022_STIG_V2R10_Manual-baseline.ckl --role 'Member Server'

echo '== Firefox baseline (canonical) =='
python3 tools/xccdf2ckl.py "$FF" "baselines/firefox/$FF_CKL" --asset-type Application

echo '== Firefox copies per RHEL baseline =='
for r in rhel7 rhel8 rhel9; do cp "baselines/firefox/$FF_CKL" "baselines/$r/$FF_CKL"; done

echo '== merged RHEL + Firefox checklists =='
python3 tools/merge_ckl.py baselines/rhel7/U_RHEL_7_STIG_V3R15_Manual-baseline.ckl  "baselines/rhel7/$FF_CKL" baselines/rhel7/U_RHEL_7_V3R15_plus_Firefox_V6R8-baseline.ckl
python3 tools/merge_ckl.py baselines/rhel8/U_RHEL_8_STIG_V2R8_Manual-baseline.ckl    "baselines/rhel8/$FF_CKL" baselines/rhel8/U_RHEL_8_V2R8_plus_Firefox_V6R8-baseline.ckl
python3 tools/merge_ckl.py baselines/rhel9/U_RHEL_9_STIG_V2R9_Manual-baseline.ckl    "baselines/rhel9/$FF_CKL" baselines/rhel9/U_RHEL_9_V2R9_plus_Firefox_V6R8-baseline.ckl

echo '== validate =='
for f in baselines/*/*.ckl; do xmllint --noout "$f"; done
echo 'ALL OK'