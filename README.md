# stig-baselines

DISA STIG baseline checklists (CKL) generated from the official DISA XCCDF sources,
ready to open in **DISA STIG Viewer 2.x / 3.x**. Each VULN carries the full rule
content (check, fix, SRG group, CCI refs) with status `Not_Reviewed` — the starting
point for assessment work.

**Repo:** https://github.com/dmrobbi/stig-baselines

**vSphere 6.7 assessment:** see
[docs/VSPHERE67-EVALUATION.md](docs/VSPHERE67-EVALUATION.md) —
getting the files, prepping ESXi/vCenter targets, the starter command
kit, and bulk-applying statuses from a CSV.

## Baselines

| Platform | STIG release | Benchmark date | Rules | CKL |
|----------|-------------|----------------|-------|-----|
| Red Hat Enterprise Linux 7 | V3R15 | 2024-07-24 | 244 | `baselines/rhel7/U_RHEL_7_STIG_V3R15_Manual-baseline.ckl` |
| Red Hat Enterprise Linux 8 | V2R8 | 2026-07-01 | 369 | `baselines/rhel8/U_RHEL_8_STIG_V2R8_Manual-baseline.ckl` |
| Red Hat Enterprise Linux 9 | V2R9 | 2026-07-01 | 445 | `baselines/rhel9/U_RHEL_9_STIG_V2R9_Manual-baseline.ckl` |
| Mozilla Firefox | V6R8 | 2026-07-01 | 33 | `baselines/firefox/` + a copy in each `baselines/rhel*/` |
| RHEL 7 + Firefox (merged) | V3R15 + V6R8 | — | 277 | `baselines/rhel7/U_RHEL_7_V3R15_plus_Firefox_V6R8-baseline.ckl` |
| RHEL 8 + Firefox (merged) | V2R8 + V6R8 | — | 402 | `baselines/rhel8/U_RHEL_8_V2R8_plus_Firefox_V6R8-baseline.ckl` |
| RHEL 9 + Firefox (merged) | V2R9 + V6R8 | — | 478 | `baselines/rhel9/U_RHEL_9_V2R9_plus_Firefox_V6R8-baseline.ckl` |
| VMware ESXi 6.7 | V1R3 | 2023-07-26 | 74 | `baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl` |
| VMware vCenter 6.7 | V1R4 | 2023-07-26 | 62 | `baselines/vsphere67/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-baseline.ckl` |
| Canonical Ubuntu 20.04 LTS | V2R4 | 2025-08-27 | 173 | `baselines/ubuntu20.04/Canonical_Ubuntu_20.04_LTS_STIG_V2R4_Manual-baseline.ckl` |
| Canonical Ubuntu 22.04 LTS | V2R9 | 2026-05-14 | 188 | `baselines/ubuntu22.04/Canonical_Ubuntu_22.04_LTS_STIG_V2R9_Manual-baseline.ckl` |
| Canonical Ubuntu 24.04 LTS | V1R6 | 2026-05-14 | 194 | `baselines/ubuntu24.04/Canonical_Ubuntu_24.04_LTS_STIG_V1R6_Manual-baseline.ckl` |
| Apple macOS 26 (Tahoe) | V1R3 | 2026-05-23 | 160 | `baselines/macos/Apple_macOS_26_Tahoe_STIG_V1R3_Manual-baseline.ckl` |
| Apple macOS 15 (Sequoia) | V1R6 | 2026-01-05 | 160 | `baselines/macos/Apple_macOS_15_Sequoia_STIG_V1R6_Manual-baseline.ckl` |
| Microsoft Windows 10 | V3R6 | 2026-01-05 | 267 | `baselines/windows/MS_Windows_10_STIG_V3R6_Manual-baseline.ckl` |
| Microsoft Windows 11 | V2R9 | 2026-08-10 | 257 | `baselines/windows/MS_Windows_11_STIG_V2R9_Manual-baseline.ckl` |
| Microsoft Windows Server 2019 | V3R9 | 2026-07-01 | 282 | `baselines/windows/MS_Windows_Server_2019_STIG_V3R9_Manual-baseline.ckl` |
| Microsoft Windows Server 2022 | V2R10 | 2026-08-10 | 278 | `baselines/windows/MS_Windows_Server_2022_STIG_V2R10_Manual-baseline.ckl` |

