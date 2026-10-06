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

echo '== Ubuntu baselines (V2R4/V2R9/V1R6 from trackr /download 2026-10-05; older Wayback releases retained in sources/) =='
python3 tools/xccdf2ckl.py sources/ubuntu/20.04/U_CAN_Ubuntu_20-04_LTS_V2R4_Manual_STIG/U_CAN_Ubuntu_20-04_LTS_STIG_V2R4_Manual-xccdf.xml baselines/ubuntu20.04/Canonical_Ubuntu_20.04_LTS_STIG_V2R4_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/ubuntu/22.04/U_CAN_Ubuntu_22-04_LTS_V2R9_Manual_STIG/U_CAN_Ubuntu_22-04_LTS_STIG_V2R9_Manual-xccdf.xml baselines/ubuntu22.04/Canonical_Ubuntu_22.04_LTS_STIG_V2R9_Manual-baseline.ckl
python3 tools/xccdf2ckl.py sources/ubuntu/24.04/U_CAN_Ubuntu_24-04_LTS_V1R6_Manual_STIG/U_CAN_Ubuntu_24-04_LTS_STIG_V1R6_Manual-xccdf.xml baselines/ubuntu24.04/Canonical_Ubuntu_24.04_LTS_STIG_V1R6_Manual-baseline.ckl

echo '== macOS baselines =='
python3 tools/xccdf2ckl.py sources/macos/26-tahoe/U_Apple_macOS_26_V1R1_Manual_STIG/U_Apple_macOS_26_V1R1_STIG_Manual-xccdf.xml baselines/macos/Apple_macOS_26_Tahoe_STIG_V1R3_Manual-baseline.ckl --role Workstation
python3 tools/xccdf2ckl.py sources/macos/15-sequoia/U_Apple_macOS_15_V1R6_Manual_STIG/U_Apple_macOS_15_V1R6_STIG_Manual-xccdf.xml baselines/macos/Apple_macOS_15_Sequoia_STIG_V1R6_Manual-baseline.ckl --role Workstation

echo '== Windows baselines =='
python3 tools/xccdf2ckl.py sources/windows/win10/U_MS_Windows_10_V3R6_Manual_STIG/U_MS_Windows_10_STIG_V3R6_Manual-xccdf.xml baselines/windows/MS_Windows_10_STIG_V3R6_Manual-baseline.ckl --role Workstation
python3 tools/xccdf2ckl.py sources/windows/win11/U_MS_Windows_11_V2R9_Manual_STIG/U_MS_Windows_11_STIG_V2R9_Manual-xccdf.xml baselines/windows/MS_Windows_11_STIG_V2R9_Manual-baseline.ckl --role Workstation
python3 tools/xccdf2ckl.py sources/windows/server2019/U_MS_Windows_Server_2019_V3R9_Manual_STIG/U_MS_Windows_Server_2019_STIG_V3R9_Manual-xccdf.xml baselines/windows/MS_Windows_Server_2019_STIG_V3R9_Manual-baseline.ckl --role 'Member Server'
python3 tools/xccdf2ckl.py sources/windows/server2022/U_MS_Windows_Server_2022_V2R10_Manual_STIG/U_MS_Windows_Server_2022_STIG_V2R10_Manual-xccdf.xml baselines/windows/MS_Windows_Server_2022_STIG_V2R10_Manual-baseline.ckl --role 'Member Server'

echo '== VMware vSphere 6.5 =='
python3 tools/xccdf2ckl.py "sources/vsphere65/U_VMW_vSphere_6-5_ESXi_V2R4_Manual_STIG/U_VMW_vSphere_6-5_ESXi_STIG_V2R4_Manual-xccdf.xml" "baselines/vsphere65/U_VMW_vSphere_6-5_ESXi_STIG_V2R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere65/U_VMW_vSphere_6-5_Virtual_Machine_V2R2_Manual_STIG/U_VMW_vSphere_6-5_Virtual_Machine_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere65/U_VMW_vSphere_6-5_Virtual_Machine_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere65/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_V2R3_Manual_STIG/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_STIG_V2R3_Manual-xccdf.xml" "baselines/vsphere65/U_VMW_vSphere_6-5_vCenter_Server_for_Windows_STIG_V2R3_Manual-baseline.ckl"

