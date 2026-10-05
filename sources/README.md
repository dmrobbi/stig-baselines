# Source XCCDFs

Official DISA STIG XCCDF files; the CKLs in `baselines/` are generated from these.
The original DISA bundles (XCCDF + PDFs) are **committed under `sources/zips/`** so
the whole kit works offline; only the SCAP benchmark zips are absent — their
benchmark XMLs are committed directly under `sources/scap/`.

## Original bundles (sources/zips/)

| Zip | Matches baseline | Fetched from |
|-----|------------------|--------------|
| `U_RHEL_7_V3R15_Manual_STIG.zip` | RHEL 7 V3R15 | cyber.trackr.live companion (V3R15) |
| `U_RHEL_8_V2R8_Manual_STIG.zip` | RHEL 8 V2R8 | cyber.trackr.live companion (V2R8) |
| `U_RHEL_9_V2R9_Manual_STIG.zip` | RHEL 9 V2R9 | cyber.trackr.live companion (V2R9) |
| `U_MOZ_Firefox_V6R8_Manual_STIG.zip` | Firefox V6R8 | cyber.trackr.live companion (V6R8) |
| `U_MS_Windows_10_V3R6_Manual_STIG.zip` | Windows 10 V3R6 | cyber.trackr.live companion (V3R6) |
| `U_MS_Windows_11_V2R9_Manual_STIG.zip` | Windows 11 V2R9 | cyber.trackr.live companion (V2R9) |
| `U_MS_Windows_Server_2019_V3R9_Manual_STIG.zip` | Server 2019 V3R9 | cyber.trackr.live companion (V3R9) |
| `U_MS_Windows_Server_2022_V2R10_Manual_STIG.zip` | Server 2022 V2R10 | cyber.trackr.live companion (V2R10) |
| `U_VMW_vSphere_6-7_Y23M07_STIG.zip` | ESXi 6.7 V1R3 / vCenter 6.7 V1R4 (+ 10 component STIGs) | web.archive.org replay of `dl.dod.cyber.mil/.../U_VMW_vSphere_6-7_Y23M07_STIG.zip` (snapshot 2025-02-12) |
| `U_Apple_macOS_26_V1R1_STIG.zip` | macOS 26 V1R1 | web.archive.org replay (2025 route) |
| `U_Apple_macOS_15_V1R6_STIG.zip` | macOS 15 V1R6 | web.archive.org replay (2025 route) |
| `U_CAN_Ubuntu_20-04_LTS_V2R2_STIG.zip` | Ubuntu 20.04 V2R2 | web.archive.org replay (2025 route) |
| `U_CAN_Ubuntu_22-04_LTS_V2R4_STIG.zip` | Ubuntu 22.04 V2R4 | web.archive.org replay (2025 route) |
| `U_CAN_Ubuntu_24-04_LTS_V1R1_STIG.zip` | Ubuntu 24.04 V1R1 | web.archive.org replay (2025 route) |

Every zip was verified to contain the exact XCCDF the baseline was generated
from. Trackr only keeps companions for the latest release, so the older
macOS/Ubuntu releases came from Wayback replays of the original
`dl.dod.cyber.mil/wp-content/uploads/stigs/zip/…` URLs.

| Platform | File | Release | Obtained from |
|----------|------|---------|---------------|