**Added 2026-10-05 — VMware family, Citrix, Microsoft email:**

| VMware vSphere 6.5 ESXi | V2R4 | 2023-06-16 | 74 | `baselines/vsphere65/U_VMW_vSphere_6-5_ESXi_STIG_V2R4_Manual-baseline.ckl` |
| VMware vSphere 6.5 Virtual Machine | V2R2 | 2023-06-15 | 40 | `baselines/vsphere65/U_VMW_vSphere_6-5_Virtual_Machine_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 6.5 vCenter Server for Windows | V2R3 | 2023-06-16 | 66 | `baselines/vsphere65/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_STIG_V2R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 EAM Tomcat | V1R4 | 2023-07-26 | 31 | `baselines/vsphere67/U_VMW_vSphere_6-7_EAM_Tomcat_STIG_V1R4_Manual-baseline.ckl` |
| VMware vSphere 6.7 Perfcharts Tomcat | V1R3 | 2023-06-16 | 32 | `baselines/vsphere67/U_VMW_vSphere_6-7_Perfcharts_Tomcat_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 Photon OS | V1R6 | 2023-06-16 | 124 | `baselines/vsphere67/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-baseline.ckl` |
| VMware vSphere 6.7 PostgreSQL | V1R2 | 2023-06-20 | 22 | `baselines/vsphere67/U_VMW_vSphere_6-7_PostgreSQL_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 6.7 RhttpProxy | V1R3 | 2023-06-20 | 10 | `baselines/vsphere67/U_VMW_vSphere_6-7_RhttpProxy_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 STS Tomcat | V1R3 | 2023-06-20 | 31 | `baselines/vsphere67/U_VMW_vSphere_6-7_STS_Tomcat_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 UI Tomcat | V1R3 | 2023-06-20 | 33 | `baselines/vsphere67/U_VMW_vSphere_6-7_UI_Tomcat_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 VAMI lighttpd | V1R3 | 2023-06-20 | 28 | `baselines/vsphere67/U_VMW_vSphere_6-7_VAMI-lighttpd_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 6.7 Virgo Client | V1R2 | 2023-06-20 | 30 | `baselines/vsphere67/U_VMW_vSphere_6-7_Virgo-Client_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 6.7 Virtual Machine | V1R3 | 2023-06-16 | 25 | `baselines/vsphere67/U_VMW_vSphere_6-7_Virtual_Machine_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 7.0 ESXi | V1R4 | 2025-02-11 | 75 | `baselines/vsphere70/U_VMW_vSphere_7-0_ESXi_STIG_V1R4_Manual-baseline.ckl` |
| VMware vSphere 7.0 VAMI | V1R2 | 2023-06-15 | 28 | `baselines/vsphere70/U_VMW_vSphere_7-0_VAMI_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 7.0 Virtual Machine | V1R4 | 2024-12-16 | 28 | `baselines/vsphere70/U_VMW_vSphere_7-0_Virtual_Machine_STIG_V1R4_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter | V1R3 | 2023-12-21 | 57 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCenter_STIG_V1R3_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance EAM | V1R2 | 2023-06-15 | 33 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_EAM_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance Lookup Service | V1R2 | 2023-06-15 | 31 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Lookup_Svc_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance Perfcharts | V1R1 | 2023-02-21 | 34 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Perfcharts_STIG_V1R1_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance Photon OS | V1R4 | 2024-12-16 | 113 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Photon_OS_STIG_V1R4_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance PostgreSQL | V1R2 | 2023-06-15 | 20 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_PostgreSQL_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance RhttpProxy | V1R1 | 2023-02-21 | 8 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_RhttpProxy_STIG_V1R1_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance STS | V1R2 | 2023-06-15 | 31 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_STS_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 7.0 vCenter Appliance UI | V1R2 | 2023-06-15 | 33 | `baselines/vsphere70/U_VMW_vSphere_7-0_vCA_UI_STIG_V1R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 ESXi | V2R4 | 2026-06-04 | 76 | `baselines/vsphere80/U_VMW_vSphere_8-0-ESXi_STIG_V2R4_Manual-baseline.ckl` |
| VMware vSphere 8.0 Virtual Machine | V2R1 | 2024-07-11 | 25 | `baselines/vsphere80/U_VMW_vSphere_8-0_Virtual_Machine_STIG_V2R1_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter | V2R4 | 2026-05-23 | 67 | `baselines/vsphere80/U_VMW_vSphere_8-0_vCenter_STIG_V2R4_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance ESX Agent Manager (EAM) | V2R3 | 2026-05-23 | 34 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_EAM_STIG_V2R3_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Envoy | V2R2 | 2026-06-02 | 5 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Envoy_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Lookup Service | V2R2 | 2026-05-23 | 34 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Management Interface (VAMI) | V2R2 | 2026-05-23 | 22 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_VAMI_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Perfcharts | V2R2 | 2026-05-23 | 33 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Perfcharts_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Photon OS 4.0 | V2R2 | 2026-06-02 | 107 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance PostgreSQL | V2R3 | 2026-06-02 | 18 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_PostgreSQL_STIG_V2R3_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance Secure Token Service (STS) | V2R2 | 2026-05-23 | 33 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_STS_STIG_V2R2_Manual-baseline.ckl` |
| VMware vSphere 8.0 vCenter Appliance User Interface (UI) | V2R2 | 2026-05-23 | 33 | `baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_UI_STIG_V2R2_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x Application | V1R2 | 2023-09-12 | 8 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_Application_V1R2_STIG_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x HA Proxy | V1R2 | 2023-09-12 | 55 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_HAProxy_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x Lighttpd | V1R2 | 2023-09-12 | 62 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_Lighttpd_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x PostgreSQL | V1R2 | 2023-09-20 | 69 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_PostgreSQL_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x SLES | V2R2 | 2023-09-22 | 209 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_SLES_STIG_V2R2_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x tc Server | V2R3 | 2023-10-03 | 156 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_tc_Server_STIG_V2R3_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x vAMI | V1R2 | 2023-09-12 | 44 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_vAMI_V1R2_STIG_Manual-baseline.ckl` |
| VMware vRealize Automation 7.x vIDM | V1R2 | 2023-09-12 | 8 | `baselines/vra7/U_VMW_vRealize_Automation_7-x_vIDM_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Operations Manager 6.x Application | V1R2 | 2023-09-12 | 6 | `baselines/vrops6/U_VMW_vRealize_Ops_6-x_Application_V1R2_STIG_Manual-baseline.ckl` |
| VMware vRealize Operations Manager 6.x PostgreSQL | V1R2 | 2023-09-12 | 69 | `baselines/vrops6/U_VMW_vRealize_Ops_6-x_PostgreSQL_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Operations Manager 6.x SLES | V2R2 | 2023-09-21 | 212 | `baselines/vrops6/U_VMW_vRealize_Ops_6-x_SLES_STIG_V2R2_Manual-baseline.ckl` |
| VMware vRealize Operations Manager 6.x tc Server | V1R2 | 2023-09-12 | 173 | `baselines/vrops6/U_VMW_vRealize_Ops_6-x_tc_Server_STIG_V1R2_Manual-baseline.ckl` |
| VMware vRealize Ops Mgr - Cassandra | V1R2 | 2023-09-26 | 57 | `baselines/vrops6/U_VMW_vRealize_Ops_Mgr_Cassandra_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Distributed Firewall | V1R2 | 2024-12-13 | 6 | `baselines/nsx/U_VMW_NSX_4-x_Distributed_FW_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Manager NDM | V1R2 | 2024-12-13 | 28 | `baselines/nsx/U_VMW_NSX_4-x_Manager_NDM_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Tier-0 Gateway Firewall | V1R2 | 2024-12-13 | 4 | `baselines/nsx/U_VMW_NSX_4-x_T-0_Gateway_FW_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Tier-0 Gateway Router | V1R2 | 2024-12-13 | 16 | `baselines/nsx/U_VMW_NSX_4-x_T-0_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Tier-1 Gateway Firewall | V1R2 | 2024-12-20 | 5 | `baselines/nsx/U_VMW_NSX_4-x_T-1_Gateway_FW_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX 4.x Tier-1 Gateway Router | V1R2 | 2024-12-20 | 4 | `baselines/nsx/U_VMW_NSX_4-x_T-1_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl` |
| VMware NSX-T Distributed Firewall | V1R3 | 2023-06-23 | 7 | `baselines/nsx/U_VMW_NSX-T_Distributed_FW_STIG_V1R3_Manual-baseline.ckl` |
| VMware NSX-T Manager NDM | V1R3 | 2023-06-22 | 23 | `baselines/nsx/U_VMW_NSX-T_Manager_NDM_STIG_V1R3_Manual-baseline.ckl` |
| VMware NSX-T SDN Controller | V1R1 | 2022-03-09 | 2 | `baselines/nsx/U_VMW_NSX-T_SDN_Controller_STIG_V1R1_Manual-baseline.ckl` |
| VMware NSX-T Tier 1 Gateway Firewall | V1R3 | 2023-06-22 | 9 | `baselines/nsx/U_VMW_NSX-T_T-1_Gateway_FW_STIG_V1R3_Manual-baseline.ckl` |
| VMware NSX-T Tier 1 Gateway RTR | V1R1 | 2022-03-09 | 4 | `baselines/nsx/U_VMW_NSX-T_T-1_Gateway_RTR_STIG_V1R1_Manual-baseline.ckl` |
| VMware NSX-T Tier-0 Gateway Firewall | V1R3 | 2023-06-22 | 7 | `baselines/nsx/U_VMW_NSX-T_T-0_Gateway_FW_STIG_V1R3_Manual-baseline.ckl` |
| VMware NSX-T Tier-0 Gateway RTR | V1R2 | 2022-09-01 | 16 | `baselines/nsx/U_VMW_NSX-T_T-0_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl` |
| VMware Horizon 7.13 Agent | V1R1 | 2021-07-30 | 15 | `baselines/horizon/U_VMW_Horizon_7-13_Agent_STIG_V1R1_Manual-baseline.ckl` |
| VMware Horizon 7.13 Client | V1R1 | 2021-07-22 | 7 | `baselines/horizon/U_VMW_Horizon_7-13_Client_STIG_V1R1_Manual-baseline.ckl` |
| VMware Horizon 7.13 Connection Server | V1R2 | 2024-02-13 | 35 | `baselines/horizon/U_VMW_Horizon_7-13_Connection_Server_STIG_V1R2_Manual-baseline.ckl` |
| VMware Workspace ONE UEM | V2R2 | 2024-06-06 | 20 | `baselines/workspace_one/U_VMW_WS1_UEM_STIG_V2R2_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x Delivery Controller | V1R3 | 2025-06-23 | 4 | `baselines/citrix/U_Citrix_VAD_7-x_Delivery_Controller_STIG_V1R3_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x License Server | V1R2 | 2025-06-23 | 8 | `baselines/citrix/U_Citrix_VAD_7-x_License_Server_STIG_V1R2_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x Linux Virtual Delivery Agent | V1R2 | 2025-06-23 | 7 | `baselines/citrix/U_Citrix_VAD_7-x_Linux_VDA_STIG_V1R2_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x StoreFront | V1R2 | 2025-06-23 | 3 | `baselines/citrix/U_Citrix_VAD_7-x_StoreFront_STIG_V1R2_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x Windows Virtual Delivery Agent | V1R2 | 2025-06-23 | 3 | `baselines/citrix/U_Citrix_VAD_7-x_Windows_VDA_STIG_V1R2_Manual-baseline.ckl` |
| Citrix Virtual Apps and Desktop 7.x Workspace App | V1R3 | 2025-06-23 | 2 | `baselines/citrix/U_Citrix_VAD_7-x_Workspace_App_STIG_V1R3_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x Delivery Controller | V1R3 | 2025-06-23 | 4 | `baselines/citrix/U_Citrix_XenDesktop_7-x_Delivery_Controller_STIG_V1R3_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x License Server | V1R3 | 2019-12-12 | 7 | `baselines/citrix/U_Citrix_XenDesktop_7-x_License_Server_STIG_V1R3_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x Receiver | V1R2 | 2025-06-23 | 3 | `baselines/citrix/U_Citrix_XenDesktop_7-x_Receiver_STIG_V1R2_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x StoreFront | V1R2 | 2025-06-23 | 2 | `baselines/citrix/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R2_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x Windows VDA | V1R3 | 2025-06-23 | 3 | `baselines/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R3_Manual-baseline.ckl` |
| Citrix XenDesktop 7.x Windows Virtual Delivery Agent | V1R2 | 2019-03-20 | 2 | `baselines/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R2_Manual-baseline.ckl` |
| Citrix XenDesktop v7.x StoreFront | V1R1 | 2018-08-28 | 1 | `baselines/citrix/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R1_Manual-baseline.ckl` |
| Microsoft Exchange 2013 Client Access Server | V2R2 | 2024-06-10 | 33 | `baselines/exchange/U_MS_Exchange_2013_CAS_STIG_V2R2_Manual-baseline.ckl` |
| Microsoft Exchange 2013 Edge Transport Server | V1R6 | 2024-06-10 | 63 | `baselines/exchange/U_MS_Exchange_2013_Edge_Transport_Server_STIG_V1R6_Manual-baseline.ckl` |
| Microsoft Exchange 2013 Mailbox Server | V2R3 | 2024-06-10 | 70 | `baselines/exchange/U_MS_Exchange_2013_Mailbox_STIG_V2R3_Manual-baseline.ckl` |
| Microsoft Exchange 2016 Edge Transport Server | V2R6 | 2024-12-06 | 68 | `baselines/exchange/U_MS_Exchange_2016_Edge_Transport_Server_STIG_V2R6_Manual-baseline.ckl` |
| Microsoft Exchange 2016 Mailbox Server | V2R6 | 2023-12-18 | 64 | `baselines/exchange/U_MS_Exchange_2016_Mailbox_Server_STIG_V2R6_Manual-baseline.ckl` |
| Microsoft Exchange 2019 Edge Server | V2R2 | 2024-12-06 | 68 | `baselines/exchange/U_MS_Exchange_2019_Edge_Server_STIG_V2R2_Manual-baseline.ckl` |
| Microsoft Exchange 2019 Mailbox Server | V2R3 | 2025-05-14 | 66 | `baselines/exchange/U_MS_Exchange_2019_Mailbox_Server_STIG_V2R3_Manual-baseline.ckl` |
| Microsoft Outlook 2013 | V1R14 | 2024-12-14 | 82 | `baselines/outlook/U_MS_Outlook_2013_STIG_V1R14_Manual-baseline.ckl` |
| Microsoft Outlook 2016 | V2R4 | 2025-11-25 | 64 | `baselines/outlook/U_MS_Outlook_2016_STIG_V2R4_Manual-baseline.ckl` |