echo '== VMware vSphere 6.7 sub-components =='
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_Perfcharts_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_Perfcharts_Tomcat_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_Perfcharts_Tomcat_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_Photon_OS_V1R6_Manual_STIG/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_PostgreSQL_V1R2_Manual_STIG/U_VMW_vSphere_6-7_PostgreSQL_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_PostgreSQL_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_RhttpProxy_V1R3_Manual_STIG/U_VMW_vSphere_6-7_RhttpProxy_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_RhttpProxy_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_STS_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_STS_Tomcat_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_STS_Tomcat_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_UI_Tomcat_V1R3_Manual_STIG/U_VMW_vSphere_6-7_UI_Tomcat_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_UI_Tomcat_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_VAMI-lighttpd_V1R3_Manual_STIG/U_VMW_vSphere_6-7_VAMI-lighttpd_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_VAMI-lighttpd_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_Virgo-Client_V1R2_Manual_STIG/U_VMW_vSphere_6-7_Virgo-Client_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_Virgo-Client_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_Virtual_Machine_V1R3_Manual_STIG/U_VMW_vSphere_6-7_Virtual_Machine_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_Virtual_Machine_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere67/U_VMW_vSphere_6-7_EAM_Tomcat_V1R4_Manual_STIG/VMware_vSphere_6.7_EAM_Tomcat_STIG_V1R4_Manual-xccdf.xml" "baselines/vsphere67/U_VMW_vSphere_6-7_EAM_Tomcat_STIG_V1R4_Manual-baseline.ckl"

echo '== VMware vSphere 7.0 =='
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_ESXi_V1R4_Manual_STIG/U_VMW_vSphere_7-0_ESXi_STIG_V1R4_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_ESXi_STIG_V1R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_VAMI_V1R2_Manual_STIG/U_VMW_vSphere_7-0_VAMI_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_VAMI_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_Virtual_Machine_V1R4_Manual_STIG/U_VMW_vSphere_7-0_Virtual_Machine_STIG_V1R4_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_Virtual_Machine_STIG_V1R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCenter_V1R3_Manual_STIG/U_VMW_vSphere_7-0_vCenter_STIG_V1R3_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCenter_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_EAM_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_EAM_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_EAM_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_Lookup_Svc_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_Lookup_Svc_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Lookup_Svc_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_Perfcharts_V1R1_Manual_STIG/U_VMW_vSphere_7-0_vCA_Perfcharts_STIG_V1R1_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Perfcharts_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_Photon_OS_V1R4_Manual_STIG/U_VMW_vSphere_7-0_vCA_Photon_OS_STIG_V1R4_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_Photon_OS_STIG_V1R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_PostgreSQL_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_PostgreSQL_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_PostgreSQL_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_RhttpProxy_V1R1_Manual_STIG/U_VMW_vSphere_7-0_vCA_RhttpProxy_STIG_V1R1_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_RhttpProxy_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_STS_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_STS_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_STS_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere70/U_VMW_vSphere_7-0_vCA_UI_V1R2_Manual_STIG/U_VMW_vSphere_7-0_vCA_UI_STIG_V1R2_Manual-xccdf.xml" "baselines/vsphere70/U_VMW_vSphere_7-0_vCA_UI_STIG_V1R2_Manual-baseline.ckl"

echo '== VMware vSphere 8.0 =='
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0-ESXi_V2R4_Manual_STIG/U_VMW_vSphere_8-0-ESXi_STIG_V2R4_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0-ESXi_STIG_V2R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_Virtual_Machine_V2R1_Manual_STIG/U_VMW_vSphere_8-0_Virtual_Machine_STIG_V2R1_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_Virtual_Machine_STIG_V2R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_vCenter_V2R4_Manual_STIG/U_VMW_vSphere_8-0_vCenter_STIG_V2R4_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_vCenter_STIG_V2R4_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_EAM_V2R3_Manual_STIG/U_VMW_vSphere_8-0_VCSA_EAM_STIG_V2R3_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_EAM_STIG_V2R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Envoy_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Envoy_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Envoy_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Lookup_Svc_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_VAMI_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_VAMI_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_VAMI_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Perfcharts_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Perfcharts_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Perfcharts_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_Photon_OS_4-0_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_PostgreSQL_V2R3_Manual_STIG/U_VMW_vSphere_8-0_VCSA_PostgreSQL_STIG_V2R3_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_PostgreSQL_STIG_V2R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_STS_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_STS_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_STS_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vsphere80/U_VMW_vSphere_8-0_VCSA_UI_V2R2_Manual_STIG/U_VMW_vSphere_8-0_VCSA_UI_STIG_V2R2_Manual-xccdf.xml" "baselines/vsphere80/U_VMW_vSphere_8-0_VCSA_UI_STIG_V2R2_Manual-baseline.ckl"

