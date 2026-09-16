#!/usr/bin/env bash
# sudo-remote-scan.sh — run an OpenSCAP scan on a remote host via
# `ssh <user>@<host> 'sudo -n oscap xccdf eval'`, pull the XCCDF results
# back, and (optionally) convert them into a DISA STIG Viewer baseline CKL.
#
# Auth: SSH keys (default) or a password via sshpass (--password).
# The remote user needs the scoped sudoer (see examples/sudoers/soc-remote-scan):
#   Cmnd_Alias SOC_OSCAP = /usr/bin/oscap xccdf eval *
#   <scan-user> ALL=(root) NOPASSWD: SOC_OSCAP
#
# Usage:
#   tools/sudo-remote-scan.sh --host <name-or-ip> [--user <user>] [--port <22>]
#       [--password <ssh-password>] [--results <local-path>] [--report <local-path>]
#       [--profile <xccdf-profile-id>] [--ds <datastream-path>] [--out-dir <dir>]
#       [--hostname <asset hostname>] [--ip <asset ip>] [--skip-ckl]
#
# Examples:
#   tools/sudo-remote-scan.sh --host 192.168.200.130 --profile xccdf_org.ssgproject.content_profile_cis \
#       --ds sources/rhel8/ssg-rhel8-ds.xml
#   tools/sudo-remote-scan.sh --host evgen-b --user wez --skip-ckl
set -euo pipefail

HOST=""
USER_NAME="${SUDO_REMOTE_SCAN_USER:-wez}"
PORT="22"
PASSWORD=""
PROFILE="xccdf_org.ssgproject.content_profile_cis"
DS=""
OUT_DIR=""
SKIP_CKL="false"
HOSTNAME_ARG=""
IP_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --password) PASSWORD="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --ds) DS="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --hostname) HOSTNAME_ARG="$2"; shift 2 ;;
    --ip) IP_ARG="$2"; shift 2 ;;
    --skip-ckl) SKIP_CKL="1"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -n "$HOST" ] || { echo "ERROR: --host is required" >&2; exit 1; }
[ -n "$DS" ] || { echo "ERROR: --ds (path to the SCAP datastream) is required" >&2; exit 1; }
OUT_DIR="${OUT_DIR:-./remote-scan-${HOST}-$(date -u +%Y-%m-%d)}"
HOSTNAME_ASSET="${HOSTNAME_ARG:-$HOST}"
IP_ASSET="${IP_ARG:-$HOST}"

# ssh options: BatchMode (no prompts) + accept-new host keys; password
# auth goes through sshpass only when --password is given.
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new -p "$PORT")
SCP_OPTS=(-o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new -P "$PORT")
if [ -n "$PASSWORD" ]; then
  command -v sshpass >/dev/null 2>&1 || { echo "ERROR: sshpass is required for --password" >&2; exit 1; }
  SSH_OPTS=(-o StrictHostKeyChecking=accept-new -p "$PORT")
  SCP_OPTS=(-o StrictHostKeyChecking=accept-new -P "$PORT")
  SSH_OPTS+=(-o "PreferredAuthentications=password" -o "PubkeyAuthentication=no")
  export SSHPASS="$PASSWORD"
  SCP_PREFIX=("sshpass" "-e")
else
  SCP_PREFIX=()
fi

REMOTE_DIR="/tmp/soc-remote-scan-$$"
mkdir -p "$OUT_DIR"

echo "== $HOSTNAME_ASSET ($HOST:$PORT) — sudo oscap eval =="
${SCP_PREFIX[@]+"${SCP_PREFIX[@]}"} "${SCP_OPTS[@]}" "$DS" "$USER_NAME@$HOST:$REMOTE_DIR/"
ssh "${SSH_OPTS[@]}" "$USER_NAME@$HOST" "sudo -n mkdir -p $REMOTE_DIR && sudo -n mv $REMOTE_DIR/ds.xml $REMOTE_DIR/ds.xml.tmp && sudo -n mv $REMOTE_DIR/ds.xml.tmp $REMOTE_DIR/ds.xml"
ssh "${SSH_OPTS[@]}" "$USER_NAME@$HOST" "sudo -n oscap xccdf eval --profile '$PROFILE' --results $REMOTE_DIR/results.xml --report $REMOTE_DIR/report.html $REMOTE_DIR/ds.xml" || true
${SCP_PREFIX[@]+"${SCP_PREFIX[@]}"} "${SCP_OPTS[@]}" "$USER_NAME@$HOST:$REMOTE_DIR/results.xml" "$OUT_DIR/results.xml"
${SCP_PREFIX[@]+"${SCP_PREFIX[@]}"} "${SCP_OPTS[@]}" "$USER_NAME@$HOST:$REMOTE_DIR/report.html" "$OUT_DIR/report.html" || true
ssh "${SSH_OPTS[@]}" "$USER_NAME@$HOST" "sudo -n rm -rf $REMOTE_DIR"

echo "XCCDF results: $OUT_DIR/results.xml"
echo "HTML report:   $OUT_DIR/report.html"

if [ "${SKIP_CKL:-0}" != "1" ]; then
  python3 tools/xccdf2ckl.py "$OUT_DIR/results.xml" "$OUT_DIR/baseline.ckl" \
    --hostname "$HOSTNAME_ASSET" --ip "$IP_ASSET"
  echo "Baseline CKL:  $OUT_DIR/baseline.ckl"
fi