All current-estate VMware STIGs are covered: vSphere 6.5/6.7/7.0/8.0 (incl. VCSA sub-component
STIGs — Photon OS, PostgreSQL, STS/UI/EAM/Perfcharts Tomcat, Lookup Service, Envoy, VAMI),
vRealize Automation 7.x, vRealize Operations Manager 6.x, NSX-T/NSX 4.x, Horizon 7.13,
Workspace ONE UEM. Citrix covers both DISA lines (Virtual Apps and Desktop 7.x + XenDesktop
7.x). Microsoft email covers Exchange 2013/2016/2019 + Outlook 2013/2016.

Deliberately excluded legacy relics (EOL products, DISA content frozen ≤2016): ESX 3.x,
ESXi 5.x/vCenter 5, vCenter/ESXi 6.0, NSX-v 2016-era, AirWatch v9, Exchange 2003/2010,
Outlook 2003/2007/2010, and the DoD-wide Email_Services_Policy (not a Microsoft product STIG).

Refreshed 2026-10-05 from cyber.trackr.live's per-revision `/download` endpoint
(all HEAD-200): Ubuntu 20.04 V2R4 / 22.04 V2R9 / 24.04 V1R6, macOS 26 V1R3. RHEL
7/8/9 baselines keep their committed SCAP provenance (see `sources/README.md`).

