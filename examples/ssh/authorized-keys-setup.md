# Setting up key-based auth for the remote scan user (auditor-side)

1. Auditor host — generate a scoped scan keypair (no passphrase; keep
   it offline-scoped):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/soc-remote-scan -C "soc-remote-scan"
   ```
2. On each STIGed target (as root):
   ```bash
   useradd -m -s /bin/bash scanuser
   install -d -m 700 -o scanuser -g scanuser /home/scanuser/.ssh
   install -m 600 ~/.ssh/soc-remote-scan.pub /home/scanuser/.ssh/authorized_keys
   # scoped sudoers (see examples/sudoers/soc-remote-scan)
   install -m 440 examples/sudoers/soc-remote-scan /etc/sudoers.d/soc-remote-scan
   visudo -cf /etc/sudoers.d/soc-remote-scan
   ```
3. Test from the auditor host:
   ```bash
   ssh -i ~/.ssh/soc-remote-scan -o BatchMode=yes scanuser@target 'sudo -n true'
   ```

Password auth (fallback): see `examples/ssh/remote-scan.md` (sshpass;
the password must not appear in shell history or files).