echo '== VMware vRealize Automation 7.x =='
python3 tools/xccdf2ckl.py "sources/vra7/VMware_Automation_7.x_Application/U_VMW_vRealize_Automation_7-x_Application_V1R2_STIG_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_Application_V1R2_STIG_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_HAProxy_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_HAProxy_STIG_V1R2_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_HAProxy_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_Lighttpd_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_Lighttpd_STIG_V1R2_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_Lighttpd_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_PostgreSQL_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_PostgreSQL_STIG_V1R2_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_PostgreSQL_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_SLES_V2R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_SLES_STIG_V2R2_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_SLES_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_tc_Server_V2R3_Manual_STIG/U_VMW_vRealize_Automation_7-x_tc_Server_STIG_V2R3_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_tc_Server_STIG_V2R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/VMware_vRealize_Automation_7.x_vAMI/U_VMW_vRealize_Automation_7-x_vAMI_V1R2_STIG_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_vAMI_V1R2_STIG_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vra7/U_VMW_vRealize_Automation_7-x_vIDM_V1R2_Manual_STIG/U_VMW_vRealize_Automation_7-x_vIDM_STIG_V1R2_Manual-xccdf.xml" "baselines/vra7/U_VMW_vRealize_Automation_7-x_vIDM_STIG_V1R2_Manual-baseline.ckl"

echo '== VMware vRealize Operations Manager 6.x =='
python3 tools/xccdf2ckl.py "sources/vrops6/VMware_vRealize_Operations_Manager_6.x_Application/U_VMW_vRealize_Ops_6-x_Application_V1R2_STIG_Manual-xccdf.xml" "baselines/vrops6/U_VMW_vRealize_Ops_6-x_Application_V1R2_STIG_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vrops6/U_VMW_vRealize_Ops_6-x_PostgreSQL_V1R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_PostgreSQL_STIG_V1R2_Manual-xccdf.xml" "baselines/vrops6/U_VMW_vRealize_Ops_6-x_PostgreSQL_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vrops6/U_VMW_vRealize_Ops_6-x_SLES_V2R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_SLES_STIG_V2R2_Manual-xccdf.xml" "baselines/vrops6/U_VMW_vRealize_Ops_6-x_SLES_STIG_V2R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vrops6/U_VMW_vRealize_Ops_6-x_tc_Server_V1R2_Manual_STIG/U_VMW_vRealize_Ops_6-x_tc_Server_STIG_V1R2_Manual-xccdf.xml" "baselines/vrops6/U_VMW_vRealize_Ops_6-x_tc_Server_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/vrops6/VMware_vRealize_Ops_Mgr_-_Cassandra/U_VMW_vRealize_Ops_Mgr_Cassandra_V1R2_Manual-xccdf.xml" "baselines/vrops6/U_VMW_vRealize_Ops_Mgr_Cassandra_V1R2_Manual-baseline.ckl"

echo '== VMware NSX =='
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_Distributed_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_Distributed_FW_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_Distributed_FW_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_Manager_NDM_V1R2_Manual_STIG/U_VMW_NSX_4-x_Manager_NDM_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_Manager_NDM_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_T-0_Gateway_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-0_Gateway_FW_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_T-0_Gateway_FW_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_T-0_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-0_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_T-0_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_T-1_Gateway_FW_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-1_Gateway_FW_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_T-1_Gateway_FW_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX_4-x_T-1_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX_4-x_T-1_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX_4-x_T-1_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_Distributed_FW_V1R3_Manual_STIG/U_VMW_NSX-T_Distributed_FW_STIG_V1R3_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_Distributed_FW_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_Manager_NDM_V1R3_Manual_STIG/U_VMW_NSX-T_Manager_NDM_STIG_V1R3_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_Manager_NDM_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_SDN_Controller_V1R1_Manual_STIG/U_VMW_NSX-T_SDN_Controller_STIG_V1R1_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_SDN_Controller_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_T-1_Gateway_FW_V1R3_Manual_STIG/U_VMW_NSX-T_T-1_Gateway_FW_STIG_V1R3_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_T-1_Gateway_FW_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_T-1_Gateway_RTR_V1R1_Manual_STIG/U_VMW_NSX-T_T-1_Gateway_RTR_STIG_V1R1_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_T-1_Gateway_RTR_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_T-0_Gateway_FW_V1R3_Manual_STIG/U_VMW_NSX-T_T-0_Gateway_FW_STIG_V1R3_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_T-0_Gateway_FW_STIG_V1R3_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/nsx/U_VMW_NSX-T_T-0_Gateway_RTR_V1R2_Manual_STIG/U_VMW_NSX-T_T-0_Gateway_RTR_STIG_V1R2_Manual-xccdf.xml" "baselines/nsx/U_VMW_NSX-T_T-0_Gateway_RTR_STIG_V1R2_Manual-baseline.ckl"

