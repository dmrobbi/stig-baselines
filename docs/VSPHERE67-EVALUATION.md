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
  Everything is committed — baseline CKLs, source XCCDFs, the original DISA
  bundles (`sources/zips/`, PDFs included), schema, tools — so the clone works
  **offline**; see [docs/SCANNING.md](docs/SCANNING.md) for the air-gapped notes.
- **DISA STIG Viewer 2.18** (Java 8+) from
  `public.cyber.mil/stigs/stig-viewing-tools/` (DoD auth) — any 2.x/3.x
  works; the committed CKLs are schema-valid per DISA Checklist v2.5. This is
  the one artifact NOT in the repo — side-load the installer.
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

If you collect results in a spreadsheet, apply them without the viewer
using `tools/csv2ckl.py` (statuses are enum-checked, so the output stays
schema-valid and opens in STIG Viewer for the final human pass):

```csv
rule,status,finding_details,comments
ESXI-67-000001,NotAFinding,Lockdown mode strict per hostd,"checked via client 2026-09-16"
ESXI-67-000020,Open,"SSH PermitRootLogin yes on host esxi02","POA&M: rotate to key-only"
```

(one row per rule; `rule` accepts the Rule_Ver, Rule_ID, or Vuln_Num;
unknown rules are warned and skipped)

```bash
python3 tools/csv2ckl.py \
  baselines/vsphere67/U_VMW_vSphere_6-7_ESXi_STIG_V1R3_Manual-baseline.ckl \
  results.csv \
  esxi01-eval.ckl
```

## 7. Refreshing later

DISA released newer vSphere 6.7 content after V1R3/V1R4 through the same
manual-STIG channel; when a newer zip lands (archive.org or with DoD auth
on cyber.mil), drop the XCCDF into `sources/vsphere67/`, extend
`tools/build.sh`, and `make baselines` — the schema gate keeps the output
STIG-Viewer-clean.