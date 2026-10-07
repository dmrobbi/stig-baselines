# GitLab + Runner (forge idm.wezzel.com) — hardening guide

_Sources: GitLab official hardening recommendations (docs.gitlab.com/security/hardening — general / application / OS / configuration pages with 800-53 mapping). No product STIG exists — this guide is also the control source for the flagship **custom GitLab benchmark** (SRG-APP controls → `gitlab.rb` + Admin Area checks, our xccdf2ckl pipeline). Fleet: Omnibus on the forge, bundled nginx/PG/redis/gitaly (their hardening lives in guides 08/09/13), shell-executor runner on thing1 (top roadmap finding)._

## gitlab.rb — the versioned source of truth

This repo holds `gitlab.rb` (config-as-code = drift detection per the roadmap). Every change below lands there first, `gitlab-ctl reconfigure` after.

```
external_url 'https://idm.wezzel.com'
nginx['ssl_protocols'] = 'TLSv1.2 TLSv1.3'
nginx['hsts_max_age'] = 31536000        # + CSP headers where supported
nginx['request_buffering_off_path_limit']    # sane defaults; keep buffering on
letsencrypt['enable'] = false            # certs are managed; not LE-managed by gitlab
```

## Admin Area settings (instance)

1. Open sign-up **disabled** (or admin-approval flow if opened); email confirmation required.
2. **2FA enforced** (instance setting) — grace period for migration; WebAuthn preferred.
3. `admin_mode` (re-auth for admin areas); restricted visibility levels (no public projects on infra forge); session duration capped.
4. **PAT expiry enforcement on** + max lifetime set; SSH key expiry enforced.
5. Import/export: max import size bounded, allowed importers limited, no public visibility on imports.
6. Rate limits: web + protected paths (sign-in/register/password-reset) + Files/CI API — start generous, tighten on telemetry.
7. Default branch protection: instance-level "protected branches + tags on creation".

## Project/group policy

- Protected branches: no direct pushes to main; MR approvals (min 1, reset on new pushes).
- Commit signing: enforce signed commits capability on; push rules for author-email allowlist (the Dawn Robbins attribution rule fits here).
- CI templates instance-wide: secret detection + dependency/container scanning on the pipelines that matter; audit-variables hygiene below.

## CI / secrets

- CI variables: **masked + protected** only; no plaintext secrets in `.gitlab-ci.yml` (tracked to fix); secure files reviewed quarterly.
- Runner: move the thing1 **shell executor off root-equivalence** — docker executor on a dedicated runner host (acceptance: no shell-executor runners with docker.sock access); registration tokens rotated + group-scoped; `pull_policy` allowlist on runner images.
- Fork pipeline runners disabled on instance runners.

## Audit + backups

- Audit events: instance audit JSON log shipped to the SOC (existing shipper patterns) — user/branch/setting changes land in Wazuh.
- `gitlab-backup create` weekly + copy the backup AND `/etc/gitlab/gitlab-secrets.json` AND registry/artifacts/LFS **off-host encrypted**; restore drill documented (the expired-glpat-token incident showed restore access is its own surface — keep a current push-scope token in the secrets store, not in `~/.git-credentials`).
- Upgrade cadence: supported path only (follow X.Y → X.Y+Z route docs), pin versions per release.

## Verify

```
gitlab-rake gitlab:check
gitlab-rake gitlab:doctor:secrets    # secret health after secret/config moves
curl -s https://idm.wezzel.com/api/v4/version -H 'PRIVATE-TOKEN <admin-token>'   # version tracking
Admin Area checklist walk (signup, 2FA, PAT expiry, rate limits) — evidence screenshots/table into the repo
git diff of committed gitlab.rb vs live (drift = alert)
```

## Change risk

- 2FA enforcement locks users without TOTP set up — communicate + set a deadline; keep a break-glass root token documented.
- PAT expiry enforcement kills existing automations silently (the git-credentials lesson) — inventory all active tokens (name/owner/scope/expiry) FIRST, reissue scoped ones, then enforce.