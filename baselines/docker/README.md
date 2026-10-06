# baselines/docker — Docker host hardening kit

Container Platform SRG (V2R4, 2025-09-10) assessments for plain docker hosts.
The DISA Docker Enterprise STIG = legacy (product EOL); this kit keys controls to
the SRG's CTR groups and implements the honestly-checkable/file-fixable subset.

## Files

| File | Role |
|------|------|
| `controls.yaml` | control set with SRG anchors (daemon / live containers / policy rows) |
| `docker-host-scan.sh` | read-only assessment; exit code = FAIL count; `--json` output |
| `docker-host-harden.sh` | daemon.json fixer; dry-run default; `--apply` writes (with backup) |
| `ignore_list.yml` | accepted-risk exceptions (`<control-id>|<reason>|<expiry>`) = EXCEPT rows |

## Coverage notes (v0.1.0)

- Scans: socket perms/ownership, remote daemon API disabled (config + listener),
  log rotation limits, live-restore, userns-remap decision, privileged containers,
  host-network containers, no-new-privileges/SecurityOpt evidence.
- Hardens: daemon.json merge (log rotation + live-restore) with a `.stig-backup`;
  the script never restarts the daemon — print + restart is the operator's.
- Container-level remediations (caps, rootfs) = operator decisions per workload;
  the scanner reports them so the backlog is visible.

## Usage

```bash
sudo ./docker-host-scan.sh           # exit = fail count
sudo ./docker-host-scan.sh --json
sudo ./docker-host-harden.sh         # dry run
sudo ./docker-host-harden.sh --apply # daemon.json merge (backed up; docker restart on you)
```