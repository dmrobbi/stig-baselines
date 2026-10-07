# Node.js apps — hardening guide

_Sources: OWASP Node.js Security Cheat Sheet + Express/helmet patterns; no product STIG (OS STIGs cover the host; app layer follows the App-Sec-Dev route). Fleet: mail-host web player (self-hosted at /player/, CSP patched for wasm-unsafe-eval), openclaw runtime, npm-installed tools on thing1/lab hosts._

## Runtime / process

- systemd unit per service with the guide-17 sandbox template (Node needs no capabilities); `OOMPolicy=stop`? set `Restart=on-failure` + `MemoryMax`; `--max-old-space-size` sane per service.
- Bind `127.0.0.1` (or the docker-internal iface for the player) — never `0.0.0.0`; external traffic always through nginx TLS (guide 13).
- Node current line (v24 running): track the LTS/current cadence; pin majors deliberately, minors auto-patched in the update routine.

## Dependencies

- `package-lock.json` committed, installs via `npm ci` only; `npm audit --production` in CI (fail on high/critical); renovate/dependabot cadence; no `npm i` of unvetted packages on prod hosts.

## App layer

- **Headers** (helmet or equivalent — and at the nginx edge for fronted apps): CSP, HSTS, nosniff, Frame-Options, Referrer-Policy. Known accepted exception: the player's CSP needs `wasm-unsafe-eval` for the wasm module (documented reason — keep, don't "fix" it away).
- Sessions/cookies: `Secure`, `HttpOnly`, `SameSite=strict` (or lax where redirects need it); strong session secrets from env (0600 files, never committed); CSRF tokens on forms.
- Input validation at the boundary (zod/joi) for all request fields; no `eval`, no `Function()` strings; template engines' auto-escape on (XSS).
- Authz checks per route group, not just per app (player endpoints auth-gated — the in-memory customers.js/view.js mocks are auth-gated already; keep that property when they become real).
- No sensitive data in URLs/logs; error responses generic (no stack traces).

## Deployment hygiene

- Disable source maps in prod builds; no `.env` served accidentally (nginx deny-dotfiles rule per guide 13); secrets via env files 0600.
- CI: lint + audit + tests before any deploy path; the forge-runner isolation rules (guide 15) apply to these pipelines.

## Verify

```
ss -tlnp | grep node                        # binds right
curl -sI https://<host>/ | grep -Ei 'content-security|strict-transport|x-frame|x-content-type'
npm audit --production                       (in each app repo)
journalctl -u <svc> -n 50                    (restarts/errors sane)
```

## Change risk

- Header/CSP tightening breaks frontend features — change one header at a time with the app loaded and exercised (the wasm-unsafe-eval history is exactly this lesson).
- Node minor bumps silently rebuild native modules — schedule with the service owner, verify a real end-to-end flow after.