Merged CKLs contain two `<iSTIG>` blocks (RHEL OS STIG + Firefox STIG) in one
checklist — DISA STIG Viewer shows both via the STIG dropdown.

**Custom baselines:** where no DISA STIG exists, this repo also carries custom
STIG-style baselines — a machine-readable control set, a read-only scanner, an
idempotent fixer (dry-run by default), and a Wazuh SCA policy for continuous
audit. First up: **Proxmox VE** — artifacts in
[baselines/proxmox/](baselines/proxmox/README.md), program plan in
[docs/PROXMOX-PROGRAM.md](docs/PROXMOX-PROGRAM.md), pilot test kit in
[examples/proxmox/](examples/proxmox/README.md).

**Ansible:** see [examples/ansible/README.md](examples/ansible/README.md) —
the `stig_eval` role maps a mixed-OS cluster (RHEL family automated via
the committed SCAP benchmarks; Debian/Ubuntu, Windows, macOS baseline
handoffs) and produces populated, schema-valid CKLs per host.

## Layout

```
tools/xccdf2ckl.py       XCCDF -> CKL converter (stdlib-only Python 3)
baselines/<platform>/    generated baseline CKLs (commit these); custom baselines also carry
                         control sets + scanners + Wazuh SCA policies (baselines/README.md)
sources/<platform>/      official DISA XCCDFs the CKLs were generated from (committed)
sources/zips/            original DISA STIG zips (local only, not committed)
docs/                    program + evaluation docs (HARDENING-ROADMAP, SCANNING, VSPHERE67, PROXMOX-PROGRAM)
examples/                copy-paste artifacts (ansible stig_eval role, ssh/sudoers, proxmox pilot kit)
```

