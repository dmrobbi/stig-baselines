# RHEL 8/9 hosts — hardening guide

_Sources: RHEL 8 STIG V2R9 and RHEL 9 STIG V2R10 (baselines and oscap datastreams committed in `baselines/rhel8` / `baselines/rhel9`), scap-security-guide (SSG), ansible-lockdown roles. Discipline from HARDENING-ROADMAP: remediation runs in maintenance windows only, with snapshots._

## Scan (read-only, any time)

```
sudo dnf install -y openscap-scanner scap-security-guide
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_stig \
  --fetch-remote-ovals \
  --results /tmp/rhel9-oscap.xml --report /tmp/rhel9-oscap.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
```

Review the report; the SSG `stig` profile mirrors the DISA STIG — exceptions should end up in the kit `ignore_list.yml` pattern we use for PVE/K8s kits, with a one-line justification.

## Remediate (maintenance window, snapshot first)

```
sudo lvcreate -s -n snap-prestig -L 5G <rootvg/lv>          # or your snapshot mechanism
oscap xccdf remediate --results /tmp/rhel9-oscap.xml /tmp/rhel9-oscap.xml
reboot   # kernel/crypto-policies changes often require it
```

Re-scan after reboot; compare pass/fail deltas. Anything that failed-but-is-accepted goes to the exceptions list with justification, not away silently.

## Central crypto policy

- `sudo update-crypto-policies --show` — set explicitly per host class:
  - default hosts: `DEFAULT` (RHEL current TLS 1.2/1.3 safe set),
  - stricter sets (STIG crypto): `update-crypto-policies --set DEFAULT:OSPP` or FIPS only where a requirement demands — FIPS breaks some libs; test first.
- This is the single control that retunes sshd/nginx/openldap ciphers at once — prefer it over per-service cipher lists on RHEL.

## Other baseline items

- SELinux: confirm `getenforce` = `Enforcing`, policy `targeted`; never set permissive in prod.
- firewalld zones: services only in the zones they belong in; `firewall-cmd --list-all` reviewed per host role.
- cockpit: `sudo systemctl disable --now cockpit.socket` where no one uses it.
- USBGuard on any host with console/physical access.
- fapolicyd (whitelisting) is a phase-2 — enable in monitoring mode first (`fapolicyd --permissive`) before enforcing.
- Keep `dnf-automatic` (security only) or Satellite/candlepin cadence documented per host.

## Ansible path (preferred for fleets)

```
ansible-galaxy install ansible-lockdown.rhel9_stig   # and rhel8_stig
```

Run with `-t remediate` in windows; tags allow per-control granularity and the role's `skip` vars are our exceptions transport. Evidence: run `ansible-playbook ... --check` and keep the generated reports next to the oscap ones in this repo's `dist/`.

## Verify

```
oscap xccdf eval ... (as above) — pass count target: 100%% minus approved exceptions
getenforce ; update-crypto-policies --show
ansible-lockdown role in check mode, diff reviewed
```

## Change risk

- `oscap xccdf remediate` is destructive by design (edits files, restarts services). Snapshot + window + re-scan; never blind-run from Ansible on shared hosts.
- FIPS/OSPP crypto policies have broken third-party clients before — validate our own sshd, docker pulls, and wazuh connections after any policy change.