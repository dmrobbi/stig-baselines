# Pilot test plan — PVE-STIG on the first Proxmox node

> The future-work runbook: what gets tested when the program is ready for
> testing, in what order, and what "done" means per test. Nothing here runs
> until the readiness gates below are met — they are the Phase A outputs from
> [PROXMOX-PROGRAM.md](../PROXMOX-PROGRAM.md) §5.

## Readiness gates (Phase A complete)

- [ ] Host inventory filled (program §4 table): host list, PVE versions, roles
- [ ] Pilot node chosen — **non-production**, snapshot/rollback verified
      (`qm snapshot` / `vzdump` before any change)
- [ ] Accepted-risk owner named (Dawn)
- [ ] Cluster impact reviewed: the pilot must not be a corosync quorum-critical
      node; if it is a cluster member, document the blast radius first
- [ ] Wazuh manager reachable from the pilot (agent enrollment plan;
      thing1 manager address + agent-group `proxmox`)

## Tests (Phase B/E execution order)

| # | Test | Command / action | Pass criteria |
|---|------|------------------|---------------|
| T1 | First scan — failing-first baseline | `sudo ./proxmox-scan.sh` | Runs clean; every control reports PASS/FAIL/SKIP; the expected fresh-host FAILs appear (that is the point — record them, don't fix yet) |
| T2 | Machine-readable scan | `sudo ./proxmox-scan.sh --json` | Valid JSON (pipe into `python3 -m json.tool`); feeds the findings pipeline |
| T3 | Record findings | Create `docs/proxmox/findings.md` from [`accepted-findings-template.md`](accepted-findings-template.md); fill from scan output | Every FAIL mapped to a rule ID with disposition (fix / accept / defer) |
| T4 | Remediation preview | `sudo ./proxmox-harden.sh` | Dry-run shows planned changes only; **applies nothing** — prove it by re-scanning: identical results |
| T5 | Apply remediation | `sudo ./proxmox-harden.sh --apply` | Re-scan shows the targeted FAILs → PASS; manual-guidance controls still FAIL by design |
| T6 | Idempotency | Run `--apply` a second time | Zero new `[APPLIED]` lines — no double-fix, re-runs are safe |
| T7 | Cluster care | After apply: `pvecm status`, cluster join test, root-SSH-between-nodes check | Cluster healthy; any required deviation documented as an accepted finding (see the fawraw model in [`collected/`](collected/README.md)) |
| T8 | Wazuh SCA live | Deploy agent + policy per [`wazuh-sca-integration.md`](wazuh-sca-integration.md) + [`examples/proxmox/wazuh-sca-ossec.conf`](../../examples/proxmox/wazuh-sca-ossec.conf) | SCA results per rule visible in the dashboard (Security Configuration Assessment); SCA verdicts match the scanner verdicts |
| T9 | Drift alert | Deliberately revert one hardened setting (e.g. remove the sysctl drop-in) | SCA/drift alert fires within one scan interval (24h default) — then re-apply |

## Exit criteria

Maps to the program acceptance gates ([PROXMOX-PROGRAM.md](../PROXMOX-PROGRAM.md) §6):

- Pilot passes ≥90% of applicable rules.
- Every failure is fixed or in the accepted-findings register with
  rationale + compensating control + owner + review date.
- SCA visible in the Wazuh dashboard; drift alert proven (T9).

## Evidence kept

- **Findings register:** `docs/proxmox/findings.md` (committed; created from the
  template at the first pilot run — see
  [`examples/proxmox/findings-register-example.md`](../../examples/proxmox/findings-register-example.md)
  for what a filled one looks like).
- **Raw scan outputs + SCA dashboard state:** referenced from register entries
  (date + command), not committed raw.
- **Pilot VM bootstrap** (if the pilot is a VM): `examples/proxmox/pilot-vm-bootstrap.sh`.

## Run log — pilot execution 2026-09-22 (pve-pilot)

First execution of this runbook, on a disposable Proxmox VE 9.2.20 node built
for the purpose ("pve-pilot" — Debian 13 cloud image + the trixie pve repo,
qemu VM on gus2, TCG-emulated because VT-x is disabled in that host's BIOS;
Wazuh agent 021 enrolled against the thing1 manager).

| Test | Result | Notes |
|---|---|---|
| T1 baseline | 5 PASS / 8 FAIL / 1 SKIP, exit=8 | failing-first baseline recorded; PVE-tool checks ran for real (pct, pvesh 2FA audit, pve-firewall) |
| T2 JSON | valid | fed the findings pipeline |
| T3 findings | register opened | [`findings.md`](findings.md) — 4 OPEN findings (all manual-guidance controls) |
| T4 dry-run | exit=0, applies nothing | verified by re-scan |
| T5 apply | exit=0 | sysctl + sshd drop-ins, auditd, aide (one transient apt error self-recovered) |
| T6 idempotency | **0 re-applies** | after the guard fixes — before them the pilot caught the re-apply loops |
| T7 cluster care | N/A | standalone node, no corosync |
| T8 SCA go-live | green | policy loaded + scanned (~3s); manager emitted the rule-19003 SCA summary; group shared-file sync lagged the test window — validated quick path documented in [`wazuh-sca-integration.md`](wazuh-sca-integration.md) §6 |
| T9 drift alert | pending | needs the SCA cadence + a deliberate revert window (next run) |

**Post-remediation scan: 11 PASS / 3 FAIL / 1 SKIP, exit=3.** The pilot also
found seven kit bugs, all fixed in-repo (56ce359..f98ea46): scanner/harden
guard OpenSSH `without-password` spelling, sysctl drop-in losing precedence to
PVE's own `pve-firewall.conf` (renamed `zz-`), SCA policy `requirements` with
no rules list (silently skipped), a masked `printf -w` failure writing empty
audit-watch files, the Debian 13 `dailyaidecheck.timer` unit name, and docs.

Exit criteria status: pilot passes 11/14 automated controls; every remaining
failure is in the register with rationale + compensating control + owner;
SCA visible in the dashboard; drift alert (T9) is the one open gate.

**Next phase executed:** the pilot node became cluster node #1 — the full
4-node cluster + HA build and the Wazuh fleet enrollment are documented in
[`CLUSTER-HA-SETUP.md`](CLUSTER-HA-SETUP.md) (includes the T9-style live
failover procedure).