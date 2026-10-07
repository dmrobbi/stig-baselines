# Apple macOS — hardening guide

_Sources: our CKLs (`baselines/macos/`: Apple macOS 15 Sequoia V1R6, macOS 26 Tahoe V1R3), CIS Apple macOS Benchmark, NSA Apple macOS Security Guidance, Apple Platform Security. Recommended tooling: NIST [macOS Security Compliance Project](https://github.com/usnistgov/macos_security) (generates profiles implementing STIG/CIS checks, deployable as .mobileconfig)._

## Management plane decision first

- The fleet has multiple Macs — manage via **compliance profiles** (MDM-less possible: `mdmclient`-style .mobileconfig install + periodic check), or defer: generate the profile, review diffs manually. Raw `defaults write` commands drift silently; profiles make drift visible.

## Core hardening

1. **FileVault 2 on**, personal or institutional recovery key escrowed off the device (institutional preferred; store in the secrets store, not on the Mac).
2. **Firewall on + stealth mode** (`/usr/libexec/ApplicationFirewall/socketfilterfw --globalstate on --stealthmode on`), block all unless signed software.
3. **Gatekeeper on** (default), `spctl --status` verify; don't bypass for ad-hoc tools — keep them signed/development-signed.
4. **SIP on** (`csrutil status`); never disable — if a tool demands it, that tool is a phase-out candidate.
5. **SSH (RemoteLogin) off** unless required; when on: keys only (`PasswordAuthentication no` in `/etc/ssh/sshd_config.d/`), no root login equivalent (`PermitRootLogin no`).
6. **Screen saver lock at 5 min**, password immediately: via profile (`askForPassword=true`, `askForPasswordDelay=0`).
7. **Auto updates on** (`sudo softwareupdate --schedule on` + auto-install critical/security), Xcode CLT updated separately.
8. Guest account disabled; automatic login disabled; admin accounts limited (daily driver = standard account).
9. Bluetooth sharing / AirDrop / Handoff off on work Macs (TCC hygiene); Spotlight suggestions off (privacy/data flow).
10. Auditing: `log` retention raised (e.g. `log config --mode "logdir_size:500000000"`); send unified logs to the SOC if the Mac touches infra.
11. Bluetooth/USB accessories: no firmware auto-pairing surprises; keep Touch ID for sudo? (fine).
12. TCC review quarterly: `tccutil --list`-style review or manual check in System Settings; remove stale consent grants.

## Verify

```
fdesetup status                 # FileVault on + key escrowed
spctl --status ; csrutil status
sudo softwareupdate --schedule
defaults read com.apple.screensaver  (or profile status via `profiles status -type configuration`)
socketfilterfw --getglobalstate --getstealthmode
```

## Change risk

- Profiles can block dev tooling (TCC prompts, notarization). Audit profile subset first, add blocks only for tools actually flagged.
- FileVault escrow: institutional key = everyone with the key can decrypt; store with the other crown-jewel secrets, rotate policy documented.