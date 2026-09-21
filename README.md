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
| Canonical Ubuntu 20.04 LTS | V2R2† | 2025-04-02 | 164 | `baselines/ubuntu20.04/Canonical_Ubuntu_20.04_LTS_STIG_V2R2_Manual-baseline.ckl` |
| Canonical Ubuntu 22.04 LTS | V2R4† | 2025-04-02 | 179 | `baselines/ubuntu22.04/Canonical_Ubuntu_22.04_LTS_STIG_V2R4_Manual-baseline.ckl` |
| Canonical Ubuntu 24.04 LTS | V1R1† | 2025-01-28 | 188 | `baselines/ubuntu24.04/Canonical_Ubuntu_24.04_LTS_STIG_V1R1_Manual-baseline.ckl` |
| Apple macOS 26 (Tahoe) | V1R1† | 2025-09-11 | 160 | `baselines/macos/Apple_macOS_26_Tahoe_STIG_V1R1_Manual-baseline.ckl` |
| Apple macOS 15 (Sequoia) | V1R6 | 2026-01-05 | 160 | `baselines/macos/Apple_macOS_15_Sequoia_STIG_V1R6_Manual-baseline.ckl` |
| Microsoft Windows 10 | V3R6 | 2026-01-05 | 267 | `baselines/windows/MS_Windows_10_STIG_V3R6_Manual-baseline.ckl` |
| Microsoft Windows 11 | V2R9 | 2026-08-10 | 257 | `baselines/windows/MS_Windows_11_STIG_V2R9_Manual-baseline.ckl` |
| Microsoft Windows Server 2019 | V3R9 | 2026-07-01 | 282 | `baselines/windows/MS_Windows_Server_2019_STIG_V3R9_Manual-baseline.ckl` |
| Microsoft Windows Server 2022 | V2R10 | 2026-08-10 | 278 | `baselines/windows/MS_Windows_Server_2022_STIG_V2R10_Manual-baseline.ckl` |

† latest release per trackr is newer (Ubuntu 20.04 V2R4 / 22.04 V2R9 / 24.04 V1R6,
macOS 26 V1R3) — DISA's portal now gates downloads and those exact zips are not yet in
any public archive; refresh when you have cyber.mil auth (see `sources/README.md`).

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