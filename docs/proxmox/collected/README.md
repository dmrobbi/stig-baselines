# Collected reference material

Fetched copies of the community guides this program builds on
([`../references.md`](../references.md) has the full source inventory). Nothing
here is auto-trusted — each source is cited where a rule or phase uses it, so
every control in [`layered-controls.md`](../layered-controls.md) traces to its
origin.

| File | Upstream | License | Notes |
|------|----------|---------|-------|
| `homesecexplorer-hardening-guide.md` | [HomeSecExplorer/Proxmox-Hardening-Guide](https://github.com/HomeSecExplorer/Proxmox-Hardening-Guide) | CC BY 4.0 | PVE 9/8 + PBS 4/3 hardening guides; upstream ships per-release docs (`docs/pve9-hardening-guide.md` etc.) — fetch those when Phase C starts |
| `fawraw-pve8-hardening.md` | [fawraw/proxmox-host-hardening](https://github.com/fawraw/proxmox-host-hardening) | MIT | CIS-aligned PVE 8 playbook; models the accepted-findings workflow used by this program |
| `pve9-hardening.md` | [abualialfatih23/PVE-9-Hardening](https://github.com/abualialfatih23/PVE-9-Hardening) | per upstream | PVE 9.1 tooling (CIS Debian 13 + Proxmox docs); author marks it **experimental** — use with care |

Collected 2026-09-21. Kept as offline reference (the fleet runs air-gapped
sometimes); re-fetch when Phase C starts and diff for updates. If upstreams
are missing attribution here, that is a bug — fix it.