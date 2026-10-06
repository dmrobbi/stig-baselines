# stig-baselines todo

## K8S/Container starter pack (owner "start pack of 5", 2026-10-06; options = docs/K8S-CONTAINER-OPTIONS.md)

Ground rules: per-task exclusive file lists; shared-file edits (README, build.sh,
Makefile, sources/README) live in PACK-INT only; every acceptance ends in evidence;
commits = Dawn Robbins; pushes = github main + gitea mirror branch, hash-verified.

### PACK-1 · Kubernetes STIG V2R6 baseline — [BUILDER][S] (OPT-K01)
- **Owns:** `sources/kubernetes/U_Kubernetes_V2R6_Manual_STIG/U_Kubernetes_STIG_V2R6_Manual-xccdf.xml` (new),
  `baselines/kubernetes/U_Kubernetes_V2R6_Manual-baseline.ckl` (new), `todo.md` (this file)
- **Acceptance:** 92 rules, all Not_Reviewed; xmllint schema-valid (DISA Checklist v2.5);
  source sha256 recorded in the commit message; fetched via the repo's own trackr tooling.
- **Depends:** none.

### PACK-2 · kube-bench runner wrapper — [BUILDER][S] (OPT-K06)
- **Owns:** `baselines/kubernetes/run-kube-bench.sh` (new)
- **Acceptance:** pinned release + versioned benchmark argument; JSON + text output into
  a results dir; exit-code contract with an OK marker; bash -n clean; --help prints usage.
- **Depends:** PACK-1 (the baseline family exists).

### PACK-3 · Kubernetes hardening kit — [BUILDER][M] (OPT-K11)
- **Owns:** `baselines/kubernetes/kubernetes-scan.sh`, `baselines/kubernetes/kubernetes-harden.sh`,
  `baselines/kubernetes/controls.yaml`, `baselines/kubernetes/ignore_list.yml`, `baselines/kubernetes/README.md` (all new)
- **Acceptance:** control-ids STIG-V-IDs from V2R6; scan = read-only (exit = fail-count);
  harden = --apply + a dry-run default; scanner self-test green on a kind cluster; the
  ignore-list mechanism = the proxmox pattern.
- **Depends:** PACK-1.

### PACK-4 · Docker host hardening kit — [BUILDER][M] (OPT-K13)
- **Owns:** `baselines/docker/docker-host-scan.sh`, `baselines/docker/docker-host-harden.sh`,
  `baselines/docker/controls.yaml`, `baselines/docker/ignore_list.yml`, `baselines/docker/README.md` (all new)
- **Acceptance:** controls mapped to the Container Platform SRG (CTR-* SRG ids); read-only
  scan default; --apply gated; live self-test against this host's docker without breaking it.
- **Depends:** PACK-1 (the family lands; the SRG choice documented).

### PACK-5 · Lab assessment assets — [BUILDER][S] (OPT-K21)
- **Owns:** `baselines/kubernetes/LAB-ASSESSMENT.md` + `baselines/kubernetes/kind-audit-job.yaml` (new)
- **Acceptance:** a runbook for the bare-metal kind lab (kind-gms) assessment: kube-bench
  in-container job + the K8s STIG manual-pass checklist; runnable the moment a cluster
  locus confirms (no cluster located as of 2026-10-06 — precondition documented).
- **Depends:** PACK-2.

### PACK-INT · Integration — [INTEGRATION][S]
- **Owns (SHARED):** `README.md` (baseline-table row + the k8s family), `tools/build.sh`
  (the K8s line), `Makefile` (validate wildcard), `sources/README.md` (provenance row),
  `docs/K8S-CONTAINER-OPTIONS.md` (tick K01/K06/K11/K13/K21), `docs/HARDENING-ROADMAP.md`
  (Tier-1 Kubernetes row = in-repo).
- **Acceptance:** `make all` green (baselines regenerate + every CKL schema-valid); 
  lockstep hashes verified on both remotes.
- **Depends:** PACK-1..5.