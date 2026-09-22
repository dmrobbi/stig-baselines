# Proxmox VE cluster with HA on a single host — build guide

> The working, verified setup: **4 Proxmox VE 9.2.20 nodes in one qemu VM host,
> clustered with corosync, HA-armed via NFS shared storage, all four in the
> Wazuh fleet.** Built 2026-09-22 on gus2 (a 20-core i9 with VT-x disabled —
> everything runs under TCG software emulation; 10-20x slower than KVM, fully
> functional). Every command below ran successfully as written.

Companion docs: [PILOT-TEST-PLAN.md](PILOT-TEST-PLAN.md) (the T1–T9 test
runbook + pilot run log), [wazuh-sca-integration.md](wazuh-sca-integration.md)
(the continuous-audit wiring), [findings.md](findings.md) (the live findings
register), [PROXMOX-PROGRAM.md](../PROXMOX-PROGRAM.md) (the program plan).

## 1. Topology

```
gus2 (Ubuntu 24.04, bare metal)
├── br-pve  10.10.10.1/24          dedicated bridge = the cluster network
│     ├── tap-pve1 ── pve-pilot   10.10.10.11  (also Wazuh agent 021)
│     ├── tap-pve2 ── pve2        10.10.10.12  (Wazuh agent 022)
│     ├── tap-pve3 ── pve3        10.10.10.13  (Wazuh agent 023)
│     └── tap-pve4 ── pve4        10.10.10.14  (Wazuh agent 024)
├── qemu TCG VMs: each node has TWO NICs
│     ├── NIC1 user-mode (SLIRP): outbound internet + host forwards to the LAN
│     └── NIC2 tap on br-pve:     corosync + cluster traffic (L2, VM-to-VM)
├── /srv/pve-nfs on NFS (10.10.10.1) = the shared storage for HA
└── host forwards on the SLIRP NICs: 2222-2225→ssh, 8006-8009→:8006
```

Design decisions worth keeping:

- **Two NICs per node.** NIC1 is qemu user-mode networking (SLIRP): gives each
  VM outbound internet for apt and the Wazuh repo, and a `hostfwd` so the LAN
  reaches ssh + the PVE UI without touching the host firewall. NIC2 is a tap on
  a dedicated bridge: VM-to-VM L2 for corosync. SLIRP VMs cannot see each
  other, which is exactly what you want — the cluster rides its own wire.
- **Static cluster IPs via cloud-init MAC matching** — deterministic, no DHCP
  dependency on the cluster network.
- **A dedicated bridge, not the LAN bridge.** The cluster network never
  touches the LAN; only the SLIRP forwards do (and those can be bound to
  127.0.0.1 or firewalled — see the audit notes).

## 2. Host preparation (gus2)

```bash
# bridge + host address + one tap per node
sudo ip link add br-pve type bridge
sudo ip addr add 10.10.10.1/24 dev br-pve
sudo ip link set br-pve up
for i in 1 2 3 4; do
  sudo ip tuntap add dev tap-pve$i mode tap
  sudo ip link set tap-pve$i master br-pve
  sudo ip link set tap-pve$i up
done
```

Disk and RAM: each node is a 32G thin qcow2 (a PVE VE install lands at
~10 GB actual); 4 GB RAM / 2 vCPU per node is comfortable for a cluster under
TCG. Have ~10 GB actual free per node.

## 3. Node build (the cloud-init recipe)

Base: Debian 13 (trixie) genericcloud qcow2 — PVE 9 is trixie-based. Each node
gets a backing-file disk (`qemu-img create -f qcow2 -F qcow2 -b debian-13.qcow2
pveN-disk.qcow2 32G`) and a NoCloud seed ISO (`genisoimage -volid cidata`)
carrying three files:

**user-data** (the parts that matter — all of these fix something that broke
the first time, see [PILOT-TEST-PLAN.md](PILOT-TEST-PLAN.md)):

```yaml
#cloud-config
hostname: pveN
fqdn: pveN.lan
manage_etc_hosts: false          # CRITICAL: true rewrites /etc/hosts on EVERY
                                 # boot and breaks pmxcfs (pve-cluster)
disable_root: false
ssh_pwauth: false
write_files:
  - path: /etc/hosts             # full static hosts file, written ONCE
    content: |
      127.0.0.1 localhost
      10.10.10.11 pve-pilot.lan pve-pilot
      10.10.10.12 pve2.lan pve2
      10.10.10.13 pve3.lan pve3
      10.10.10.14 pve4.lan pve4
      ::1 localhost ip6-localhost ip6-loopback
  - path: /etc/apt/sources.list.d/pve-install-repo.list
    content: |
      deb [signed-by=/usr/share/keyrings/proxmox-archive-keyring.gpg] http://download.proxmox.com/debian/pve trixie pve-no-subscription
  - path: /root/authorized_keys.real
    content: |
      ssh-ed25519 AAAA... your-key
package_update: true
runcmd:
  - curl -fsSL https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -o /usr/share/keyrings/proxmox-archive-keyring.gpg
  - echo "grub-pc grub-pc/install_devices multiselect /dev/vda" | debconf-set-selections
  - printf "postfix postfix/main_mailer_type string Local System\npostfix postfix/mailname string pveN.lan\n" | debconf-set-selections
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get install -y proxmox-ve postfix
  - rm -f /etc/apt/sources.list.d/pve-enterprise.sources   # unsigned, breaks apt
  - mkdir -p /root/.ssh && rm -f /root/.ssh/authorized_keys && install -m 600 /root/authorized_keys.real /root/.ssh/authorized_keys && rm -f /root/authorized_keys.real && chmod 700 /root/.ssh
  - touch /etc/cloud/cloud-init.disabled    # stop per-boot rewrites AFTER provisioning
power_state:
  mode: reboot
  timeout: 60
```