## Provenance

- RHEL 7/8/9: DISA Manual STIG XCCDFs from the current releases (obtained via
  cyber.trackr.live companion zips, which mirror the official DISA STIG packages).
- vSphere 6.7: official DISA bundle `U_VMW_vSphere_6-7_Y23M07_STIG.zip` (Internet
  Archive copy of dl.dod.cyber.mil) — contains ESXi V1R3 and vCenter V1R4 plus the
  appliance sub-component STIGs (Photon OS, PostgreSQL, Tomcat services, etc.).
- DISA notes: DISA's public download portal now gates zip downloads behind auth;
  archived/mirrored copies of the official packages were used and are committed here
  (STIG content is US Government public domain).

## Usage

Open a CKL in DISA STIG Viewer (File > Open), set ASSET fields, assess rules.
Regenerate after refreshing sources:

```bash
make baselines    # regenerate all CKLs from sources/
make validate   # xmllint well-formedness + count/status integrity
```

### Generating result-driven CKLs (OpenSCAP)

The converter can map oscap scan results onto statuses
(pass->NotAFinding, fail->Open, notapplicable->Not_Applicable, else Not_Reviewed):

```bash
oscap xccdf eval --profile stig --results results.xml sources/rhel9/.../xccdf.xml
python3 tools/xccdf2ckl.py <xccdf> <out.ckl> --results results.xml \
  --hostname myhost --ip 10.0.0.5 --fqdn myhost.example.com
```

## Caveats

- CKLs are XML checklists for STIG Viewer; they are not eMASS/POA&M inputs by themselves.
- `TARGET_KEY`/GUID asset fields are left blank (filled by STIG Viewer on save).
- Baseline statuses are all `Not_Reviewed` by design.