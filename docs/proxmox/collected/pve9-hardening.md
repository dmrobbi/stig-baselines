![Status](https://img.shields.io/badge/status-experimental-orange)
![Warning](https://img.shields.io/badge/use%20at%20your%20own%20risk-important)
[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-PayPal-blue.svg)](https://www.paypal.me/ismailDjamhur)

# Proxmox VE 9.1 Hardening Tools

---

## ⚠️ DISCLAIMER (READ FIRST)

This project is provided **“as is”**, without warranty of any kind.  
Applying system hardening may introduce operational, security, or availability risks depending on the environment.

- Any risk, impact, or issue arising from the use of this tool is **the sole responsibility of the user**.
- The author **does not provide support**, guarantees, or remediation for issues caused by this tool.
- Users are expected to **review, understand, and validate** all changes applied to their systems.

**Always test in a development or non-production environment before applying to production systems.**

---

## Overview
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/pve-9-hard-overview.png)

This repository contains an automation tool for applying **minimal and graduated security hardening** to **Proxmox Virtual Environment (PVE) version 9.1**.

The hardening measures implemented by this tool are **influenced by**:
- Relevant recommendations from the **CIS Debian 13 Benchmark**
- **Official Proxmox documentation**

This tool intentionally applies **only a subset of controls** and **does not attempt to fully implement or enforce all controls** from the referenced standards.

---

## Tested Environment

This tool was tested in a **limited and constrained environment** with the following characteristics:

- Proxmox clusters were simulated using **VirtualBox**
- Each Virtual Machine represented **one Proxmox node**
- All cluster nodes were hosted on the **same physical laptop**
- No virtual machines were created under Proxmox clusters due to:
  - Lack of support for **nested virtualization** in the available environment

As a result:
- Cluster join functionality was observed only at the **node level**
- VM-level workloads were **not covered** by testing

Behavior may differ in real-world or production environments.

---

## Applied Modules and Hardening Scope

This tool implements a **graduated security hardening model** using configurable security levels.  
If no level is specified, the tool defaults to **Level 2 (Minimum compliance security)**.

> The term **“compliance”** is used only as a **relative indicator of hardening coverage**,  
> not as a claim of formal compliance, certification, or conformance.

---

### Security Levels

#### Level 1 — *Very Minimum Compliance Security*
Basic system hygiene and minimal network exposure reduction.

Modules:
- System update & upgrade
- Firewall (Proxmox VE / nftables)

---

#### Level 2 — *Minimum Compliance Security* (Default)
Baseline hardening while preserving normal operational behavior.

Modules:
- System update & upgrade  
- Firewall  
- SSH hardening  
- Password policy  
- Time synchronization (Chrony)  
- Auditd rules  

---

#### Level 3 — *Security Compliance Enough*
Adds kernel-level and filesystem-level hardening.

Modules:
- All Level 2 modules  
- Kernel and sysctl hardening  
- Disable unused filesystems  

---

#### Level 4 — *Security Compliance Near Fully*
Introduces automated security updates with higher operational impact.

Modules:
- All Level 3 modules  
- Unattended security updates  

---

#### Level 5 — *Security Compliance Fully*
Applies the most restrictive set of available modules.

Modules:
- All Level 4 modules  
- /dev/shm hardening  
- Package verification  

---

### Module Descriptions

- **System update & upgrade** – Applies package updates using the system package manager  
- **Firewall (PVE / nftables)** – Proxmox-aware firewall configuration  
- **SSH hardening** – Restricts SSH authentication and access behavior  
- **Password policy** – Applies password policies via PAM  
- **Time synchronization (Chrony)** – Ensures consistent system time  
- **Auditd rules** – Enables basic system auditing  
- **Kernel & sysctl hardening** – Applies selected kernel parameter tuning  
- **Disable unused filesystems** – Reduces kernel attack surface  
- **Unattended updates** – Automates selected security updates  
- **/dev/shm hardening** – Restricts shared memory usage  
- **Package verification** – Verifies package integrity  
- **AppArmor** – Available but not enabled by default  

---

## Regulatory and Standards Mapping

This project provides an **informational mapping** between implemented modules and:

- **CIS Debian 13 Benchmark**
- **ISO/IEC 27001 & ISO/IEC 27002:2022 (Annex A)**
- **Indonesia Personal Data Protection Law (UU PDP – Law No. 27 of 2022)**

> This mapping is provided **for reference only** and does **not** represent certification, compliance, or legal interpretation.

| Module | CIS Benchmark Reference | ISO/IEC 27002:2022 Reference | UU PDP Reference | Purpose | Risk if Not Implemented |
|--------|--------------------------|-------------------------------|------------------|---------|-------------------------|
| **system_update** | 1.2.2.1 Ensure updates, patches, and additional security software are installed | A.8.8 Management of technical vulnerabilities | Article 35 | Reduces exposure to known vulnerabilities through timely patching | Systems remain vulnerable to known exploits |
| **audit** | 6.2 System Auditing | A.8.15 Logging | Article 60 (Monitoring) | Records system activity for visibility and forensic analysis | Limited ability to detect or investigate incidents |
| **secure_shared_memory** | 1.1.2.2 Configure `/dev/shm` | A.8.9 Configuration management | Article 35 | Limits privilege escalation via shared memory | Potential execution of malicious code from shared memory |
| **ssh_hardening** | 5.1 Configure SSH Server | A.5.17 Authentication information | Article 39 | Restricts remote access methods and authentication mechanisms | Brute-force attacks and unauthorized access |
| **automatic_updates** | 1.2.2 Configure Package Updates | A.8.8 Management of technical vulnerabilities | Article 35 | Automates application of selected security updates | Delayed remediation of vulnerabilities |
| **password_policy** | 5.3.1 Configure PAM packages<br>5.4 User Accounts and Environment | A.5.17 Authentication information | Article 39 | Reduces risk of weak or reused credentials | Credential compromise and account abuse |
| **ntp** | 2.3.3 Configure Chrony | A.8.15 Logging<br>A.8.16 Monitoring activities | Articles 29 & 30 | Ensures accurate timestamps for logs and cluster operations | Log inconsistency, forensic gaps, cluster instability |
| **apparmor** | 1.3.1.3 Ensure all profiles are in enforce/complain mode | A.8.7 Protection against malware | Article 39 | Limits impact of compromised applications | Easier lateral movement and privilege abuse |
| **package_verification** | 1.2.1.1 Ensure GPG keys are configured | A.8.10 Information deletion<br>A.8.9 Configuration management | Article 35 | Helps ensure software integrity and supply-chain trust | Tampered packages go undetected |
| **filesystems** | 1.1.1.1 – 1.1.10 Disable unused filesystem modules | A.8.9 Configuration management | Article 35 | Reduces kernel attack surface | Exploitation via unused filesystem drivers |
| **firewall** | 4.1 Ensure single firewall utility<br>4.3 nftables configuration | A.8.20 Network security | Articles 39, 57, 58 | Controls and restricts network traffic | Unrestricted network exposure |
| **sysctl** | 3.3.1 – 3.3.11 Network kernel parameters | A.8.20 Network security | Articles 29 & 30 | Applies kernel-level network behavior tuning | Misconfiguration may impact connectivity or availability |


---

## Usage

### 1. Prepare SSH Key-Based Access (Required)

Before running this tool, **SSH key-based authentication must be configured** on all target Proxmox nodes.

If SSH keys are not yet available on the client system, generate them first:

```bash
ssh-keygen -t ed25519
```

Copy the public key to each Proxmox node:
```bash
ssh-copy-id root@<proxmox-node-ip>
```
⚠️ If SSH keys are not configured prior to running the tool, SSH access to the server may be lost, as password-based SSH login may be restricted during hardening.

### 2. Execute the Hardening Tool
   
Run the tool with appropriate privileges on the target Proxmox node:
```bash
chmod +x PVE9-Harden-FinalVersion-v1.sh
sudo ./PVE9-Harden-FinalVersion-v1.sh
```
### 3. Choose Security Level
You can select the desired security level by entering the corresponding number shown in the image below, then press Enter.
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/choose-seclevel.png)