Why each oddity is there (all verified the hard way):

| Line | Breaks without it |
|---|---|
| `manage_etc_hosts: false` + hosts via write_files | `manage_etc_hosts: true` rewrites /etc/hosts every boot; boot 2 wipes your fix → pve-cluster (pmxcfs) dies on the Debian 127.0.1.1 style |
| hosts maps FQDN → 10.10.10.x | pmxcfs refuses to start when the hostname resolves only to 127.0.1.1 |
| authorized_keys as a REAL file (rm + install) | the cloud-image authorized_keys is a **symlink** into /var/lib/cloud that dangles after the PVE reboot — cp fails on it ("dangling symlink") |
| `rm pve-enterprise.sources` | proxmox-ve ships the unsigned enterprise repo; apt breaks on it |
| grub-pc preseed | dpkg configure prompts/errs on grub install devices in a non-interactive VM |
| `touch /etc/cloud/cloud-init.disabled` at the END of runcmd | after provisioning, cloud-init must never run again (it would undo the hosts/keys on later boots) |
| No `users:` section | the users module writes authorized_keys as a symlink — we own the file ourselves |

**network-config** (per node; MAC matching makes NIC order irrelevant):

```yaml
network:
  version: 2
  ethernets:
    slirp:
      match: {macaddress: "52:54:00:12:00:0N"}
      dhcp4: true                # outbound via SLIRP
    cluster:
      match: {macaddress: "52:54:00:aa:00:1N"}
      addresses: [10.10.10.1N/24]  # corosync/cluster net, no gateway
```

**qemu launch** (per node; forwards unique per VM):

```bash
qemu-system-x86_64 -accel tcg,thread=multi -cpu max -m 4096 -smp 2 \
  -drive file=pveN-disk.qcow2,if=virtio,format=qcow2 \
  -drive file=seedN.iso,if=virtio,format=raw,media=cdrom \
  -netdev user,id=n0,hostfwd=tcp::222N-:22,hostfwd=tcp::800N-:8006 \
  -device virtio-net-pci,netdev=n0,mac=52:54:00:12:00:0N \
  -netdev tap,id=n1,ifname=tap-pveN,script=no,downscript=no \
  -device virtio-net-pci,netdev=n1,mac=52:54:00:aa:00:1N \
  -display none -serial file:serial-pveN.log -monitor none
```

Serial-to-file is your install console; the install takes ~25-45 min per node
under TCG (3 nodes in parallel is fine — the host cores are the budget), and
cloud-init reboots into the PVE kernel when done.

**Gotchas that WILL bite** (all hit live once):

- The first-boot install and the second boot are different worlds. After
  cloud-init finishes, the node reboots into the PVE kernel with cloud-init
  disabled — expect a login prompt on serial and SSH via your key.
- If qemu refuses to start with `Failed to get "write" lock`, the previous
  qemu is still exiting (a slow poweroff under TCG). Wait for it to exit
  before relaunching — never bypass the lock.
- Adding a NIC to an existing VM = shutdown + relaunch. Attach the tap at
  boot time; then configure it in the guest (`ip -o link | grep <MAC>` to find
  the name, add an `auto <iface>` stanza to /etc/network/interfaces — note
  PVE's ifupdown2 does NOT source /etc/network/interfaces.d by default — and
  `ifup <iface>`).

## 4. Cluster formation

Preconditions: /etc/hosts has all five names on all nodes (done by the
recipe), the cluster NIC is up on every node, and passwordless SSH between
nodes. The last one matters: PVE 9's default `pvecm add` is the API join and
**prompts for the target's root password** — with key-only root auth you must
use the SSH join:

```bash
# on the first node
pvecm create pve-lab --link0 10.10.10.11

# on each additional node (place your private key in /root/.ssh/id_ed25519
# first — then node-to-node ssh is passwordless)
pvecm add 10.10.10.11 --use_ssh --link0 10.10.10.12   # ... .13, .14
```

`--use_ssh` is the piece most guides miss: without it the join dies with
`EOF while reading password` on a passwordless root account. The join merges
authorized SSH keys and restarts pveproxy/pvedaemon on the new node.

Verify:

```bash
pvecm status   # Nodes: 4, Expected votes: 4, Quorum: OK
pvecm nodes    # 1 pve-pilot, 2 pve2, 3 pve3, 4 pve4
```

Corosync is key-encrypted by default (the authkey is generated by pvecm) and
runs on the dedicated bridge — multicast/UDP flows freely on a local bridge.

