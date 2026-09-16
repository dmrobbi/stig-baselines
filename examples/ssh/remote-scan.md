# Direct SSH sudo-remote-scan (no ansible)

One-off scans over plain SSH. The remote user needs the scoped sudo
(see `examples/sudoers/soc-remote-scan`) — NOPASSWD for oscap only is
the least-privilege recommendation.

## Key-based auth (recommended)

1. Generate a scan keypair on the auditor host (no passphrase — keep
   it offline-scoped):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/soc_scan_key -N "" -C "soc-remote-scan"
   ```
2. Install the PUBLIC key on each target:
   ```bash
   ssh-copy-id -i ~/.ssh/soc-remote-scan.pub scanuser@target-host
   ```
3. Run the scan (datastream pushed via stdin — no quoting hazards):
   ```bash
   cat sources/scap/ssg-debian12-ds.xml | \
     ssh -i ~/.ssh/soc-remote-scan scanuser@target \
       'sudo -n bash -s' < tools/remote-scan-stdin.sh
   ```
   (or the one-liner pattern used by `tools/sudo-remote-scan.sh`)

## Password auth (fallback — needs sshpass)

```bash
sudo apt-get install -y sshpass   # auditor host
sshpass -P sshpass -e ssh scanuser@target ...
# with SSHPASS=<password> exported from a vault/secret store — never
# inline passwords.
```

## Scoped sudoers on the target

Drop into `/etc/sudoers.d/soc-remote-scan` (chmod 440, root-owned):

```
Cmnd_Alias SOC_OSCAP = /usr/bin/oscap xccdf eval *
scanuser ALL=(root) NOPASSWD: SOC_OSCAP
```

Least-privilege: the scan user can only run `oscap xccdf eval *` as
root — nothing else. Full `NOPASSWD: ALL` for the scan user works too
but is broader than needed.

## Notes

- BatchMode ssh (`-o BatchMode=yes`) fails fast instead of prompting —
  good for automation.
- `StrictHostKeyChecking=accept-new` trusts new host keys on first
  connect; drop it if you pre-populate known_hosts another way.
- Password auth: prefer keys. If passwords are required, `sshpass`
  keeps them out of process lists (the password itself still goes over
  the wire inside the SSH session — that is fine; it must not appear
  in shell history or files).