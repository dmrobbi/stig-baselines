# WordPress — hardening guide

_Sources: WordPress.org official Hardening documentation; community benchmark `dknauss/wp-security-benchmark` (no official DISA STIG or CIS benchmark exists — see catalog note). Fleet: bedimsecurity.com + stsphotos.com on the mail-host nginx (WordPress fate on stsphotos is an owner decision — harden what we keep)._

## wp-config.php (site root, 0640 owner web-user)

```
// rotate the salts (api.wordpress.org/secret-key/1.1/salt) — do this at install and after any suspected leak
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);   // if updates flow through wp-cli/staging; else keep false + plugin minimization discipline
define('FORCE_SSL_ADMIN', true);
define('WP_AUTO_UPDATE_CORE', 'minor');   // security minors automatic; majors deliberate
define('WP_MEMORY_LIMIT', '256M');
define('FS_METHOD', 'direct');       // + correct web-user ownership makes updates non-tftp
```

- DB user: least-privilege (no DROP/ALTER beyond what's needed), password in the secrets store; `table_prefix` non-default at install; DB on localhost socket or internal IP only.

## Filesystem / web server

- Ownership web-user, group web-user (`www-data`/equivalent), files 0640, dirs 0750; ONLY `wp-content/uploads` writable by the web server, everything else read-only to it (via nginx fastcgi user + perms, not chmod 777).
- NGINX (per the NGINX guide baseline block) plus WordPress-specific rules:

```
location = /xmlrpc.php { deny all; }
location ~* (?:\.htaccess|readme\.html|wp-config\.php|wp-admin/install\.php)$ { deny all; }
location ~* /(?:uploads|files)/.*\.php$ { deny all; }
# wp-login brute force: limit_req zone + (better) fail2ban jail reading access_log
```

- Security headers at the vhost (CSP tuned to plugins/themes — do tighten gradually; `upgrade-insecure-requests` first).

## Plugins / themes

- Minimum set, each actively maintained (last update < 12 months), removed when unused; no nulled/anything-from-unknown-zips (that's 90%% of WP compromises).
- 2FA on admin accounts (auth plugin of choice); admin over HTTPS-only; /wp-admin allowlist by IP where the owners' office/VPN IPs are stable.
- Update cadence: wp-cli cron weekly (`wp core update`, `wp plugin update --all` on staging → prod), not manual dashboard clicks.

## Ops

- Off-host backup (files + db dump) before every update; restore drill documented (the stsphotos WordPress fate decision should name its backup owner).
- `wp-cli` + `wpscan` in CI: `wpscan --url <site> --api-token <token-id>` quarterly.
- Monitor: fail2ban jail on wp-login POST failures → feeds the SOC (the mail-host already ships auth logs pattern per skills).

## Verify

```
wp core verify-checksums ; wp plugin list --update=available ; wp theme list --update=available
ls -la wp-content/{plugins,themes} | awk perms        # no 777, no web-user-owned core files
curl -s -o /dev/null -w '%%{http_code}' https://<site>/xmlrpc.php   # 403/404 expected
fail2ban-client status nginx-wplogin                  # jail firing on real attempts
```

## Change risk

- `DISALLOW_FILE_MODS` breaks plugin installs from the dashboard — gate it behind the wp-cli update flow being live first.
- Locks on /wp-admin by IP: owners lose access from new locations — document the VPN path + the allowlist change runbook before enabling.