2026-10-05 update: trackr now serves per-revision `/download` directly (companion
zips are gone). The current Ubuntu 20.04 V2R4 / 22.04 V2R9 / 24.04 V1R6 and
macOS 26 V1R3 sources below were fetched straight from
`cyber.trackr.live /stig/<Title>/<V>/<R>/download` (all HEAD-200); the older
Wayback-replayed releases remain committed for provenance.
| RHEL 7 | `rhel7/U_RHEL_7_V3R15_Manual_STIG/U_RHEL_7_STIG_V3R15_Manual-xccdf.xml` | V3R15, 2024-07-24 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_7/3/15/companion.zip` |
| RHEL 8 | `rhel8/U_RHEL_8_V2R8_Manual_STIG/U_RHEL_8_STIG_V2R8_Manual-xccdf.xml` | V2R8, 2026-07-01 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_8/2/8/companion.zip` |
| RHEL 9 | `rhel9/U_RHEL_9_V2R9_Manual_STIG/U_RHEL_9_STIG_V2R9_Manual-xccdf.xml` | V2R9, 2026-07-01 | cyber.trackr.live `/stig/Red_Hat_Enterprise_Linux_9/2/9/companion.zip` |
| ESXi 6.7 | `vsphere67/U_VMW_vSphere_6-7_ESXi_V1R3_Manual_STIG/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-07-26 | Archive.org copy of `U_VMW_vSphere_6-7_Y23M07_STIG.zip` (dl.dod.cyber.mil) |
| vCenter 6.7 | `vsphere67/U_VMW_vSphere_6-7_vCenter_V1R4_Manual_STIG/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2023-07-26 | same vSphere 6.7 bundle |
| VMware vSphere 6.7 Perfcharts Tomcat | `sources/vsphere67/U_VMW_vSphere_6-7_Perfcharts_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_Perfcharts_Tomcat_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-16 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 Photon OS | `sources/vsphere67/U_VMW_vSphere_6-7_Photon_OS_V1R6_Manual_STIG/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-xccdf.xml` | V1R6, 2023-06-16 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 PostgreSQL | `sources/vsphere67/U_VMW_vSphere_6-7_PostgreSQL_V1R2_Manual_STIG/U_VMW_vSphere_6-7_PostgreSQL_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 RhttpProxy | `sources/vsphere67/U_VMW_vSphere_6-7_RhttpProxy_V1R3_Manual_STIG/U_VMW_vSphere_6-7_RhttpProxy_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 STS Tomcat | `sources/vsphere67/U_VMW_vSphere_6-7_STS_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_STS_Tomcat_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 UI Tomcat | `sources/vsphere67/U_VMW_vSphere_6-7_UI_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_UI_Tomcat_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 VAMI lighttpd | `sources/vsphere67/U_VMW_vSphere_6-7_VAMI-lighttpd_V1R3_Manual_STIG/U_VMW_vSphere_6-7_VAMI-lighttpd_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 Virgo Client | `sources/vsphere67/U_VMW_vSphere_6-7_Virgo-Client_V1R2_Manual_STIG/U_VMW_vSphere_6-7_Virgo-Client_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-20 | vSphere 6.7 bundle (committed) |
| VMware vSphere 6.7 Virtual Machine | `sources/vsphere67/U_VMW_vSphere_6-7_Virtual_Machine_V1R3_Manual_STIG/U_VMW_vSphere_6-7_Virtual_Machine_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-16 | vSphere 6.7 bundle (committed) |
| macOS 15 Sequoia | `macos/15-sequoia/U_Apple_macOS_15_V1R6_Manual_STIG/U_Apple_macOS_15_V1R6_STIG_Manual-xccdf.xml` | V1R6, 2026-01-05 | Archive.org `U_Apple_macOS_15_V1R6_STIG.zip` |
| macOS 26 Tahoe | `macos/26-tahoe/U_Apple_macOS_26_V1R3_Manual_STIG/U_Apple_macOS_26_V1R3_STIG_Manual-xccdf.xml` | V1R3, 2026-05-23 (current) | cyber.trackr.live `/stig/Apple_macOS_26_(Tahoe)/1/3/download` |
| macOS 26 Tahoe (V1R1, superseded) | `macos/26-tahoe/U_Apple_macOS_26_V1R1_Manual_STIG/U_Apple_macOS_26_V1R1_STIG_Manual-xccdf.xml` | V1R1, 2025-09-11 | Archive.org `U_Apple_macOS_26_V1R1_STIG.zip` |
| Ubuntu 20.04 | `ubuntu/20.04/U_CAN_Ubuntu_20-04_LTS_V2R4_Manual_STIG/U_CAN_Ubuntu_20-04_LTS_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2025-08-27 (current) | cyber.trackr.live `/stig/Canonical_Ubuntu_20.04_LTS/2/4/download` |
| Ubuntu 20.04 (V2R2, superseded) | `ubuntu/20.04/U_CAN_Ubuntu_20-04_LTS_V2R2_Manual_STIG/U_CAN_Ubuntu_20-04_LTS_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2025-04-02 | Archive.org `U_CAN_Ubuntu_20-04_LTS_V2R2_STIG.zip` |
| Ubuntu 22.04 | `ubuntu/22.04/U_CAN_Ubuntu_22-04_LTS_V2R9_Manual_STIG/U_CAN_Ubuntu_22-04_LTS_STIG_V2R9_Manual-xccdf.xml` | V2R9, 2026-05-14 (current) | cyber.trackr.live `/stig/Canonical_Ubuntu_22.04_LTS/2/9/download` |
| Ubuntu 22.04 (V2R4, superseded) | `ubuntu/22.04/U_CAN_Ubuntu_22-04_LTS_V2R4_Manual_STIG/U_CAN_Ubuntu_22-04_LTS_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2025-04-02 | Archive.org `U_CAN_Ubuntu_22-04_LTS_V2R4_STIG.zip` |
| Ubuntu 24.04 | `ubuntu/24.04/U_CAN_Ubuntu_24-04_LTS_V1R6_Manual_STIG/U_CAN_Ubuntu_24-04_LTS_STIG_V1R6_Manual-xccdf.xml` | V1R6, 2026-05-14 (current) | cyber.trackr.live `/stig/Canonical_Ubuntu_24.04_LTS/1/6/download` |
| Ubuntu 24.04 (V1R1, superseded) | `ubuntu/24.04/U_CAN_Ubuntu_24-04_LTS_V1R1_Manual_STIG/U_CAN_Ubuntu_24-04_LTS_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2025-01-28 | Archive.org `U_CAN_Ubuntu_24-04_LTS_V1R1_STIG.zip` |
| Windows 10 | `windows/win10/U_MS_Windows_10_V3R6_Manual_STIG/U_MS_Windows_10_STIG_V3R6_Manual-xccdf.xml` | V3R6, 2026-01-05 (current) | cyber.trackr.live `/stig/Windows_10/3/6/companion.zip` |
| Windows 11 | `windows/win11/U_MS_Windows_11_V2R9_Manual_STIG/U_MS_Windows_11_STIG_V2R9_Manual-xccdf.xml` | V2R9, 2026-08-10 (current) | cyber.trackr.live `/stig/Windows_11/2/9/companion.zip` |
| Windows Server 2019 | `windows/server2019/U_MS_Windows_Server_2019_V3R9_Manual_STIG/U_MS_Windows_Server_2019_STIG_V3R9_Manual-xccdf.xml` | V3R9, 2026-07-01 (current) | cyber.trackr.live `/stig/Windows_Server_2019/3/9/companion.zip` |
| Windows Server 2022 | `windows/server2022/U_MS_Windows_Server_2022_V2R10_Manual_STIG/U_MS_Windows_Server_2022_STIG_V2R10_Manual-xccdf.xml` | V2R10, 2026-08-10 (current) | cyber.trackr.live `/stig/Windows_Server_2022/2/10/companion.zip` |
| Firefox | `firefox/U_MOZ_Firefox_V6R8_Manual_STIG/U_MOZ_Firefox_STIG_V6R8_Manual-xccdf.xml` | V6R8, 2026-07-01 | cyber.trackr.live `/stig/Mozilla_Firefox/6/8/companion.zip` |
| VMware vSphere 6.5 ESXi | `sources/vsphere65/U_VMW_vSphere_6-5_ESXi_V2R4_Manual_STIG/U_VMW_vSphere_6-5_ESXi_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2023-06-16 | cyber.trackr.live `/stig/VMware_vSphere_6.5_ESXi/2/4/download` |
| VMware vSphere 6.5 Virtual Machine | `sources/vsphere65/U_VMW_vSphere_6-5_Virtual_Machine_V2R2_Manual_STIG/U_VMW_vSphere_6-5_Virtual_Machine_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_6.5_Virtual_Machine/2/2/download` |
| VMware vSphere 6.5 vCenter Server for Windows | `sources/vsphere65/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_V2R3_Manual_STIG/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2023-06-16 | cyber.trackr.live `/stig/VMW_vSphere_6.5_vCenter_Server_for_Windows/2/3/download` |
| VMware vSphere 6.7 EAM Tomcat | `sources/vsphere67/U_VMW_vSphere_6-7_EAM_Tomcat_V1R4_Manual_STIG/VMware_vSphere_6.7_EAM_Tomcat_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2023-07-26 | vSphere 6.7 bundle (committed) |
| VMware vSphere 7.0 ESXi | `sources/vsphere70/U_VMW_vSphere_7-0_ESXi_V1R4_Manual_STIG/U_VMW_vSphere_7-0_ESXi_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2025-02-11 | cyber.trackr.live `/stig/VMware_vSphere_7.0_ESXi/1/4/download` |
| VMware vSphere 7.0 VAMI | `sources/vsphere70/U_VMW_vSphere_7-0_VAMI_V1R2_Manual_STIG/U_VMW_vSphere_7-0_VAMI_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_VAMI/1/2/download` |
| VMware vSphere 7.0 Virtual Machine | `sources/vsphere70/U_VMW_vSphere_7-0_Virtual_Machine_V1R4_Manual_STIG/U_VMW_vSphere_7-0_Virtual_Machine_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2024-12-16 | cyber.trackr.live `/stig/VMware_vSphere_7.0_Virtual_Machine/1/4/download` |
| VMware vSphere 7.0 vCenter | `sources/vsphere70/U_VMW_vSphere_7-0_vCenter_V1R3_Manual_STIG/U_VMW_vSphere_7-0_vCenter_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-12-21 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter/1/3/download` |
| VMware vSphere 7.0 vCenter Appliance EAM | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_EAM_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_EAM_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_EAM/1/2/download` |
| VMware vSphere 7.0 vCenter Appliance Lookup Service | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_Lookup_Svc_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_Lookup_Svc_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_Lookup_Service/1/2/download` |
| VMware vSphere 7.0 vCenter Appliance Perfcharts | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_Perfcharts_V1R1_Manual_STIG/U_VMW_vSphere_7-0_vCA_Perfcharts_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2023-02-21 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_Perfcharts/1/1/download` |
| VMware vSphere 7.0 vCenter Appliance Photon OS | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_Photon_OS_V1R4_Manual_STIG/U_VMW_vSphere_7-0_vCA_Photon_OS_STIG_V1R4_Manual-xccdf.xml` | V1R4, 2024-12-16 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_Photon_OS/1/4/download` |
| VMware vSphere 7.0 vCenter Appliance PostgreSQL | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_PostgreSQL_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_PostgreSQL_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_PostgreSQL/1/2/download` |
| VMware vSphere 7.0 vCenter Appliance RhttpProxy | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_RhttpProxy_V1R1_Manual_STIG/U_VMW_vSphere_7-0_vCA_RhttpProxy_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2023-02-21 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_RhttpProxy/1/1/download` |
| VMware vSphere 7.0 vCenter Appliance STS | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_STS_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_STS_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_STS/1/2/download` |
| VMware vSphere 7.0 vCenter Appliance UI | `sources/vsphere70/U_VMW_vSphere_7-0_vCA_UI_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_UI_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-06-15 | cyber.trackr.live `/stig/VMware_vSphere_7.0_vCenter_Appliance_UI/1/2/download` |
| VMware vSphere 8.0 ESXi | `sources/vsphere80/U_VMW_vSphere_8-0-ESXi_V2R4_Manual_STIG/U_VMW_vSphere_8-0-ESXi_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2026-06-04 | cyber.trackr.live `/stig/VMware_vSphere_8.0_ESXi/2/4/download` |
| VMware vSphere 8.0 Virtual Machine | `sources/vsphere80/U_VMW_vSphere_8-0_Virtual_Machine_V2R1_Manual_STIG/U_VMW_vSphere_8-0_Virtual_Machine_STIG_V2R1_Manual-xccdf.xml` | V2R1, 2024-07-11 | cyber.trackr.live `/stig/VMware_vSphere_8.0_Virtual_Machine/2/1/download` |
| VMware vSphere 8.0 vCenter | `sources/vsphere80/U_VMW_vSphere_8-0_vCenter_V2R4_Manual_STIG/U_VMW_vSphere_8-0_vCenter_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter/2/4/download` |
| VMware vSphere 8.0 vCenter Appliance ESX Agent Manager (EAM) | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_EAM_V2R3_Manual_STIG/U_VMW_vSphere_8-0_VCSA_EAM_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_ESX_Agent_Manager_(EAM)/2/3/download` |
| VMware vSphere 8.0 vCenter Appliance Envoy | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Envoy_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Envoy_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-06-02 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Envoy/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance Lookup Service | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Lookup_Service/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance Management Interface (VAMI) | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_VAMI_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_VAMI_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Management_Interface_(VAMI)/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance Perfcharts | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Perfcharts_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Perfcharts_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Perfcharts/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance Photon OS 4.0 | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-06-02 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Photon_OS_4.0/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance PostgreSQL | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_PostgreSQL_V2R3_Manual_STIG/U_VMW_vSphere_8-0_VCSA_PostgreSQL_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2026-06-02 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_PostgreSQL/2/3/download` |
| VMware vSphere 8.0 vCenter Appliance Secure Token Service (STS) | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_STS_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_STS_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_Secure_Token_Service_(STS)/2/2/download` |
| VMware vSphere 8.0 vCenter Appliance User Interface (UI) | `sources/vsphere80/U_VMW_vSphere_8-0_VCSA_UI_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_UI_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2026-05-23 | cyber.trackr.live `/stig/VMware_vSphere_8.0_vCenter_Appliance_User_Interface_(UI)/2/2/download` |
| VMware vRealize Automation 7.x Application | `sources/vra7/VMware_Automation_7.x_Application/U_VMW_vRealize_Automation_7-x_Application_V1R2_STIG_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_Automation_7.x_Application/1/2/download` |
| VMware vRealize Automation 7.x HA Proxy | `sources/vra7/U_VMW_vRealize_Automation_7-x_HAProxy_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_HAProxy_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMW_vRealize_Automation_7.x_HA_Proxy/1/2/download` |
| VMware vRealize Automation 7.x Lighttpd | `sources/vra7/U_VMW_vRealize_Automation_7-x_Lighttpd_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_Lighttpd_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_vRealize_Automation_7.x_Lighttpd/1/2/download` |
| VMware vRealize Automation 7.x PostgreSQL | `sources/vra7/U_VMW_vRealize_Automation_7-x_PostgreSQL_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_PostgreSQL_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-20 | cyber.trackr.live `/stig/VMW_vRealize_Automation_7.x_PostgreSQL/1/2/download` |
| VMware vRealize Automation 7.x SLES | `sources/vra7/U_VMW_vRealize_Automation_7-x_SLES_V2R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_SLES_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2023-09-22 | cyber.trackr.live `/stig/VMware_vRealize_Automation_7.x_SLES/2/2/download` |
| VMware vRealize Automation 7.x tc Server | `sources/vra7/U_VMW_vRealize_Automation_7-x_tc_Server_V2R3_Manual_STIG/U_VMW_vRealize_Automation_7-x_tc_Server_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2023-10-03 | cyber.trackr.live `/stig/VMware_vRealize_Automation_7.x_tc_Server/2/3/download` |
| VMware vRealize Automation 7.x vAMI | `sources/vra7/VMware_vRealize_Automation_7.x_vAMI/U_VMW_vRealize_Automation_7-x_vAMI_V1R2_STIG_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_vRealize_Automation_7.x_vAMI/1/2/download` |
| VMware vRealize Automation 7.x vIDM | `sources/vra7/U_VMW_vRealize_Automation_7-x_vIDM_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_vIDM_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_vRealize_Automation_7.x_vIDM/1/2/download` |
| VMware vRealize Operations Manager 6.x Application | `sources/vrops6/VMware_vRealize_Operations_Manager_6.x_Application/U_VMW_vRealize_Ops_6-x_Application_V1R2_STIG_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_vRealize_Operations_Manager_6.x_Application/1/2/download` |
| VMware vRealize Operations Manager 6.x PostgreSQL | `sources/vrops6/U_VMW_vRealize_Ops_6-x_PostgreSQL_V1R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_PostgreSQL_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMW_vRealize_Operations_Manager_6.x_PostgreSQL/1/2/download` |
| VMware vRealize Operations Manager 6.x SLES | `sources/vrops6/U_VMW_vRealize_Ops_6-x_SLES_V2R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_SLES_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2023-09-21 | cyber.trackr.live `/stig/VMware_vRealize_Operations_Manager_6.x_SLES/2/2/download` |
| VMware vRealize Operations Manager 6.x tc Server | `sources/vrops6/U_VMW_vRealize_Ops_6-x_tc_Server_V1R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_tc_Server_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-12 | cyber.trackr.live `/stig/VMware_vRealize_Operations_Manager_6.x_tc_Server/1/2/download` |
| VMware vRealize Ops Mgr - Cassandra | `sources/vrops6/VMware_vRealize_Ops_Mgr_-_Cassandra/U_VMW_vRealize_Ops_Mgr_Cassandra_V1R2_Manual-xccdf.xml` | V1R2, 2023-09-26 | cyber.trackr.live `/stig/VMware_vRealize_Ops_Mgr_-_Cassandra/1/2/download` |
| VMware NSX 4.x Distributed Firewall | `sources/nsx/U_VMW_NSX_4-x_Distributed_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_Distributed_FW_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-13 | cyber.trackr.live `/stig/VMware_NSX_4.x_Distributed_Firewall/1/2/download` |
| VMware NSX 4.x Manager NDM | `sources/nsx/U_VMW_NSX_4-x_Manager_NDM_V1R2_Manual_STIG/U_VMW_NSX_4-x_Manager_NDM_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-13 | cyber.trackr.live `/stig/VMware_NSX_4.x_Manager_NDM/1/2/download` |
| VMware NSX 4.x Tier-0 Gateway Firewall | `sources/nsx/U_VMW_NSX_4-x_T-0_Gateway_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-0_Gateway_FW_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-13 | cyber.trackr.live `/stig/VMware_NSX_4.x_Tier-0_Gateway_Firewall/1/2/download` |
| VMware NSX 4.x Tier-0 Gateway Router | `sources/nsx/U_VMW_NSX_4-x_T-0_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-0_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-13 | cyber.trackr.live `/stig/VMware_NSX_4.x_Tier-0_Gateway_Router/1/2/download` |
| VMware NSX 4.x Tier-1 Gateway Firewall | `sources/nsx/U_VMW_NSX_4-x_T-1_Gateway_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-1_Gateway_FW_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-20 | cyber.trackr.live `/stig/VMware_NSX_4.x_Tier-1_Gateway_Firewall/1/2/download` |
| VMware NSX 4.x Tier-1 Gateway Router | `sources/nsx/U_VMW_NSX_4-x_T-1_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-1_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-12-20 | cyber.trackr.live `/stig/VMware_NSX_4.x_Tier-1_Gateway_Router/1/2/download` |
| VMware NSX-T Distributed Firewall | `sources/nsx/U_VMW_NSX-T_Distributed_FW_V1R3_Manual_STIG/U_VMW_NSX-T_Distributed_FW_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-23 | cyber.trackr.live `/stig/VMware_NSX-T_Distributed_Firewall/1/3/download` |
| VMware NSX-T Manager NDM | `sources/nsx/U_VMW_NSX-T_Manager_NDM_V1R3_Manual_STIG/U_VMW_NSX-T_Manager_NDM_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-22 | cyber.trackr.live `/stig/VMware_NSX-T_Manager_NDM/1/3/download` |
| VMware NSX-T SDN Controller | `sources/nsx/U_VMW_NSX-T_SDN_Controller_V1R1_Manual_STIG/U_VMW_NSX-T_SDN_Controller_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2022-03-09 | cyber.trackr.live `/stig/VMware_NSX-T_SDN_Controller/1/1/download` |
| VMware NSX-T Tier 1 Gateway Firewall | `sources/nsx/U_VMW_NSX-T_T-1_Gateway_FW_V1R3_Manual_STIG/U_VMW_NSX-T_T-1_Gateway_FW_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-22 | cyber.trackr.live `/stig/VMware_NSX-T_Tier_1_Gateway_Firewall/1/3/download` |
| VMware NSX-T Tier 1 Gateway RTR | `sources/nsx/U_VMW_NSX-T_T-1_Gateway_RTR_V1R1_Manual_STIG/U_VMW_NSX-T_T-1_Gateway_RTR_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2022-03-09 | cyber.trackr.live `/stig/VMware_NSX-T_Tier_1_Gateway_RTR/1/1/download` |
| VMware NSX-T Tier-0 Gateway Firewall | `sources/nsx/U_VMW_NSX-T_T-0_Gateway_FW_V1R3_Manual_STIG/U_VMW_NSX-T_T-0_Gateway_FW_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2023-06-22 | cyber.trackr.live `/stig/VMware_NSX-T_Tier-0_Gateway_Firewall/1/3/download` |
| VMware NSX-T Tier-0 Gateway RTR | `sources/nsx/U_VMW_NSX-T_T-0_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX-T_T-0_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2022-09-01 | cyber.trackr.live `/stig/VMware_NSX-T_Tier-0_Gateway_RTR/1/2/download` |
| VMware Horizon 7.13 Agent | `sources/horizon/U_VMW_Horizon_7-13_Agent_V1R1_Manual_STIG/U_VMW_Horizon_7-13_Agent_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2021-07-30 | cyber.trackr.live `/stig/VMware_Horizon_7.13_Agent/1/1/download` |
| VMware Horizon 7.13 Client | `sources/horizon/U_VMW_Horizon_7-13_Client_V1R1_Manual_STIG/U_VMW_Horizon_7-13_Client_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2021-07-22 | cyber.trackr.live `/stig/VMware_Horizon_7.13_Client/1/1/download` |
| VMware Horizon 7.13 Connection Server | `sources/horizon/U_VMW_Horizon_7-13_Connection_Server_V1R2_Manual_STIG/U_VMW_Horizon_7-13_Connection_Server_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2024-02-13 | cyber.trackr.live `/stig/VMware_Horizon_7.13_Connection_Server/1/2/download` |
| VMware Workspace ONE UEM | `sources/workspace_one/U_VMW_WS1_UEM_V2R2_Manual_STIG/U_VMW_WS1_UEM_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2024-06-06 | cyber.trackr.live `/stig/VMware_Workspace_ONE_UEM/2/2/download` |
| Citrix Virtual Apps and Desktop 7.x Delivery Controller | `sources/citrix/U_Citrix_VAD_7-x_Delivery_Controller_V1R3_Manual_STIG/U_Citrix_VAD_7-x_Delivery_Controller_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_Delivery_Controller/1/3/download` |
| Citrix Virtual Apps and Desktop 7.x License Server | `sources/citrix/U_Citrix_VAD_7-x_License_Server_V1R2_Manual_STIG/U_Citrix_VAD_7-x_License_Server_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_License_Server/1/2/download` |
| Citrix Virtual Apps and Desktop 7.x Linux Virtual Delivery Agent | `sources/citrix/U_Citrix_VAD_7-x_Linux_VDA_V1R2_Manual_STIG/U_Citrix_VAD_7-x_Linux_VDA_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_Linux_Virtual_Delivery_Agent/1/2/download` |
| Citrix Virtual Apps and Desktop 7.x StoreFront | `sources/citrix/U_Citrix_VAD_7-x_StoreFront_V1R2_Manual_STIG/U_Citrix_VAD_7-x_StoreFront_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_StoreFront/1/2/download` |
| Citrix Virtual Apps and Desktop 7.x Windows Virtual Delivery Agent | `sources/citrix/U_Citrix_VAD_7-x_Windows_VDA_V1R2_Manual_STIG/U_Citrix_VAD_7-x_Windows_VDA_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_Windows_Virtual_Delivery_Agent/1/2/download` |
| Citrix Virtual Apps and Desktop 7.x Workspace App | `sources/citrix/U_Citrix_VAD_7-x_Workspace_App_V1R3_Manual_STIG/U_Citrix_VAD_7-x_Workspace_App_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2025-06-23 | cyber.trackr.live `/stig/Citrix_Virtual_Apps_and_Desktop_7.x_Workspace_App/1/3/download` |
| Citrix XenDesktop 7.x Delivery Controller | `sources/citrix/U_Citrix_XenDesktop_7-x_Delivery_Controller_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_Delivery_Controller_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2025-06-23 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_Delivery_Controller/1/3/download` |
| Citrix XenDesktop 7.x License Server | `sources/citrix/U_Citrix_XenDesktop_7-x_License_Server_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_License_Server_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2019-12-12 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_License_Server/1/3/download` |
| Citrix XenDesktop 7.x Receiver | `sources/citrix/U_Citrix_XenDesktop_7-x_Receiver_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_Receiver_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_Receiver/1/2/download` |
| Citrix XenDesktop 7.x StoreFront | `sources/citrix/U_Citrix_XenDesktop_7-x_StoreFront_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2025-06-23 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_StoreFront/1/2/download` |
| Citrix XenDesktop 7.x Windows VDA | `sources/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R3_Manual-xccdf.xml` | V1R3, 2025-06-23 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_Windows_VDA/1/3/download` |
| Citrix XenDesktop 7.x Windows Virtual Delivery Agent | `sources/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R2_Manual-xccdf.xml` | V1R2, 2019-03-20 | cyber.trackr.live `/stig/Citrix_XenDesktop_7.x_Windows_Virtual_Delivery_Agent/1/2/download` |
| Citrix XenDesktop v7.x StoreFront | `sources/citrix/U_Citrix_XenDesktop_7-x_StoreFront_V1R1_Manual_STIG/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R1_Manual-xccdf.xml` | V1R1, 2018-08-28 | cyber.trackr.live `/stig/Citrix_XenDesktop_v7.x_StoreFront/1/1/download` |
| Microsoft Exchange 2013 Client Access Server | `sources/exchange/U_MS_Exchange_2013_CAS_V2R2_Manual_STIG/U_MS_Exchange_2013_CAS_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2024-06-10 | cyber.trackr.live `/stig/Exchange_2013_Client_Access_Server/2/2/download` |
| Microsoft Exchange 2013 Edge Transport Server | `sources/exchange/U_MS_Exchange_2013_Edge_V1R6_Manual_STIG/U_MS_Exchange_2013_Edge_Transport_Server_STIG_V1R6_Manual-xccdf.xml` | V1R6, 2024-06-10 | cyber.trackr.live `/stig/Exchange_2013_Edge_Transport_Server/1/6/download` |
| Microsoft Exchange 2013 Mailbox Server | `sources/exchange/U_MS_Exchange_2013_Mailbox_V2R3_Manual_STIG/U_MS_Exchange_2013_Mailbox_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2024-06-10 | cyber.trackr.live `/stig/Exchange_2013_Mailbox_Server/2/3/download` |
| Microsoft Exchange 2016 Edge Transport Server | `sources/exchange/U_MS_Exchange_2016_Edge_Transport_Server_V2R6_Manual_STIG/U_MS_Exchange_2016_Edge_Transport_Server_STIG_V2R6_Manual-xccdf.xml` | V2R6, 2024-12-06 | cyber.trackr.live `/stig/Exchange_2016_Edge_Transport_Server/2/6/download` |
| Microsoft Exchange 2016 Mailbox Server | `sources/exchange/U_MS_Exchange_2016_Mailbox_Server_V2R6_Manual_STIG/U_MS_Exchange_2016_Mailbox_Server_STIG_V2R6_Manual-xccdf.xml` | V2R6, 2023-12-18 | cyber.trackr.live `/stig/Exchange_2016_Mailbox_Server/2/6/download` |
| Microsoft Exchange 2019 Edge Server | `sources/exchange/U_MS_Exchange_2019_Edge_Server_V2R2_Manual_STIG/U_MS_Exchange_2019_Edge_Server_STIG_V2R2_Manual-xccdf.xml` | V2R2, 2024-12-06 | cyber.trackr.live `/stig/Exchange_2019_Edge_Server/2/2/download` |
| Microsoft Exchange 2019 Mailbox Server | `sources/exchange/U_MS_Exchange_2019_Mailbox_Server_V2R3_Manual_STIG/U_MS_Exchange_2019_Mailbox_Server_STIG_V2R3_Manual-xccdf.xml` | V2R3, 2025-05-14 | cyber.trackr.live `/stig/Exchange_2019_Mailbox_Server/2/3/download` |
| Microsoft Outlook 2013 | `sources/outlook/U_MS_Outlook_2013_V1R14_Manual_STIG/U_MS_Outlook_2013_STIG_V1R14_Manual-xccdf.xml` | V1R14, 2024-12-14 | cyber.trackr.live `/stig/Outlook_2013/1/14/download` |
| Microsoft Outlook 2016 | `sources/outlook/U_MS_Outlook_2016_V2R4_Manual_STIG/U_MS_Outlook_2016_STIG_V2R4_Manual-xccdf.xml` | V2R4, 2025-11-25 | cyber.trackr.live `/stig/Outlook_2016/2/4/download` |
| RHEL 7 (SCAP, automation) | `scap/U_RHEL_7_V3R2_STIG_SCAP_1-2_Benchmark.xml` | V3R2 (stale — RHEL7 SCAP not published after) | Archive.org `U_RHEL_7_V3R2_STIG_SCAP_1-2_Benchmark.zip` |
| RHEL 8 (SCAP, automation) | `scap/U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark.xml` | V2R2 (stale vs manual V2R8) | Archive.org `U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark.zip` |
| RHEL 9 (SCAP, automation) | `scap/U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.xml` | V2R5 (stale vs manual V2R9) | Archive.org `U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.zip` |

## Refreshing to a newer release

1. Fetch the XCCDF directly: `curl -sL -o x.xml https://cyber.trackr.live/stig/<Title>/<V>/<R>/download`
   (trackr retired `companion.zip` packages; the `/download` endpoint serves the original
   DISA-named `U_<ID>_STIG_V<V>R<R>_<KIND>-xccdf.xml` file. DISA's own portal still requires auth.)
   (DISA's own portal now requires auth; trackr mirrors the official packages and
   tracks current releases — check `https://cyber.trackr.live/stig` for the latest
   version/release of each STIG.)
2. Unzip into `sources/<platform>/`, update this table + README.
3. `make convert validate`
