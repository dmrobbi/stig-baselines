# stig-baselines todo

K8S/Container starter pack (owner "start pack of 5", 2026-10-06; options =
docs/K8S-CONTAINER-OPTIONS.md).

Ground rules: per-task exclusive file lists; shared-file edits (README, build.sh,
Makefile, sources/README) live in PACK-INT only; every acceptance ends in evidence;
commits = Dawn Robbins; pushes = github main + gitea mirror branch, hash-verified.

- [x] **PACK-1 · Kubernetes STIG V2R6 baseline** — [BUILDER][S] (OPT-K01) — d466e18
  - Owns: sources/kubernetes/.../U_Kubernetes_STIG_V2R6_Manual-xccdf.xml (new),
    baselines/kubernetes/U_Kubernetes_V2R6_Manual-baseline.ckl (new), todo.md
  - Acceptance: 92 rules all Not_Reviewed; xmllint schema-valid; source sha256
    0ca995078bd987a153f5a3238d0812b331883809d11547882bf0cedf0b110e50 in the message.
- [x] **PACK-2 · kube-bench runner wrapper** — [BUILDER][S] (OPT-K06) — 6db9048
  - Owns: baselines/kubernetes/run-kube-bench.sh (new)
  - Acceptance: pin v0.16.0, JSON+text evidence, OK-marker contract; bash -n + help green.
- [x] **PACK-3 · Kubernetes hardening kit** — [BUILDER][M] (OPT-K11)
  - Owns: baselines/kubernetes/{kubernetes-scan.sh, kubernetes-harden.sh, controls.yaml,
    ignore_list.yml, README.md} (all new)
  - Acceptance: scan = read-only (exit = fail count); harden = dry-run default + --apply
    root-gated + backups; fixture self-test green; EXCEPT-mechanism tested.
- [x] **PACK-4 · Docker host hardening kit** — [BUILDER][M] (OPT-K13)
  - Owns: baselines/docker/{docker-host-scan.sh, docker-host-harden.sh, controls.yaml,
    ignore_list.yml, README.md} (all new)
  - Acceptance: controls mapped to Container Platform SRG; read-only scan default;
    --apply gated; live self-test against this host's docker without breaking it.
- [x] **PACK-5 · Lab assessment assets** — [BUILDER][S] (OPT-K21)
  - Owns: baselines/kubernetes/{LAB-ASSESSMENT.md, kind-audit-job.yaml} (new)
  - Acceptance: the kind-gms runbook (kube-bench in-container job + the STIG manual-pass
    checklist); precondition documented (no cluster locus confirmed yet).
- [x] **PACK-INT · Integration** — [INTEGRATION][S]
  - Owns (SHARED): README.md, tools/build.sh (K8s line), Makefile (validate wildcard),
    sources/README.md (provenance), docs/K8S-CONTAINER-OPTIONS.md (ticks),
    docs/HARDENING-ROADMAP.md (Tier-1 k8s row in-repo)
  - Acceptance: `make all` green; lockstep hashes verified on both remotes.

## Guides → hardening waves (2026-10-07)

Source: `docs/guides/` (24 per-app guides + index; context in `docs/APP-HARDENING-CATALOG.md`). Order = blast radius: host baselines first, identity/user-visible surfaces last. Diffs land in this repo before touching hosts; every exception takes a one-line justification; per-wave owner go-ahead.

- [ ] **HARD-1 · Ubuntu OS baseline apply (thing1 + lab Ubuntu hosts)** — [S]
  - Owns: guides/01 + the host layer of guides/06 — sshd drop-in, sysctl, ufw/DOCKER-USER, auditd, fail2ban; no other hosts.
  - Acceptance: two-session lockout rule passed; `sshd -T`/sysctl/auditctl evidence recorded; docker + k3s still functional afterward.
- [x] **HARD-2 · Docker kit live pass (thing1; miner parked by owner)** — [S] — 3e791
  - Applied: daemon.json (log rotation + live-restore, restart done once,
    live-restore now holds containers through restarts), interface binds
    {127.0.0.1, 192.168.1.106, 100.94.13.51} on agent/API ports and
    {192.168.1.106, 100.94.13.51} on dashboard/mc (owner-approved), per-service
    logging blocks (compose overrides daemon defaults), security_opt
    no-new-privileges on wazuh x3 + mc; runner = EXCEPT row (HARD-5 owns it).
  - Rehearsal-caught re-encodes committed to the role repo: integration level
    10 (owner-decision), agentic_loop_mode=live (Phase 4), token via secrets
    file (fail-loud lookup), bridge MCP hosts (2026-09-27 decision).
  - Evidence: docs/hard-waves/HARD-2-APPLY.md; re-scan exit=0 (pass 6 / except 1).
- [ ] **HARD-3 · NGINX baseline (thing1 + mail-host vhosts)** — [S]
  - Owns: guides/13 — headers, TLS options, systemd override; forge-bundled nginx excluded (owned by HARD-5's gitlab.rb work).
  - Acceptance: curl header checks green per vhost; testssl.sh shows no TLS < 1.2; `nginx -t` clean; every vhost serves a round-trip.
- [ ] **HARD-4 · SOC stack pass (Wazuh + custom services)** — [M]
  - Owns: guides/16 + 12 (rotation-skill pass, binds, compose networks) + guides/17 systemd hardening for the soc-* units.
  - Acceptance: `filebeat test output` green post-rotation; soc MCP integrations still resolve (soc-manager-container flow); indexer/dashboard not WAN-bound; `systemd-analyze security` scores recorded per unit.
- [ ] **HARD-5 · Forge wave (GitLab + Runner)** — [M]
  - Owns: guides/15 — **token inventory FIRST**, then 2FA/PAT enforcement, runner isolation (docker executor), backup + secrets off-host drill.
  - Acceptance: token inventory table (name/scope/expiry/owner) committed before enforcement; 2FA + PAT expiry live; no shell-executor runner rooted on thing1; `gitlab:doctor:secrets` green.
- [ ] **HARD-6 · Mail + content wave (postfix/dovecot/rspamd + WordPress)** — [M]
  - Owns: guides/23 + 14 on the mail VPS; stsphotos WordPress hardening only if the owner decides to keep it.
  - Acceptance: internet.nl/mail-tester green on SPF/DKIM/DMARC/TLS; fail2ban jails firing on real attempts; wp checksums + perms verified; DMARC stays rua/quarantine until reports reviewed.