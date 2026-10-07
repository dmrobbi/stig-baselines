# Kubernetes / k3s — hardening guide

_Sources: Kubernetes STIG V2R6 (kit landed 2026-10-06: `baselines/kubernetes/{kubernetes-scan.sh, kubernetes-harden.sh, controls.yaml, run-kube-bench.sh, LAB-ASSESSMENT.md}`), CIS Kubernetes via kube-bench v0.16.0, Rancher k3s hardening guide for the thing1 node. Clusters: kind-gms (bare-metal kind), k3s on thing1._

## Run the kit (primary procedure)

```
cd baselines/kubernetes
sudo ./kubernetes-scan.sh                    # read-only; exit = fail count
sudo ./kubernetes-harden.sh                  # dry-run by default; --apply root-gated + backups
./run-kube-bench.sh                          # pinned v0.16.0, JSON+text evidence, OK-marker contract
```

The kind-gms lab path is documented in `LAB-ASSESSMENT.md` (kube-bench in-container job + STIG manual-pass checklist).

## k3s node (thing1) — config-as-code in `/etc/rancher/k3s/config.yaml`, checked into this repo

```
write-kubeconfig-mode: "0600"
protect-kernel-defaults: true
secrets-encryption: true          # enables datastore secret encryption; on an EXISTING cluster
                                  # follow k3s re-encrypt procedure (rotate-keys steps) — do not hand-trick it
kube-controller-manager-arg:
  - "bind-address=127.0.0.1"
kube-scheduler-arg:
  - "bind-address=127.0.0.1"
kubelet-arg:
  - "streaming-connection-idle-timeout=5m"
  - "protect-kernel-defaults=true"
  - "event-qps=0"
disable:                          # only components we genuinely don't serve:
  - servicelb                     # keep traefik if ingress serves anything — check before disabling
```

Restart via systemd with the existing unit; API port 6443 stays off the WAN (ufw/DOCKER-USER per the Ubuntu + Docker guides).

## RBAC / PSA

- No interactive user binds `cluster-admin` routinely — separate a named admin identity for break-glass; daily ops through scoped roles.
- Every app namespace: PodSecurity admission label `enforce=restricted, warn=restricted`; third-party charts that refuse restricted → dedicated namespace at baseline + documented exception in `ignore_list.yml`.
- kube-bench / STIG exceptions land in `baselines/kubernetes/ignore_list.yml` with one-line justifications — same mechanism the PVE kit uses.

## Runtime hygiene

- NetworkPolicy default-deny (ingress+egress) per namespace, allowlists after; no flat `allow all`.
- Ingress: TLS minimum 1.2, HSTS at the edge; cert-manager-issued certs, no self-signed past bootstrap.
- k3s datastore (single-node sqlite): back up `/var/lib/rancher/k3s/server` (encrypted, off-host) alongside the manifest dir; kind-gms: etcd snapshots if/when prod-shaped.
- Registry pulls: pin digests (same policy as the Docker guide); no `:latest` in manifests.

## Verify

```
./kubernetes-scan.sh ; exit code 0 (or documented EXCEPT list)
./run-kube-bench.sh  → JSON evidence with OK markers
kubectl get networkpolicy -A          # default-deny present per namespace
kubectl auth can-i --list --as=<daily-operator>    # no cluster-admin leak
cat /etc/rancher/k3s/config.yaml      # matches the committed copy (diff = drift alert)
```

## Change risk

- `secrets-encryption` on a live cluster requires the k3s re-encrypt/restart sequence — backup the datastore first; encryption-at-rest does not retro-affect already-stored secrets until re-encrypted.
- Disabling add-ons (servicelb/traefik) can break our helm charts — inventory what's actually consuming them before the change.