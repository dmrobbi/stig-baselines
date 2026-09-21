#!/usr/bin/env bash
set -euo pipefail

# pilot-vm-bootstrap.sh — lab/pilot-only VM bootstrap for the PVE-STIG program
# (docs/PROXMOX-PROGRAM.md). Stands up the Phase B pilot target on a PVE host:
# an Ubuntu cloud-init VM. Password SSH is intentionally ENABLED — the pilot
# starts unhardened so the first scan produces real findings (test T1 in
# docs/proxmox/PILOT-TEST-PLAN.md). Never production: override CI_PASSWORD
# or set SSH_PUBKEY_FILE. Copied from the operator's notes 2026-09-21.

#############################################
# Proxmox Ubuntu VM (Cloud-Init + Guest Agent)
# - Random VMID
# - SSH password authentication ENABLED
#############################################

log() { echo "[$(date +'%F %T')] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

#############################################
# Generate random free VMID
#############################################
generate_vmid() {
  while true; do
    local id
    id=$(shuf -i 1000-9999 -n 1)
    if ! qm status "$id" &>/dev/null; then
      echo "$id"
      return
    fi
  done
}

VMID="${VMID:-$(generate_vmid)}"

#############################################
# Config (override via env vars)
#############################################
NAME="${NAME:-ubuntu-ci}"
STORAGE="${STORAGE:-local-lvm}"
BRIDGE="${BRIDGE:-vmbr0}"

CORES="${CORES:-2}"
MEMORY="${MEMORY:-2048}"
DISK_GB="${DISK_GB:-20}"

UBUNTU_RELEASE="${UBUNTU_RELEASE:-jammy}" # 22.04
IMAGE_DIR="/var/lib/vz/template/iso"
IMAGE_PATH="${IMAGE_DIR}/${UBUNTU_RELEASE}-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img"

# Cloud-init identity
CI_USER="${CI_USER:-ubuntu}"
CI_PASSWORD="${CI_PASSWORD:-ubuntu123}"   # change in prod (lab only)
SSH_PUBKEY_FILE="${SSH_PUBKEY_FILE:-$HOME/.ssh/id_rsa.pub}"

# Networking
USE_DHCP="${USE_DHCP:-1}"
IP_CIDR="${IP_CIDR:-192.168.1.50/24}"
GATEWAY="${GATEWAY:-192.168.1.1}"
DNS="${DNS:-1.1.1.1}"

# Cloud-init snippets
SNIPPET_STORAGE="${SNIPPET_STORAGE:-local}"
SNIPPET_DIR="/var/lib/vz/snippets"
USERDATA="${SNIPPET_DIR}/${NAME}-${VMID}-user.yaml"
NETDATA="${SNIPPET_DIR}/${NAME}-${VMID}-net.yaml"

mkdir -p "$IMAGE_DIR" "$SNIPPET_DIR"

#############################################
# Download image if missing
#############################################
if [[ ! -f "$IMAGE_PATH" ]]; then
  log "Downloading Ubuntu cloud image"
  wget -qO "$IMAGE_PATH" "$IMAGE_URL"
fi

#############################################
# SSH key (optional but recommended)
#############################################
SSH_KEY=""
if [[ -f "$SSH_PUBKEY_FILE" ]]; then
  SSH_KEY=$(cat "$SSH_PUBKEY_FILE")
fi

#############################################
# Cloud-init user-data
#############################################
log "Creating cloud-init user-data"

cat >"$USERDATA" <<EOF
#cloud-config
hostname: ${NAME}
manage_etc_hosts: true

ssh_pwauth: true
disable_root: true

users:
  - name: ${CI_USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: [sudo]
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ${SSH_KEY}

chpasswd:
  expire: false
  list:
    - ${CI_USER}:${CI_PASSWORD}

package_update: true
packages:
  - qemu-guest-agent

runcmd:
  - systemctl enable --now qemu-guest-agent
  - sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - systemctl restart ssh
EOF

#############################################
# Cloud-init network config
#############################################
log "Creating cloud-init network config"

if [[ "$USE_DHCP" == "1" ]]; then
cat >"$NETDATA" <<EOF
version: 2
ethernets:
  ens18:
    dhcp4: true
EOF
else
cat >"$NETDATA" <<EOF
version: 2
ethernets:
  ens18:
    addresses: [${IP_CIDR}]
    gateway4: ${GATEWAY}
    nameservers:
      addresses: [${DNS}]
EOF
fi

#############################################
# Create VM
#############################################
log "Creating VM ${VMID}"

qm create "$VMID" \
  --name "$NAME" \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --cpu host \
  --net0 virtio,bridge="$BRIDGE" \
  --scsihw virtio-scsi-pci \
  --ostype l26 \
  --agent enabled=1 \
  --serial0 socket \
  --vga serial0

#############################################
# Disk import
#############################################
qm importdisk "$VMID" "$IMAGE_PATH" "$STORAGE"
qm set "$VMID" --scsi0 "${STORAGE}:vm-${VMID}-disk-0"
qm resize "$VMID" scsi0 "${DISK_GB}G"

#############################################
# Cloud-init drive
#############################################
qm set "$VMID" --ide2 "${STORAGE}:cloudinit"
qm set "$VMID" --boot order=scsi0

#############################################
# Apply cloud-init config
#############################################
qm set "$VMID" \
  --ciuser "$CI_USER" \
  --cipassword "$CI_PASSWORD" \
  --cicustom "user=${SNIPPET_STORAGE}:snippets/$(basename "$USERDATA"),network=${SNIPPET_STORAGE}:snippets/$(basename "$NETDATA")"

#############################################
# Network (Proxmox side)
#############################################
if [[ "$USE_DHCP" == "1" ]]; then
  qm set "$VMID" --ipconfig0 ip=dhcp
else
  qm set "$VMID" --ipconfig0 "ip=${IP_CIDR},gw=${GATEWAY}"
fi

#############################################
# Start VM
#############################################
qm start "$VMID"

log "✅ VM created"
log "VMID: $VMID"
log "User: $CI_USER"
log "Password: $CI_PASSWORD"
log "SSH: ssh ${CI_USER}@<vm-ip>"


