# Windows Clients & Servers — hardening guide

_Sources: our committed CKL baselines (`baselines/windows/`: Win10 V3R6, Win11 V2R9, Srv2019 V3R9, Srv2022 V2R10) + Microsoft Security Baselines + NSA Windows guidance. Tools: LGPO, secedit, hardeningkitty, LAPS, Defender._

## Policy application path (repeatable)

1. Export current state as the diff-parent: `sudo secedit /export /cfg pre-policy.inf`.
2. Apply the curated baseline via LGPO (download MS Security Baseline + DISA GPO backups, import with `LGPO.exe /g <backup-dir>`), or generate policy from the STIG text with STIG-Compliance-Assembler style tooling — the point is: policy files are versioned in this repo before they touch a host.
3. Track every non-default delta in a per-host exceptions file with a reason.

## Non-negotiables (all hosts)

- **LAPS** on every endpoint (local admin password randomly rotated); local admin accounts otherwise unused.
- **Defender real-time on, cloud MAPS, PUA protection on**, ASR rules deployed in audit mode first, then enforce; sample consent opt-in.
- SmartScreen on (block unknown apps/files), Controlled Folder Access where ransomware matters.
- **RDP: NLA required**, TLS only, port unchanged is fine but ACL by firewall group; admin clipboard/drive redirection off unless approved.
- **WinRM**: HTTPS-only or disabled; never plain HTTP listeners.
- **SMB signing required**, SMBv1 removed (`Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol`), LmCompatibilityLevel = NTLMv2 only.
- **LSA protection** (`RunAsPPL`) + Credential Guard on 11/2022-capable hardware; UAC: always prompt on secure desktop.
- **BitLocker** on, recovery keys escrowed in AD/AAD; TPM required.
- Windows Update: scheduled, deferrals configured; drivers via same channel.
- Screen lock 15 min max + password required; inactivity timeout via GPO.
- Audit policy: advanced auditing per STIG (logon failures, process creation with command line 4688+CLI).

## Servers additionally

- Internet-facing roles use dedicated servers; DCs follow DISA Domain Controller STIGs if/when we run AD.
- Local firewall: default deny inbound, explicit allow per role; RDP from mgmt CIDR only.
- Time: internal chrony/NTP source; timezone/sync drift alerts (SOC-relevant).

## Verify

```
LGPO.exe /parse /mosc   # or: secedit /analyze /db pre.sdb /cfg baseline.sdb
Get-MpComputerStatus ; Get-MpPreference | fl ASR*
gpresult /h report.html (policy application check)
hardeningkitty --repository? (github.com/scipag/HardeningKitty) run in findings mode
```

## Change risk

- ASR rules and Credential Guard break legit tooling (drivers, some VNC/RMM). Audit mode first, enforce after two weeks of clean telemetry.
- LAPS needs the module + permissions deployed fleet-wide before enabling on any host to avoid orphaned admin passwords.