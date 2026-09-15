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