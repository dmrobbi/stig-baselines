# Kubernetes lab assessment runbook (kind-gms / any kubeadm kind cluster)

Status: READY — runnable the moment a cluster locus confirms. No bare-metal kind
cluster was located on thing1 or trooper2 as of 2026-10-06 (checked docker
containers, kubectl contexts, memory notes). When one appears, run:

```bash
# 0) locate: which host runs kind (or any kubeadm cluster)?
kind get clusters        # on the candidate host
docker ps | grep node    # kind nodes run as containers "node-name-control-plane"
kubectl config get-contexts
```

## What this pack runs (two tracks)

**Track 1 — CIS evidence (automated):** the kube-bench job
(`kind-audit-job.yaml`) runs kube-bench v0.16.0 on each node via the
aquasecurity/kube-bench image, mounting the node's /etc/kubernetes,
/var/lib/kubelet, /etc/etcd (hostPaths) — the kind nodes are containers, so the
"host paths" = the HOST's paths kind mounts into the node containers; with kind,
run kube-bench inside each node container instead:

```bash
for n in $(docker ps --format '{{.Names}}' | grep -E '(control-plane|worker)'); do
  docker exec "$n" bash -c 'kube-bench run --benchmark cis-1.11 --json' \
    > "results/kube-bench-$n.json" 2> "results/kube-bench-$n.err"
done
```

**Track 2 — Kubernetes STIG V2R6 manual pass:** use the repo's
`U_Kubernetes_V2R6_Manual-baseline.ckl` in STIG Viewer 2/3 and drive the
assessments against the cluster; the kit's `kubernetes-scan.sh` covers the
file/kubelet/control-plane rules on each node when run as root there.

## Evidence flow

1. Track 1 JSONs → `baselines/kubernetes/results/` (evidence dir; committed with
   the run log, no cluster data leaves).
2. Track 2 → statuses from STIG Viewer or the scan script's text output.
3. Bulk-update the CKL via `tools/csv2ckl.py` (see docs/SCANNING.md).

## Precondition

A reachable cluster. Without it nothing here executes; the assets stay
committed and ready (documented 2026-10-06).