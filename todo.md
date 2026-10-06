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
- [ ] **PACK-5 · Lab assessment assets** — [BUILDER][S] (OPT-K21)
  - Owns: baselines/kubernetes/{LAB-ASSESSMENT.md, kind-audit-job.yaml} (new)
  - Acceptance: the kind-gms runbook (kube-bench in-container job + the STIG manual-pass
    checklist); precondition documented (no cluster locus confirmed yet).
- [ ] **PACK-INT · Integration** — [INTEGRATION][S]
  - Owns (SHARED): README.md, tools/build.sh (K8s line), Makefile (validate wildcard),
    sources/README.md (provenance), docs/K8S-CONTAINER-OPTIONS.md (ticks),
    docs/HARDENING-ROADMAP.md (Tier-1 k8s row in-repo)
  - Acceptance: `make all` green; lockstep hashes verified on both remotes.