echo '== VMware Horizon 7.13 =='
python3 tools/xccdf2ckl.py "sources/horizon/U_VMW_Horizon_7-13_Agent_V1R1_Manual_STIG/U_VMW_Horizon_7-13_Agent_STIG_V1R1_Manual-xccdf.xml" "baselines/horizon/U_VMW_Horizon_7-13_Agent_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/horizon/U_VMW_Horizon_7-13_Client_V1R1_Manual_STIG/U_VMW_Horizon_7-13_Client_STIG_V1R1_Manual-xccdf.xml" "baselines/horizon/U_VMW_Horizon_7-13_Client_STIG_V1R1_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/horizon/U_VMW_Horizon_7-13_Connection_Server_V1R2_Manual_STIG/U_VMW_Horizon_7-13_Connection_Server_STIG_V1R2_Manual-xccdf.xml" "baselines/horizon/U_VMW_Horizon_7-13_Connection_Server_STIG_V1R2_Manual-baseline.ckl"

echo '== VMware Workspace ONE =='
python3 tools/xccdf2ckl.py "sources/workspace_one/U_VMW_WS1_UEM_V2R2_Manual_STIG/U_VMW_WS1_UEM_STIG_V2R2_Manual-xccdf.xml" "baselines/workspace_one/U_VMW_WS1_UEM_STIG_V2R2_Manual-baseline.ckl"

echo '== Citrix =='
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_Delivery_Controller_V1R3_Manual_STIG/U_Citrix_VAD_7-x_Delivery_Controller_STIG_V1R3_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_Delivery_Controller_STIG_V1R3_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_License_Server_V1R2_Manual_STIG/U_Citrix_VAD_7-x_License_Server_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_License_Server_STIG_V1R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_Linux_VDA_V1R2_Manual_STIG/U_Citrix_VAD_7-x_Linux_VDA_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_Linux_VDA_STIG_V1R2_Manual-baseline.ckl"
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_StoreFront_V1R2_Manual_STIG/U_Citrix_VAD_7-x_StoreFront_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_StoreFront_STIG_V1R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_Windows_VDA_V1R2_Manual_STIG/U_Citrix_VAD_7-x_Windows_VDA_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_Windows_VDA_STIG_V1R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_VAD_7-x_Workspace_App_V1R3_Manual_STIG/U_Citrix_VAD_7-x_Workspace_App_STIG_V1R3_Manual-xccdf.xml" "baselines/citrix/U_Citrix_VAD_7-x_Workspace_App_STIG_V1R3_Manual-baseline.ckl" --role 'Workstation'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_Delivery_Controller_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_Delivery_Controller_STIG_V1R3_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_Delivery_Controller_STIG_V1R3_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_License_Server_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_License_Server_STIG_V1R3_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_License_Server_STIG_V1R3_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_Receiver_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_Receiver_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_Receiver_STIG_V1R2_Manual-baseline.ckl" --role 'Workstation'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_StoreFront_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_V1R3_Manual_STIG/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R3_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R3_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_V1R2_Manual_STIG/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R2_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_Windows_VDA_STIG_V1R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/citrix/U_Citrix_XenDesktop_7-x_StoreFront_V1R1_Manual_STIG/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R1_Manual-xccdf.xml" "baselines/citrix/U_Citrix_XenDesktop_7-x_StoreFront_STIG_V1R1_Manual-baseline.ckl" --role 'Member Server'