## 5. Shared storage (NFS) — the HA prerequisite

HA failover needs the VM/CT disks reachable from every node. On the HOST
(gus2 — the simplest shared-storage provider for a single-host lab):

```bash
sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /srv/pve-nfs && sudo chown nobody:nogroup /srv/pve-nfs
echo "/srv/pve-nfs 10.10.10.0/24(rw,sync,no_subtree_check,fsid=0,no_root_squash)" \
  | sudo tee -a /etc/exports
sudo exportfs -ra
```

`no_root_squash` is required for PVE NFS storage (images are written as root);
the export is limited to the cluster network, and NFS is reachable only from
br-pve members in practice. Register it cluster-wide (once — pmxcfs spreads
it):

```bash
pvesm add nfs nfs-lab --server 10.10.10.1 --export /srv/pve-nfs \
  --content images,rootdir
pvesm status   # nfs-lab active on every node
```

## 6. High availability

PVE's HA stack (pve-ha-crm + pve-ha-lrm) ships with proxmox-ve and starts
itself once the cluster is quorate. Fencing uses the watchdog — on VMs, load
softdog on every node (`modprobe softdog`; /dev/watchdog appears; add it to
/etc/modules to persist) — the CRM then arms it (watch `ha-manager status`
for `fencing armed (CRM watchdog active)`).

**PVE 9 replaced HA groups with rules.** `ha-manager groupadd` is gone:

```bash
# resources
pveam update && pveam download local debian-13-standard_13.6-1_amd64.tar.zst
pct create 100 local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst \
  --hostname ha-test --memory 512 --rootfs nfs-lab:8
ha-manager add ct:100

# placement rule (the old group, migrated): priorities pve-pilot first
ha-manager rules add node-affinity lab-affinity \
  --resources ct:100 --nodes "pve-pilot:2,pve2:1,pve3:1,pve4:1"
```

After ~60-90 s the CRM assigns and the LRM starts the resource; `ha-manager
status` shows `master <node> (active)`, `fencing armed`, one `lrm ... active,
watchdog active`, the rest `standby`, and `service ct:100 (<node>, started)`.

**Failover test** (the proof): stop one node's qemu process and watch — the
CRM detects the lost LRM, the watchdog fence fires, and ct:100 relocates to
the next node by rule priority. Restart the stopped node and it rejoins as
standby. Keep the shared storage healthy: if NFS dies, HA resources cannot
restart anywhere (build the NFS provider with the same care as the nodes).

## 7. Adding the cluster to the Wazuh / SOC system

The lab nodes are fleet agents like any other host (manager on thing1):

```bash
# on each node
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor \
  -o /usr/share/keyrings/wazuh-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh-keyring.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  > /etc/apt/sources.list.d/wazuh.list
apt-get update
WAZUH_MANAGER=<manager-ip> WAZUH_AGENT_NAME=pveN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y wazuh-agent
systemctl enable --now wazuh-agent
```

Then, manager-side, put the agents into the `proxmox` agent group so the
PVE-STIG SCA policy audits them:

```bash
/var/ossec/bin/agent_groups -a -g proxmox -i <agent-id> -q
```

The PVE-STIG SCA policy (`baselines/proxmox/sca_pve_stig_policy.yml`) then
runs on every node — per-rule pass/fail with compliance refs lands in the
dashboard (Security Configuration Assessment), the SCA summary alert fires on
the manager (rule 19003), and the fleet score becomes the cluster's compliance
readout. Deployment nuance: if the agent-group shared-dir sync lags, place the
policy in the agent's `/var/ossec/ruleset/sca/` directly — SCA auto-discovers
it when the agent's `<sca>` block has no `<policies>` restriction; the
`pveversion` requirements rule scopes it to PVE hosts only.

## 8. Security posture notes (from the live audit)

- The lab key (`pve-pilot-key`) authorizes root on every node AND sits as
  `id_ed25519` on three of them: one node compromise chains to the cluster.
  Fine for a disposable lab; rotate to per-node keys before anything long-lived.
- qemu `hostfwd` binds **0.0.0.0** by default — every node's SSH + PVE UI is
  LAN-visible. Bind to 127.0.0.1 or firewall the forwards.
- Harden every node with the kit (`baselines/proxmox/proxmox-harden.sh
  --apply`) — fresh PVE installs ship `PermitRootLogin yes` and no auditd/
  aide/sysctl/pwquality. The scanner gives each node a failing-first baseline.
- The Wazuh manager's agent enrollment is open by default (`use_password=no`)
  — restrict it before any cluster is reachable from an untrusted network.

## 9. State of this build (2026-09-22)

| Layer | State |
|---|---|
| 4 nodes, PVE 9.2.20, kernel 7.0.14-19-pve | running (TCG) |
| cluster pve-lab, quorate | verified |
| nfs-lab storage | active cluster-wide |
| HA: CRM/LRM, fencing armed, node-affinity rule, ct:100 started | verified |
| Wazuh fleet: 021-024 all active, SCA group proxmox | done (pilot agent remediated; pve2/3/4 baseline scanned, remediation pending) |
| Live failover test | pending (procedure in §6) |