once you choose the module would be executing as picture below:
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/executing-process.png)

### 4. Allows manual selection of hardening modules
You can also select the desired security module by entering the corresponding number shown in the image below, then press Enter.
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/module-manually.png)

### 5. Logs and completes the execution process
The output below is generated once the tool finishes executing all configured hardening steps.
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/log-output.png)
![Haqqsec Proxmox VE 9.1 Hardening – Interactive Menu and Disclaimer](assets/complete.png)

## Observed Behavior After Hardening (Test Environment Only)

Within the tested environment described above(Section "Tested Environment"), the following observations were made after applying the hardening measures:
- Proxmox cluster creation and node joining remained functional.
- SSH access to each cluster node remained functional when using SSH key authentication.
- Access to the Proxmox web interface remained functional using standard username and password authentication.
- These observations are not guarantees and apply only to the tested setup.

## Known Limitations

The following limitations are currently known and acknowledged:
- The tool has been tested only in a limited development environment using VirtualBox-based Proxmox cluster simulations. It has not been validated in production environments hosting guest virtual machines or containers.
- Nested virtualization was not available in the test environment. As a result, the impact of the applied hardening measures on workloads running inside Proxmox (VMs or containers) has not been evaluated.
- The applied hardening controls represent a minimal and selective subset influenced by CIS Debian 13 recommendations and official Proxmox documentation. The tool does not aim to provide full CIS benchmark coverage or compliance.
- Environment-specific configurations, custom networking setups, third-party integrations, and non-standard Proxmox deployments may require additional review and manual adjustments.
- Future Proxmox VE updates or configuration changes may affect the behavior of the applied hardening measures and are not automatically accounted for.

## ☕ Buy Me a Coffee

If this tool helped you, feel free to buy me a coffee ☕
via PayPal as a voluntary contribution.

- Suggested coffee: **USD 4 (optional)**
- Contributions are **optional**
- This does **not** imply support, warranty, or services

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-PayPal-blue.svg)](https://www.paypal.me/ismailDjamhur)

## License

This project is licensed under the Apache License, Version 2.0.

![License](https://img.shields.io/badge/license-Apache--2.0-blue)

