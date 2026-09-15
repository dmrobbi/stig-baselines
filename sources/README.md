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
| macOS 15 Sequoia | `macos/15-sequoia/U_Apple_macOS_15_V1R6_Manual_STIG/U_Apple_macOS_15_V1R6_STIG_Manual-xccdf.xml` | V1R6, 2026-01-05 | Archive.org `U_Apple_macOS_15_V1R6_STIG.zip` |
| macOS 26 Tahoe | `macos/26-tahoe/U_Apple_macOS_26_V1R1_Manual_STIG/U_Apple_macOS_26_V1R1_STIG_Manual-xccdf.xml` | V1R1, 2025-09-11 (latest archived; trackr latest = V1R3) | Archive.org `U_Apple_macOS_26_V1R1_STIG.zip` |
| Ubuntu 20.04 | `ubuntu/20.04/U_CAN_Ubuntu_20-04_LTS_V2R2_Manual_STIG/U_CAN_Ubuntu_20-04_LTS_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2025-04-02 (latest = V2R4) | Archive.org `U_CAN_Ubuntu_20-04_LTS_V2R2_STIG.zip` |
| Ubuntu 22.04 | `ubuntu/22.04/U_CAN_Ubuntu_22-04_LTS_V2R4_Manual_STIG/U_CAN_Ubuntu_22-04_LTS_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2025-04-02 (latest = V2R9) | Archive.org `U_CAN_Ubuntu_22-04_LTS_V2R4_STIG.zip` |
| Ubuntu 24.04 | `ubuntu/24.04/U_CAN_Ubuntu_24-04_LTS_V1R1_Manual_STIG/U_CAN_Ubuntu_24-04_LTS_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2025-01-28 (latest = V1R6) | Archive.org `U_CAN_Ubuntu_24-04_LTS_V1R1_STIG.zip` |
| Windows 10 | `windows/win10/U_MS_Windows_10_V3R6_Manual_STIG/U_MS_Windows_10_STIG_V3R6_Manual-xccdf.xml` | V3R6, 2026-01-05 (current) | cyber.trackr.live `/stig/Windows_10/3/6/companion.zip` |
| Windows 11 | `windows/win11/U_MS_Windows_11_V2R9_Manual_STIG/U_MS_Windows_11_STIG_V2R9_Manual-xccdf.xml` | V2R9, 2026-08-10 (current) | cyber.trackr.live `/stig/Windows_11/2/9/companion.zip` |
| Windows Server 2019 | `windows/server2019/U_MS_Windows_Server_2019_V3R9_Manual_STIG/U_MS_Windows_Server_2019_STIG_V3R9_Manual-xccdf.xml` | V3R9, 2026-07-01 (current) | cyber.trackr.live `/stig/Windows_Server_2019/3/9/companion.zip` |
| Windows Server 2022 | `windows/server2022/U_MS_Windows_Server_2022_V2R10_Manual_STIG/U_MS_Windows_Server_2022_STIG_V2R10_Manual-xccdf.xml` | V2R10, 2026-08-10 (current) | cyber.trackr.live `/stig/Windows_Server_2022/2/10/companion.zip` |
| Firefox | `firefox/U_MOZ_Firefox_V6R8_Manual_STIG/U_MOZ_Firefox_STIG_V6R8_Manual-xccdf.xml` | V6R8, 2026-07-01 | cyber.trackr.live `/stig/Mozilla_Firefox/6/8/companion.zip` |
| RHEL 7 (SCAP, automation) | `scap/U_RHEL_7_V3R2_STIG_SCAP_1-2_Benchmark.xml` | V3R2 (stale — RHEL7 SCAP not published after) | Archive.org `U_RHEL_7_V3R2_STIG_SCAP_1-2_Benchmark.zip` |
| RHEL 8 (SCAP, automation) | `scap/U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark.xml` | V2R2 (stale vs manual V2R8) | Archive.org `U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark.zip` |
| RHEL 9 (SCAP, automation) | `scap/U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.xml` | V2R5 (stale vs manual V2R9) | Archive.org `U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.zip` |

## Refreshing to a newer release

1. `curl -L -o sources/zips/U_<NAME>.zip https://cyber.trackr.live/stig/<Title>/<V>/<R>/companion.zip`
   (DISA's own portal now requires auth; trackr mirrors the official packages and
   tracks current releases — check `https://cyber.trackr.live/stig` for the latest
   version/release of each STIG.)
2. Unzip into `sources/<platform>/`, update this table + README.
3. `make convert validate`