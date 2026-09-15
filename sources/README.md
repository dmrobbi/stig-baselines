# Source XCCDFs

Official DISA STIG XCCDF files; the CKLs in `baselines/` are generated from these.
Only the XCCDF XMLs are committed; zips/PDFs stay local (see .gitignore).

| Platform | File | Release | Obtained from |
|----------|------|---------|---------------|
| RHEL 7 | `rhel7/U_RHEL_7_V3R15_Manual_STIG/U_RHEL_7_STIG_V3R15_Manual-xccdf.xml` | V3R15, 2024-07-24 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_7/3/15/companion.zip` |
| RHEL 8 | `rhel8/U_RHEL_8_V2R8_Manual_STIG/U_RHEL_8_STIG_V2R8_Manual-xccdf.xml` | V2R8, 2026-07-01 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_8/2/8/companion.zip` |
| RHEL 9 | `rhel9/U_RHEL_9_V2R9_Manual_STIG/U_RHEL_9_STIG_V2R9_Manual-xccdf.xml` | V2R9, 2026-07-01 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_9/2/9/companion.zip` |
| ESXi 6.7 | `vsphere67/U_VMW_vSphere_6-7_ESXi_V1R3_Manual_STIG/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-07-26 | Archive.org copy of `U_VMW_vSphere_6-7_Y23M07_STIG.zip` (dl.dod.cyber.mil) |
| vCenter 6.7 | `vsphere67/U_VMW_vSphere_6-7_vCenter_V1R4_Manual_STIG/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2023-07-26 | same vSphere 6.7 bundle |

## Refreshing to a newer release

1. `curl -L -o sources/zips/U_<NAME>.zip https://cyber.trackr.live/stig/<Title>/<V>/<R>/companion.zip`
   (DISA's own portal now requires auth; trackr mirrors the official packages and
   tracks current releases — check `https://cyber.trackr.live/stig` for the latest
   version/release of each STIG.)
2. Unzip into `sources/<platform>/`, update this table + README.
3. `make convert validate`