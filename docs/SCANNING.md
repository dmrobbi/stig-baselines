# How to run these STIG baselines

Three ways to work each checklist: manual assessment, OpenSCAP automation, or
Tenable/Nessus. All paths end with the same artifact: a CKL with per-rule statuses
that opens in DISA STIG Viewer 3.x.

## Offline / air-gapped use

Everything the workflow needs is committed: baseline CKLs, source XCCDFs, the
original DISA bundles with PDFs (`sources/zips/`), the SCAP benchmark XMLs
(`sources/scap/`), the CKL schema (`tools/schema/`), and all tools. Clone the
repo (from the IDM GitLab over the LAN) and no internet access is required —
the only external items are the **STIG Viewer installer** (2.x/3.x, DoD-gated
download — side-load it) and a Java runtime. Regeneration and validation work
fully offline: `make baselines && make validate`.

| CKL | STIG | Automated check source |
|-----|------|------------------------|
| `baselines/rhel{7,8,9}/U_RHEL_*-baseline.ckl` | OS STIG | `sources/scap/` datastreams (see version skew note) |
| `baselines/firefox/U_MOZ_Firefox_STIG_V6R8_Manual-baseline.ckl` | Firefox STIG | none — manual only |
| `baselines/rhel*/U_*_plus_Firefox_V6R8-baseline.ckl` | OS + Firefox merged | OS part via datastream; Firefox manual |
| `baselines/vsphere67/*.ckl` | ESXi 6.7 / vCenter 6.7 | none — manual only; workflow in [docs/VSPHERE67-EVALUATION.md](docs/VSPHERE67-EVALUATION.md) |

## Option A — Manual assessment (STIG Viewer)

1. Install [DISA STIG Viewer 3.x](https://public.cyber.mil/stigs/srg-stig-tools/)
   (Java 17+ required).
2. Open the baseline CKL for your platform (File > Open > *.ckl).
3. Fill in the ASSET tab (hostname/IP/FQDN) and save — STIG Viewer assigns the
   asset key on first save.
4. Work each VULN: read the check, run the commands by hand, set STATUS
   (`Open` / `NotAFinding` / `Not_Applicable` / `Not_Reviewed`), add
   FINDING_DETAILS + COMMENTS.
5. Export the CKL back (File > Save). That file is your evidence artifact for
   eMASS/POA&M.

Merged CKLs (RHEL + Firefox) show both STIGs in one checklist — use the STIG
dropdown in the viewer.

## Option B — OpenSCAP automated scan (RHEL)

Committed SCAP datastreams (see `sources/scap/`):

| Host OS | Datastream | Release | Profile (full) |
|---------|-----------|---------|----------------|
| RHEL 7 | `sources/scap/U_RHEL_7_V3R2_STIG_SCAP_1-2_Benchmark.xml` | V3R2 (2021) | `xccdf_mil.disa.stig_profile_MAC-2_Public` (pick per your mission category) |
| RHEL 8 | `sources/scap/U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark.xml` | V2R2 | same family |
| RHEL 9 | `sources/scap/U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.xml` | V2R5 | same family |

**Version skew warning:** the archived datastreams lag the latest manual STIGs
(RHEL 9 datastream is V2R5, manual baseline is V2R9). Rules added after those
releases scan as `Not_Reviewed` in the converted CKL — fetch the current SCAP
benchmark from DISA (auth required on cyber.mil) or re-check
`https://cyber.trackr.live/scap` for updates and drop the newer XML into
`sources/scap/` to eliminate the skew.

On the RHEL host (oscap 1.3.x):

```bash
# full STIG (MAC-2 Public shown; pick the profile matching your environment)
sudo oscap xccdf eval \
  --profile xccdf_mil.disa.stig_profile_MAC-2_Public \
  --results results.xml \
  --report report.html \
  sources/scap/U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.xml
```

Remote scan over SSH from a scanner box:

```bash
oscap-ssh root@target 22 xccdf eval \
  --profile xccdf_mil.disa.stig_profile_MAC-2_Public \
  --results results.xml --report report.html \
  sources/scap/U_RHEL_9_V2R5_STIG_SCAP_1-3_Benchmark.xml
```

Turn results into a populated CKL (statuses auto-mapped: pass→NotAFinding,
fail→Open, notapplicable→Not_Applicable):

```bash
python3 tools/xccdf2ckl.py \
  sources/rhel9/U_RHEL_9_V2R9_Manual_STIG/U_RHEL_9_STIG_V2R9_Manual-xccdf.xml \
  rhel9-scan.ckl \
  --results results.xml \
  --hostname web01 --ip 10.0.0.25 --fqdn web.example.com
```

Then finish the manual-only rules (those the datastream can't check) in STIG
Viewer — they stay `Not_Reviewed`.

Remediation (careful — test on a disposable VM first):
`sudo oscap xccdf eval --remediate --profile MAC-2_Public <datastream>`, or use
the [ansible-lockdown RHEL9-STIG](https://github.com/ansible-lockdown/RHEL9-STIG)
role which tracks the same STIG.

## Option C — Tenable (SecurityCenter / Nessus / Tenable.io)

Tenable ships audit files that map 1:1 to DISA STIG releases:

1. Download the matching audit from <https://www.tenable.com/audits> — match the
   STIG release exactly, e.g.
   `DISA_STIG_Red_Hat_Enterprise_Linux_9_v2r9` for the RHEL 9 V2R9 baseline.
   (Same series exists for RHEL 7/8 and Mozilla Firefox.)
2. **SecurityCenter/Tenable.io:** Resources > Audit Files > upload the `.audit`
   file. **Nessus:** policy > Compliance/audits > add the file.
3. Run a **credentialed** scan (SSH root or sudo for full coverage; Firefox STIG
   checks need the target user's Firefox profile visible — usually done as the
   desktop user).
4. Export the scan as `.nessus` (v2) from SecurityCenter/Nessus.
5. In DISA STIG Viewer 3.x: open the matching baseline CKL > Checklist >
   **Import ACAS/Nessus results** — results map onto the VULN list by rule ID;
   verify the mapping and finish the manual rules by hand.

Notes:

- STIG Viewer's ACAS import works against the same STIG version as the audit
  file — keep release numbers aligned end to end.
- ESXi 6.7 / vCenter 6.7 have no SCAP automation; assess those CKLs manually
  (Option A) or via Tenable's VMware audits if your stack supports them.
- Rule IDs (`SV-...r..._rule`) are stable across manual XCCDF and audit/datastream
  content of the *same* release — that's what makes the result mapping work.

## Regenerating baselines

```bash
make baselines   # runs tools/build.sh — regenerates every CKL from sources/
make validate    # xmllint all CKLs
```

To roll to a newer DISA release, drop the new XCCDF into `sources/<platform>/`
(see `sources/README.md` for download URLs), bump the filenames in
`tools/build.sh`, run `make baselines`, and commit.