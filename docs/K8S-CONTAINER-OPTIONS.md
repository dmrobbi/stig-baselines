# Options: Kubernetes + container STIG additions for stig-baselines

Counted, categorized option list for what this repo can absorb next, compiled
2026-10-05 from a live sweep of the DISA catalog (cyber.trackr.live mirror),
the CIS/oss scanner ecosystem, and this repo's own pipeline + kit patterns.
Pick numbers; we decompose into the tasklist on request (the OPT-NN pattern
used by the agentic-ai todo).

Ground rules inherited from this repo:

- Official sources first: cyber.trackr.live mirrors DISA XCCDF; the existing
  pipeline (`tools/trackr_fetch.py` → `tools/xccdf2ckl.py` → `build.sh` +
  `Makefile`) turns them into STIG-Viewer-ready CKL baselines.
- Hardening artifacts = idempotent scan/harden shell kits with controls.yaml +
  ignore_list.yml (the proven pattern is `baselines/proxmox/`).
- Wazuh SCA policies give continuous per-rule fleet auditing.
- Every option ends in evidence: a saved scan output, a green scan, or a
  documented manual control.

## A. Official DISA baselines (new families through the existing pipeline)

- [ ] **OPT-K01 · Kubernetes STIG V2R6 baseline** — released 2026-02-12,
  92 rules (18 CAT I / 74 CAT II). Fetch the V2R6 XCCDF via trackr_fetch,
  generate the manual CKL, commit
  `baselines/kubernetes/U_Kubernetes_STIG_V2R6_Manual-baseline.ckl` + the README
  baseline-table row.
- [ ] **OPT-K02 · Kubernetes STIG release tracker** — record the V2R5
  (2026-01-05) → V2R6 (2026-02-12) lineage in sources/ provenance so future
  refreshes follow the documented pulse.
- [ ] **OPT-K03 · Container Platform Security Requirements Guide V2R4
  baseline** — released 2025-09-10, 188 rules (8 High / 177 Med / 3 Low). The
  platform-agnostic container guide; CKL through the same pipeline.
- [ ] **OPT-K04 · Docker Enterprise 2.x STIG V2R2 (legacy import)** — frozen
  at V2R2 (Jun 2024) and the product is EOL; import marked legacy for
  old-Docker estates only, or explicitly skip with a decision note.
- [ ] **OPT-K05 · DevSecOps Container Image Creation & Deployment Guide
  checklist** — distill the 2.6 public guide (image origin, minimal base, no
  latest tags, SBOM) into a csv2ckl-generated non-STIG checklist.

## B. Scanners and wiring (evidence over manual review)

- [ ] **OPT-K06 · kube-bench runner wrapper** — `baselines/kubernetes/` runner:
  pinned kube-bench release, versioned `--benchmark`, JSON + text output,
  exit-code contract with an OK marker (the house command-payload pattern).
- [ ] **OPT-K07 · kube-bench ↔ Kubernetes STIG cross-map** — map CIS kube-bench
  controls to Kubernetes STIG V-IDs where they correspond, so CKL statuses can
  be bulk-updated from a kube-bench run via csv2ckl.
- [ ] **OPT-K08 · docker-bench-security wrapper** — same wrapper pattern for
  Docker hosts, mapped to Container Platform SRG controls.
- [ ] **OPT-K09 · kubescape / kubeaudit cluster-scan option** — framework
  profile scans (NSA/CISA Kubernetes hardening guidance); report into a
  committed findings format that merge_ckl/csv2ckl can ingest later.
- [ ] **OPT-K10 · Tenable audit files** — commit the published
  `DISA_STIG_Kubernetes_v2r6.audit` (93 items) + Docker audit files under
  `baselines/kubernetes/audits/` with hashes + provenance.

## C. Hardening kits (the baselines/proxmox pattern)

- [ ] **OPT-K11 · Kubernetes hardening kit** — `baselines/kubernetes/`:
  kubernetes-scan.sh + kubernetes-harden.sh + controls.yaml + ignore_list.yml.
  Control surface: apiserver/kubelet/etcd/controller-manager/scheduler flags —
  anonymous-auth off, authorization-mode, admission plugins, etcd TLS + peer
  auth, audit logging, kubelet authn/webhook TLS, read-only port off, cert
  rotation, eviction params.