echo '== Microsoft Exchange =='
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2013_CAS_V2R2_Manual_STIG/U_MS_Exchange_2013_CAS_STIG_V2R2_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2013_CAS_STIG_V2R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2013_Edge_V1R6_Manual_STIG/U_MS_Exchange_2013_Edge_Transport_Server_STIG_V1R6_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2013_Edge_Transport_Server_STIG_V1R6_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2013_Mailbox_V2R3_Manual_STIG/U_MS_Exchange_2013_Mailbox_STIG_V2R3_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2013_Mailbox_STIG_V2R3_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2016_Edge_Transport_Server_V2R6_Manual_STIG/U_MS_Exchange_2016_Edge_Transport_Server_STIG_V2R6_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2016_Edge_Transport_Server_STIG_V2R6_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2016_Mailbox_Server_V2R6_Manual_STIG/U_MS_Exchange_2016_Mailbox_Server_STIG_V2R6_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2016_Mailbox_Server_STIG_V2R6_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2019_Edge_Server_V2R2_Manual_STIG/U_MS_Exchange_2019_Edge_Server_STIG_V2R2_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2019_Edge_Server_STIG_V2R2_Manual-baseline.ckl" --role 'Member Server'
python3 tools/xccdf2ckl.py "sources/exchange/U_MS_Exchange_2019_Mailbox_Server_V2R3_Manual_STIG/U_MS_Exchange_2019_Mailbox_Server_STIG_V2R3_Manual-xccdf.xml" "baselines/exchange/U_MS_Exchange_2019_Mailbox_Server_STIG_V2R3_Manual-baseline.ckl" --role 'Member Server'

echo '== Microsoft Outlook =='
python3 tools/xccdf2ckl.py "sources/outlook/U_MS_Outlook_2013_V1R14_Manual_STIG/U_MS_Outlook_2013_STIG_V1R14_Manual-xccdf.xml" "baselines/outlook/U_MS_Outlook_2013_STIG_V1R14_Manual-baseline.ckl" --role 'Workstation'
python3 tools/xccdf2ckl.py "sources/outlook/U_MS_Outlook_2016_V2R4_Manual_STIG/U_MS_Outlook_2016_STIG_V2R4_Manual-xccdf.xml" "baselines/outlook/U_MS_Outlook_2016_STIG_V2R4_Manual-baseline.ckl" --role 'Workstation'

echo '== Firefox baseline (canonical) =='
python3 tools/xccdf2ckl.py "$FF" "baselines/firefox/$FF_CKL"

echo '== Firefox copies per RHEL baseline =='
for r in rhel7 rhel8 rhel9; do cp "baselines/firefox/$FF_CKL" "baselines/$r/$FF_CKL"; done

echo '== merged RHEL + Firefox checklists =='
python3 tools/merge_ckl.py baselines/rhel7/U_RHEL_7_STIG_V3R15_Manual-baseline.ckl  "baselines/rhel7/$FF_CKL" baselines/rhel7/U_RHEL_7_V3R15_plus_Firefox_V6R8-baseline.ckl
python3 tools/merge_ckl.py baselines/rhel8/U_RHEL_8_STIG_V2R8_Manual-baseline.ckl    "baselines/rhel8/$FF_CKL" baselines/rhel8/U_RHEL_8_V2R8_plus_Firefox_V6R8-baseline.ckl
python3 tools/merge_ckl.py baselines/rhel9/U_RHEL_9_STIG_V2R9_Manual-baseline.ckl    "baselines/rhel9/$FF_CKL" baselines/rhel9/U_RHEL_9_V2R9_plus_Firefox_V6R8-baseline.ckl

echo '== Kubernetes baseline =='
python3 tools/xccdf2ckl.py sources/kubernetes/U_Kubernetes_V2R6_Manual_STIG/U_Kubernetes_STIG_V2R6_Manual-xccdf.xml baselines/kubernetes/U_Kubernetes_V2R6_Manual-baseline.ckl

echo '== validate (DISA Checklist schema v2.5) =='
SCHEMA=tools/schema/U_Checklist_Schema_V2.xsd
for f in baselines/*/*.ckl; do xmllint --noout --schema "$SCHEMA" "$f" || exit 1; done
echo 'ALL OK (schema-valid)'