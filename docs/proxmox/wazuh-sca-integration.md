# Wazuh SCA integration — the continuous-audit layer (Phase F)

The plan's enforcement layer reuses the fleet's existing Wazuh deployment
(thing1 = manager, 192.168.1.106: dashboard 5601 / API 55000). A Proxmox host
becomes a **Wazuh agent**, and the PVE-STIG control set becomes a **custom SCA
(Security Configuration Assessment) policy** the manager pushes to the agent —
giving scheduled, per-rule pass/fail reporting with compliance references, exactly
the operational half of a STIG.

## 1. Agent deployment (prerequisite — Phase A/D)

On each Proxmox node: install the Wazuh agent (Debian package from
`packages.wazuh.com` matching the manager's 4.x version), register against thing1,
assign it to a new agent group **`proxmox`** (manager-side:
`agent_groups -a -q proxmox`, then `agent_groups -a -i <agent-id> -q proxmox`).

## 2. The custom SCA policy

Format: a YAML file dropped into the agent group's shared config
(`/var/ossec/etc/shared/proxmox/sca_pve_stig_policy.yml` on the manager), with:

```yaml
policy:
  id: pve_stig
  file: sca_pve_stig_policy.yml
  name: "PVE-STIG — Proxmox VE STIG-style compliance"
  description: Layered control set: CIS Debian base + hypervisor + Proxmox services
  references:
    - https://www.cisecurity.org/cis-benchmarks/
    - https://public.cyber.mil/stigs/
requirements:
  title: "Verify Proxmox VE host hardening"
  condition: all
checks:
  - id: 100504
    title: "pveproxy must carry explicit TLS hardening (PVE-STIG-0210)"
    description: "Checks /etc/default/pveproxy TLS configuration."
    rationale: "Weak TLS on the management plane exposes the cluster."
    remediation: "Set CIPHERS/TLS versions in /etc/default/pveproxy; restart pveproxy."
    compliance:
      - reference: "PVE-STIG-0210"
    rules:
      - 'f:/etc/default/pveproxy -> r:^CIPHERS'
  # ... one block per control in layered-controls.md — see the committed
  # baselines/proxmox/sca_pve_stig_policy.yml
```

Rules are `grep`-style file checks (`f:`/`d:` `path -> r:pattern`), command
checks (`c:command -> r:pattern`), and `condition: any/all` — the official
Wazuh policy format (same shape as the wazuh-ruleset cis policies). Every
check command in `layered-controls.md` translates to a rule, or stays in
`proxmox-scan.sh` when SCA cannot express it (e.g. `sshd -T`, `pct config`).

## 3. Deployment + cadence

- The policy + `.gitattributes`-style sync rides the agent-group shared config —
  edit on thing1 under `/var/ossec/etc/shared/proxmox/`, agents pick it up on
  their sync interval.
- Schedule: agent-side, in the `ossec.conf` (or agent-group `agent.conf`)
  `<sca>` block — `<enabled>yes</enabled>`, `<scan_on_start>yes</scan_on_start>`,
  `<interval>24h</interval>` (Phase F default; snippet:
  [`examples/proxmox/wazuh-sca-ossec.conf`](../../examples/proxmox/wazuh-sca-ossec.conf)).
  Cadence is NOT a policy-file setting.
- Results appear in the Wazuh dashboard under **Security Configuration
  Assessment** per agent; each rule's `compliance.reference` maps to the
  PVE-STIG rule ID so the dashboard reads like a STIG checklist.

## 4. Drift + alerting

- SCA failures beyond the accepted-findings register → severity ≥ 10 alerts
  (rule tuning in `/var/ossec/etc/rules/local_rules.xml` if needed).
- Add log-monitoring rules for Proxmox events: `/var/log/pve/tasks/*`,
  `/var/log/daemon.log` (pvedaemon), corosync — new-privileged-CT and root-SSH-key
  alerts are the two Phase F drift rules.
- The manager's index keeps SCA history → monthly re-baseline evidence lives
  there automatically.

## 5. Ordering note

The Wazuh agent on Proxmox nodes is itself a Phase A/D deliverable (no Proxmox
agent exists in the fleet yet). SCA can be tested on the pilot node immediately
after agent deployment, before the hardening script exists — a failing-first
baseline is exactly what Phase B wants.