- [ ] **OPT-K12 · Kubernetes manifest hardening pack** — committed manifests:
  Pod Security Admission (restricted profile) namespace labels, default-deny
  NetworkPolicies, resource quotas + LimitRanges, non-root runAs/readonly
  rootfs/dropped caps/seccomp templates, digest-pinned imagePullPolicy,
  no auto-mounted service-account tokens.
- [ ] **OPT-K13 · Docker host hardening kit** — `baselines/docker/`:
  docker-host-scan.sh + docker-host-harden.sh. Control surface: daemon.json
  (remote API off, log rotation, live-restore), TLS daemon if remote, container
  defaults (no-new-privileges, cap-drop, read-only rootfs), socket ownership,
  userns-remap option.
- [ ] **OPT-K14 · kind / single-node lab kit** — hardened kind profile
  (kind-config with kubeadm patches for the CIS-relevant flags) + a lab scan
  mode that runs kube-bench in-container.
- [ ] **OPT-K15 · Wazuh SCA policy for Kubernetes** —
  `baselines/kubernetes/sca_k8s_policy.yml`, per-rule checks grouped by API
  object, scoped to hosts that present a K8s marker (the proxmox SCA pattern).
- [ ] **OPT-K16 · Wazuh SCA policy for container hosts** —
  `baselines/docker/sca_container_platform_policy.yml`, SRG-mapped per-rule
  checks (daemon.json keys, socket perms, runtime flags, image provenance).

## D. Supply chain and images

- [ ] **OPT-K17 · Hardened image inventory** — decision doc + rebuild list
  (Iron Bank / Chainguard minimal images for the containers we run; the
  Chainguard STIG-mapped image notes).
- [ ] **OPT-K18 · Image signing + SBOM gate** — cosign verify + syft SBOM
  generation as a small pipeline script + a policy checklist.
- [ ] **OPT-K19 · Registry hardening** — GitLab container registry (and any
  Harbor): TLS, auth, retention, trivy vuln-scan job + the controls row.
- [ ] **OPT-K20 · Image CVE feed** — scheduled trivy scan over our image set
  with a committed JSON report and a threshold gate (the kevstig pattern: the
  counts publish honestly, drift daily).

## E. Lab fleet tie-ins (run against existing infrastructure)

- [ ] **OPT-K21 · kind-gms cluster assessment** — scan the existing bare-metal
  kind lab with kube-bench + a Kubernetes STIG manual pass; produce the first
  evidence-backed CKLs with statuses from a live run.
- [ ] **OPT-K22 · k3s / RKE2 option row** — if a lab node moves to k3s/RKE2,
  kube-bench ships k3s profiles and RKE2 has its own hardening guide; option
  stays un-open until a deployment exists.
- [ ] **OPT-K23 · Kubernetes on pve-lab test plan** — 2-3 VMs/CTs in the
  rebuilt PVE cluster under HA as the k8s test garden; pairs with the
  CLUSTER-HA-SETUP guide.
- [ ] **OPT-K24 · containerd / podman scan variants** — the Container Platform
  SRG controls against containerd (reading /etc/containerd/config.toml) and a
  podman variant; pick per the runtimes we actually run.

## F. Documentation and process

- [ ] **OPT-K25 · docs/KUBERNETES-PROGRAM.md** — the Kubernetes twin of
  PROXMOX-PROGRAM.md: scope (kind-gms + any production cluster), phases,
  evidence plan, owner decisions.
- [ ] **OPT-K26 · README + roadmap rows** — add every new baseline family to
  the README table and tick the roadmap Tier-1 rows (Kubernetes #2, containers
  #3) to in-repo status.
- [ ] **OPT-K27 · SCANNING.md wiring** — document how kube-bench / docker-bench
  / SCA outputs flow into CKLs and Wazuh dashboards.
- [ ] **OPT-K28 · Suggested build order** — starter sequence:
  K01 + K03 baselines → K06 + K08 wrappers → K11 + K13 kits → K15 + K16 SCA →
  K12 pack → K21 lab evidence → D/F remainder.

Starter pack of five, if you want the quickest useful slice: **K01, K06, K11,
K13, K21** — the official baseline, an evidence-producing scanner, two
hardening kits, and a real lab assessment to prove it all end to end.