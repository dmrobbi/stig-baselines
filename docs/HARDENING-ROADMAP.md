# Hardening roadmap — STIG candidates for our stack

Companion to the baselines already in this repo. Order = suggested build order.
Automation column: what actually runs the checks (see docs/SCANNING.md for workflows).

## Done (in repo)

| Platform | STIG / release | Status |
|----------|---------------|--------|
| RHEL 7/8/9 hosts | V3R15 / V2R8 / V2R9 | baselines + oscap datastreams committed |
| Mozilla Firefox | V6R8 | baseline + merged CKLs |
| ESXi 6.7 / vCenter 6.7 | V1R3 / V1R4 (final Y23M07) | baselines committed |

## Tier 1 — direct hits for our stack

| # | Target | STIG | Latest ver | Automation path |
|---|--------|------|-----------|-----------------|
| 1 | Ubuntu hosts (trooper2, miner, VMs) | Canonical Ubuntu 20.04 / 22.04 / 24.04 LTS STIG | current | Manual CKL + Tenable DISA-Ubuntu audit file; no DISA SCAP for Ubuntu (SSG CIS profile is the oscap fallback) |
| 2 | Kubernetes (bare-metal k8s, kind-gms) | Kubernetes STIG | V2R6 | Manual CKL + **kube-bench** (CIS-mapped) + Tenable K8s audit; continuous via Gatekeeper/OPA |
| 3 | Docker containers (miner: market, trade, auth, kafka, minio; GitLab bundled) | Container Platform SRG (Docker Enterprise STIG is legacy) | SRG | Custom benchmark from SRG via our pipeline; Docker bench for CIS mapping |
| 4 | PostgreSQL (Patroni cluster, GitLab bundled PG) | PostgreSQL STIG (9.x-era baseline) / Crunchy Data PostgreSQL STIG V3R2 | — | Manual + Tenable PG audit |
| 5 | Custom apps (FORGE-C2, market, trade, auth, satellite, cicerone) | **Application Security and Development STIG V6R4** (2025-09-09, 286 findings) | V6R4 | Manual review + Tenable web app checks; maps findings to 800-53 |
| 6 | Guest VMs (wezzelOS, mock-gms, real-test-gms) | VMware vSphere 6.7 **Virtual Machine** STIG | V1R3 (already in `sources/vsphere67/`) | Just generate the CKL — XCCDF already committed |
| 7 | Browsers on demo/workstation VMs | Google Chrome Current Windows STIG | V2R11 | Manual + Tenable audit |
| 8 | DNS (if we run BIND on idm) | BIND 9.x STIG | current | Manual + Tenable audit |

## Tier 2 — GitLab (idm.wezzel.com)

No official DISA GitLab STIG exists. Three-layer approach:

**Layer 1 — GitLab application hardening (custom benchmark):**
- Base: GitLab official Hardening Recommendations (docs.gitlab.com/security/hardening —
  general / application / OS / configuration pages + NIST 800-53 reference mapping)
- Build a **custom GitLab STIG benchmark** via our xccdf2ckl pipeline (this is the
  custom-benchmark phase of the original plan): SRG-APP controls mapped to gitlab.rb +
  Admin Area settings. Core items:
  - 2FA required (users + admins), WebAuthn, session lifetime, PAT expiry enforcement
  - Open sign-up disabled, email confirmation, admin mode
  - Protected branches, MR approval rules, push rules, commit signing
  - Runner isolation: trooper2 runner is a **shell executor** (root-equivalent) — move to
    docker executor / isolated runner host
  - CI security: secret detection, dependency + container scanning, masked vars, secure files
  - Audit events streaming/retention, rate limits, import/export restrictions
  - TLS min 1.2, nginx HSTS/CSP headers in gitlab.rb, registry + package registry perms
  - Encrypted backups + off-host copy, backup/restore drill
- Automation: Tenable web-app/Nessus checks are weak here — mostly manual CKL + config-as-code
  (gitlab.rb under version control in this repo = drift detection)

**Layer 2 — bundled components:**
- Nginx (bundled) → Web Server SRG (no product STIG) → custom checklist
- PostgreSQL (bundled) → PostgreSQL STIG
- Redis (bundled) → no STIG; Redis hardening guide + SRG
- Gitaly/containers → Container Platform SRG

**Layer 3 — OS + runtime:**
- Host OS STIG (Ubuntu per Tier 1), fail2ban/ssh hardening (devsec roles map to controls),
  GitLab SSH (port 22) vs server SSH separation (already aliased in ~/.ssh/config)

## Tier 3 — no product STIG → SRG/custom benchmarks

| Target | Route |
|--------|-------|
| Apache Kafka (FORGE topics, TLS/SASL, listener auth) | General Application SRG → custom benchmark (xccdf2ckl) |
| Prometheus | General Application SRG → custom |
| MinIO / object storage | General Application SRG + encryption CCIs → custom |
| auth.stsgym.com service | API SRG / Application SRG → custom |
| Prometheus/Grafana | App SRG (+ Grafana official hardening docs); no DISA product STIG |
| Tenable SecurityCenter (if exposed) | hardening per vendor guide; check DISA catalog for SCC STIG |
| Tailscale/WireGuard | OS-level controls + vendor hardening; VPN SRG legacy |

## Remediation tooling (pairs with baselines)

- **ansible-lockdown** RHEL7/8/9-STIG roles (STIG-mapped, evidence for remediation)
- **devsec** os-hardening / ssh-hardening roles (Ubuntu hosts)
- **kube-bench** for K8s, **oscap --remediate** (RHEL, maintenance windows only)
- DoD Iron Bank hardened images where we rebuild containers

## Suggested build order (stig-baselines repo)

1. Ubuntu LTS STIG baselines for trooper2/miner (same pipeline, ~30 min)
2. VMware Virtual Machine STIG baseline (XCCDF already here, ~10 min)
3. Kubernetes V2R6 baseline + kube-bench runner script
4. Custom **GitLab benchmark** (first product of the custom-STIG pipeline — gitlab.rb
   checks become OVAL/manual rules, statuses flow into CKLs like everything else)
5. PostgreSQL STIG baseline
6. App Sec Dev V6R4 checklist per custom app
7. GitLab CI: xmllint + count validation on push; nightly oscap/kube-bench runs publishing CKLs