# baselines/kubernetes — Kubernetes STIG V2R6 kit

Generated from the official Kubernetes Security Technical Implementation Guide
V2R6 (released 2026-02-12, 92 rules). Source XCCDF + the full CKL baseline live
in this repo (`sources/kubernetes/`, the `U_Kubernetes_V2R6_Manual-baseline.ckl`).

## Files

| File | Role |
|------|------|
| `controls.yaml` | the control set this kit implements, keyed by STIG SV-ID |
| `kubernetes-scan.sh` | read-only assessment; exit code = FAIL count; `--json` output |
| `kubernetes-harden.sh` | fixer; dry-run default, `--apply` changes; backups for config edits |
| `ignore_list.yml` | accepted-risk exceptions (`<control-id>|<reason>|<expiry>`) = EXCEPT rows |
| `run-kube-bench.sh` | CIS kube-bench evidence runner (separate track; see OPT-K06) |

## Scan

```bash
sudo ./kubernetes-scan.sh            # text results, exit = fail count
sudo ./kubernetes-scan.sh --json     # machine-readable
```

Coverage v0.1.0: static file ownership/permissions (manifests, kubelets,
kubeconfigs, PKI), kubelet authentication flags (from the config file and
the systemd env-file), control-plane manifest flags (authorization mode,
anonymous auth, alpha gates, basic/token auth, Pod Security Admission,
etcd secret encryption, TLS minima). Live workloads (dashboard, env-var
secrets, namespaces) = SKIP rows with the manual-pass note unless kubectl
is authorized on the node. Paths assume kubeadm (`/etc/kubernetes/`,
`/var/lib/kubelet/`, `/var/lib/etcd/`); `K8S_ROOT` prefixes everything for
fixture/dry-forest tests.

## Harden

```bash
sudo ./kubernetes-harden.sh          # dry-run: prints every planned change
sudo ./kubernetes-harden.sh --apply  # real changes (config edits get .stig-backup files)
```

Not auto-applied (printed as RECOMMEND rows, restarts the control plane):
admission plugins, secret-encryption config, auth-file removals, TLS pins.
The kubelet flag edits require a kubelet restart to take effect.

## Evidence flow

Scan outputs land as text/JSON; CKL statuses update via `tools/csv2ckl.py`
(see docs/SCANNING.md). The kube-bench runner writes evidence into
`results/` with a JSON summary row the command-payload jobs can gate on.