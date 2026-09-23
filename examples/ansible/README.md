# Ansible examples for stig-baselines

Two ways to drive assessments from this repo with Ansible.

## stig-eval.yml — mixed-OS cluster evaluation (the role)

`roles/stig_eval/` maps every host by its detected OS family to the
matching stig-baselines artifacts:

| Host OS | Workflow | What happens |
|---|---|---|
| RHEL family (RHEL, Rocky, Alma; 7/8/9) | `workflow_rhel.yml` | **automated**: the committed DISA SCAP benchmark is copied to the target, `oscap xccdf eval` runs (become), results + HTML report are fetched back, and a **populated CKL** is generated on the control node (`tools/xccdf2ckl.py --results`, schema-validated). |
| Debian/Ubuntu | `workflow_debian.yml` | baseline-CKL handoff — DISA publishes no SCAP content for the Canonical Ubuntu STIGs; assess in STIG Viewer. |
| Proxmox VE (PVE node; detected via `pveversion`) | `workflow_proxmox.yml` | **automated**: the PVE-STIG kit's read-only scanner (`controls.yaml` + `proxmox-scan.sh`) is copied to the node, the scan runs (become), and its output is fetched back. Remediation stays with `proxmox-harden.sh --apply`. |
| Windows | `workflow_windows.yml` | baseline-CKL handoff (manual; registry/GPO checks). Needs `ansible.windows` + WinRM only if you add evidence-collection tasks. |
| macOS | `workflow_macos.yml` | baseline-CKL handoff over SSH (15 Sequoia + 26 Tahoe baselines). |
| vSphere/ESXi/vCenter | not managed here | manual — see [docs/VSPHERE67-EVALUATION.md](../../docs/VSPHERE67-EVALUATION.md). |

Artifacts land in `../stig-eval-results/` (outside the repo) —
`<host>/baseline.ckl`, `<host>/<host>-eval.ckl`, `results.xml`,
`report.html`, `<host>-mapping.txt`.

```bash
# cluster run
ansible-playbook -i inventory-cluster-example.yml stig-eval.yml

# quick single-rule smoke on one host
ansible-playbook -i my-inventory.yml stig-eval.yml \
  --limit rhel8-web01 \
  -e '{"stig_eval_rules": ["xccdf_mil.disa.stig_rule_SV-230221r1017040_rule"]}'

# full automated profile for the RHEL fleet (takes minutes per host)
ansible-playbook -i my-inventory.yml stig-eval.yml --limit rhel
```

Targets need: SSH (key auth; `examples/ssh/`) + sudo (NOPASSWD for oscap,
`examples/sudoers/`) + `openscap-scanner` for the automated path. The
playbook is offline-capable: everything it references is committed.

## remote-scan.yml — generic OpenSCAP scan (legacy example)

A simpler Linux-only playbook for a generic OpenSCAP CIS Level-2 scan
with the datastream installed on the target. Kept for compatibility;
prefer stig-eval.yml for repo-driven assessments.

## Statuses and bulk-apply

`xccdf2ckl.py --results` maps oscap results to statuses
(pass→NotAFinding, fail→Open, notapplicable→Not_Applicable, everything
else→Not_Reviewed) and normalizes datastream rule ids, so the output
stays schema-valid. For rules checked outside OpenSCAP, record them in a
CSV and apply with `tools/csv2ckl.py`.