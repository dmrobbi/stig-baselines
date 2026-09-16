# Evaluating the VMware vSphere 6.7 STIGs and producing checklists

How to take the committed ESXi 6.7 / vCenter 6.7 baseline checklists,
run the assessment against your environment, and turn them into
evaluated (per-rule status) CKLs. The vSphere 6.7 STIGs are **manual
only** — DISA publishes no SCAP datastream for them, so every rule is
checked by hand (or PowerCLI) and the result recorded in the checklist.

Covered here: the two core STIGs

| Baseline CKL | STIG | Rules |
|---|---|---|
| `baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl` | ESXi 6.7 V1R3 (2023-07-26) | 74 |
| `baselines/vsphere67/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-baseline.ckl` | vCenter 6.7 V1R4 (2023-07-26) | 62 |

The vSphere 6.7 family also ships component STIGs (Photon OS, PostgreSQL,
the Tomcat services, VAMI/lighttpd, RhttpProxy, Virgo, EAM, Virtual
Machine). Their XCCDFs are committed under `sources/vsphere67/`; see
[Generating the baselines](#generating-the-baselines) for the one-liner
to turn any of them into a CKL.

## 1. What you need

- This repo (`stig-baselines`) — clone it:
  ```bash
  git clone http://idm.wezzel.com:8080/crab-meat-repos/stig-baselines.git
  # or: git clone https://github.com/dmrobbi/stig-baselines.git
  ```
- **DISA STIG Viewer 2.18** (Java 8+) from
  `public.cyber.mil/stigs/stig-viewing-tools/` (DoD auth) — any 2.x/3.x
  works; the committed CKLs are schema-valid per DISA Checklist v2.5.
- **Targets**: your ESXi 6.7 host(s) and the vCenter 6.7 instance
  (identify the form factor: VCSA appliance or Windows vCenter —
  several vCenter rules differ between the two).
- Credentials: ESXi root (for SSH), vCenter administrator, VCSA root /
  Windows admin as applicable. The `examples/ssh/` and `examples/sudoers/`
  files are the Linux-scan equivalents and are **not** needed for vSphere.

## 2. Get the files

The baseline CKLs are already committed — no generation is required to
start assessing:

```
baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl
baselines/vsphere67/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-baseline.ckl
```

The official DISA XCCDF sources they were generated from live under
`sources/vsphere67/` (obtained from an archive.org copy of DISA's
`U_VMW_vSphere_6-7_Y23M07_STIG.zip`; `sources/README.md` has the
provenance table). The zips/PDFs themselves stay local-only.

## 3. Generating the baselines (optional / refresh)

Everything is idempotent; schema validation runs at the end:

```bash
make baselines        # regenerate every CKL from sources/ (needs xmllint)
make validate         # xmllint --schema tools/schema/U_Checklist_Schema_V2.xsd
```

Single checklist (any vSphere 6.7 component STIG — swap paths):

```bash
python3 tools/xccdf2ckl.py \
  sources/vsphere67/U_VMW_vSphere_6-7_Photon_OS_V1R6_Manual_STIG/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-xccdf.xml \
  baselines/vsphere67/U_VMW_vSphere_6-7_Photon_OS_STIG_V1R6_Manual-baseline.ckl
```

Want ESXi + vCenter (+ Virtual Machine STIG) in ONE checklist for the
whole environment? Merge them — STIG Viewer shows each STIG via the STIG
dropdown:

```bash
python3 tools/merge_ckl.py \
  baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl \
  baselines/vsphere67/U_VMW_vSphere_6-7_vCenter_STIG_V1R4_Manual-baseline.ckl \
  vsphere67-combined.ckl
```

## 4. Prep the targets

**ESXi (per host):** enable SSH (vSphere Client → Host → Configure →
Services → TSM-SSH → Start), then `ssh root@<esxi>`. Expect the shell to
time out per the STIG settings — re-enable as needed. Where a check
targets the DCUI/vSphere Client instead of SSH, use the client UI
(Configure pane) as the rule's check text describes.

**vCenter:** VCSA — `ssh root@<vcsa>`, then `shell.set --enabled true`
and `shell` for the Photon OS shell; VAMI lives at `https://<vcsa>:5480`.
Windows vCenter — work on the Windows host (services, registry per the
check text).

**PowerCLI alternative** for host-level checks (great for a fleet):

```powershell
Connect-VIServer <vcenter>
$h = Get-VMHost <esxi-host>
$h.ExtensionData.Config.LockdownMode                 # lockdown state
Get-AdvancedSetting -Entity $h | ? Name -eq '/UserVars/ESXiShellTimeOut'
Get-VMHostFirewallException -VMHost $h | ? Enabled   # firewall rulesets
```

## 5. Run the assessment

Open the baseline in STIG Viewer (File → Open), then:

1. **ASSET tab**: fill Host Name / IP / FQDN, pick ROLE
   (Workstation / Member Server / None) — save once so the viewer assigns
   the target key.
2. **Per VULN**: the embedded `Check_Content` is the authoritative check —
   run it on the target, then set `STATUS` and write what you saw into
   `FINDING_DETAILS` (evidence: command output snippet or where the
   setting lives) and `COMMENTS` (who/when/how verified). Statuses:
   `NotAFinding` = compliant · `Open` = finding · `Not_Applicable` =
   documented exception · `Not_Reviewed` = not yet checked.
3. `File → Save As` per target — e.g.
   `esxi01.vsphere.example.com_ESXi_67_V1R3-eval.ckl`. Keep evaluated
   CKLs out of this repo (they are environment evidence): store them with
   the environment's POA&M/eMASS artifacts.

Starter command kit for the common ESXi families (the full check text for
every rule is in the CKL — these are just the workhorses):

```bash
esxcli system version get                       # patch level (V1R3 baseline)
esxcli system settings advanced list -d | less  # advanced options (most GPO rules)
esxcli system settings advanced list -o /UserVars/ESXiShellTimeOut
esxcli system permission list                   # local accounts / roles
esxcli network firewall ruleset list            # firewall rulesets
esxcli system syslog config get                 # remote syslog
esxcli hardware clock get                       # time sync sanity
cat /etc/ssh/sshd_config                        # SSH settings block
```

For vCenter appliance rules the same pattern applies with Photon/Linux
tooling (`sshd_config`, `pam.d` files, package lists) — always follow the
rule's own check text; the CKL carries it verbatim.

## 6. Bulk-updating statuses (scripted path)

If you collect results in a spreadsheet, apply them without the viewer:

```csv
rule,status,finding_details,comments
U_ESXi-67-000010,NotAFinding,Lockdown mode strict per hostd,"checked via client 2026-09-16"
U_ESXi-67-000020,Open,"SSH PermitRootLogin yes on host esxi02","POA&M: rotate to key-only"
```

(one row per rule; `rule` accepts the Rule_Ver, Rule_ID, or Vuln_Num)

```python
#!/usr/bin/env python3
"""csv2ckl.py IN.ckl results.csv OUT.ckl — apply statuses to a baseline."""
import csv, sys
import xml.etree.ElementTree as ET

ckl, csv_path, out = sys.argv[1], sys.argv[2], sys.argv[3]
VALID = {"Open", "NotAFinding", "Not_Applicable", "Not_Reviewed"}
rows = list(csv.DictReader(open(csv_path, newline="")))
t = ET.parse(ckl)
vulns = t.getroot().findall("./STIGS/iSTIG/VULN")
hit = 0
for v in vulns:
    fields = {d.findtext("VULN_ATTRIBUTE"): d.findtext("ATTRIBUTE_DATA")
              for d in v.findall("STIG_DATA")}
    keys = {fields.get("Rule_Ver"), fields.get("Rule_ID"),
            fields.get("Vuln_Num")}
    for r in rows:
        if r["rule"].strip() in keys:
            st = r["status"].strip()
            if st not in VALID:
                sys.exit(f"invalid status {st!r} for {key}")
            v.find("STATUS").text = st
            v.find("FINDING_DETAILS").text = r.get("finding_details") or ""
            v.find("COMMENTS").text = r.get("comments") or ""
            hit += 1
ET.indent(t, space="  ")
t.write(out, encoding="UTF-8", xml_declaration=True)
print(f"updated {hit}/{len(rows)} rules across {len(vulns)} VULNs")
```

The output stays schema-valid (statuses are enum-checked) and opens in
STIG Viewer for the final human pass.

## 7. Refreshing later

DISA released newer vSphere 6.7 content after V1R3/V1R4 through the same
manual-STIG channel; when a newer zip lands (archive.org or with DoD auth
on cyber.mil), drop the XCCDF into `sources/vsphere67/`, extend
`tools/build.sh`, and `make baselines` — the schema gate keeps the output
STIG-Viewer-clean.