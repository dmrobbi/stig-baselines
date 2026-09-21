# Example: proxmox-scan.sh output

Captured 2026-09-21 with the fixed v0.1.0 scanner on **thing1** — a
non-Proxmox Ubuntu host, on purpose: it exercises the scanner end-to-end and
shows how missing PVE tooling becomes SKIPs (a real pilot node will FAIL more
controls — that is the failing-first baseline T1 wants).

## Human output (stderr; stdout stays clean)

```text
PVE-STIG baseline scan v0.1.0 — host thing1, Mon Sep 21 07:50:58 PM UTC 2026

FAIL PVE-STIG-0010  /tmp not a separate filesystem /tmp and / share /dev/mapper/ubuntu--vg-ubuntu--lv
FAIL PVE-STIG-0020  aide installed but timer inactive
PASS PVE-STIG-0030  auditd active
FAIL PVE-STIG-0040  permitrootlogin=? maxauthtries=?
PASS PVE-STIG-0050  minlen=14
PASS PVE-STIG-0060  enabled
FAIL PVE-STIG-0070  rp_filter=? syncookies=?
PASS PVE-STIG-0070b sync active
PASS PVE-STIG-0110  no libvirtd TCP listener
SKIP PVE-STIG-0120  pct tool missing
SKIP PVE-STIG-0210  pveproxy tool missing
SKIP PVE-STIG-0220  pveum tool missing
SKIP PVE-STIG-0280  pve-firewall tool missing
FAIL PVE-STIG-0290  wazuh-agent inactive

RESULTS: 5 pass, 5 fail, 4 skip
```

Notes on this run:

- Exit code = **number of failing controls** (5 here) — CI-friendly.
- PVE-STIG-0040 shows `permitrootlogin=?` because `sshd -T` evidence needs
  root; run the scanner as root on the pilot (`sudo ./proxmox-scan.sh`).
- The four SKIPs are the `pct` / `pveproxy` / `pveum` / `pve-firewall`
  checks — tools that exist on a PVE node, so a pilot run reports them
  instead of skipping.

## JSON output (`--json`; stdout)

```json
{
  "host": "thing1", "passes": 5, "fails": 5, "skips": 4, "results": [
    {"id":"PVE-STIG-0010","result":"FAIL","evidence":"/tmp not a separate filesystem /tmp and / share /dev/mapper/ubuntu--vg-ubuntu--lv"},
    {"id":"PVE-STIG-0020","result":"FAIL","evidence":"aide installed but timer inactive "},
    {"id":"PVE-STIG-0030","result":"PASS","evidence":"auditd active "},
    {"id":"PVE-STIG-0110","result":"PASS","evidence":"no libvirtd TCP listener "}
  ]
}
```

(truncated for readability; every control appears in the real output — the
`--json` stream pipes clean: notes go to stderr, only the JSON object goes to
stdout, so `... --json | python3 -m json.tool` validates directly)

The findings pipeline for the pilot: run `--json`, map each FAIL to a rule ID
in the register (test T3), then remediate (tests T4–T6).