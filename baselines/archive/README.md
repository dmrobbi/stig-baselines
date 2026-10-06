# Archived baselines

Rows retired from the maintained set. Nothing here is part of the scoreboard,
the kevstig routing table, or any derived claim. Kept as recoverable reference.

| Baseline | Archived | Reason | Artifacts |
|----------|----------|--------|-----------|
| `rhel7/` | 2026-10-06 | Owner call: RHEL 7 is an EOL track — retired from the maintained set and the kevstig scoreboard | `U_RHEL_7_STIG_V3R15_Manual-baseline.ckl` (244 rules, V3R15), `U_MOZ_Firefox_STIG_V6R8_Manual-baseline.ckl` (copy), `U_RHEL_7_V3R15_plus_Firefox_V6R8-baseline.ckl` (merged, 277 rules) |

**Restore procedure:** `git mv baselines/archive/rhel7 baselines/rhel7`, re-add the
`rhel7` platform to the kevstig routing tables (the red hat family platforms, the
version hint, and `ckl_hints`), rebuild the checker, and refresh the scoreboard
documents. The official DISA source zips were never removed — they remain under
`sources/` regardless of a row's archived status.