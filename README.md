# stig-baselines

DISA STIG baseline checklists (CKL) generated from the official DISA XCCDF sources,
ready to open in **DISA STIG Viewer 2.x / 3.x**. Each VULN carries the full rule
content (check, fix, SRG group, CCI refs) with status `Not_Reviewed` — the starting
point for assessment work.

## Baselines

| Platform | STIG release | Benchmark date | Rules | CKL |
|----------|-------------|----------------|-------|-----|
| Red Hat Enterprise Linux 7 | V3R15 | 2024-07-24 | 244 | `baselines/rhel7/` |
| Red Hat Enterprise Linux 8 | V2R8 | 2026-07-01 | 369 | `baselines/rhel8/` |
| Red Hat Enterprise Linux 9 | V2R9 | 2026-07-01 | 445 | `baselines/rhel9/` |
| VMware ESXi 6.7 | V1R3 | 2023-07-26 | 74 | `baselines/vsphere67/` |
| VMware vCenter 6.7 | V1R4 | 2023-07-26 | 62 | `baselines/vsphere67/` |

## Layout

```
tools/xccdf2ckl.py       XCCDF -> CKL converter (stdlib-only Python 3)
baselines/<platform>/    generated baseline CKLs (commit these)
sources/<platform>/      official DISA XCCDFs the CKLs were generated from (committed)
sources/zips/            original DISA STIG zips (local only, not committed)
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
make convert    # regenerate all CKLs from sources/
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