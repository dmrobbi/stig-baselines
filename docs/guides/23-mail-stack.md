# Mail stack (Postfix / Dovecot / rspamd) on the mail VPS — hardening guide

_Sources: no product STIG; NIST SP 800-45 (mail systems guidance), vendor docs, community hardening consensus (this is our own checklist route). Fleet: the bedimsecurity.com mail VPS — Postfix + Dovecot (auth backend), rspamd (filtering/DKIM signing), nginx in front of web vhosts (guide 13)._

## Postfix

```
# main.cf essentials
disable_vrfy_command = yes
smtpd_tls_security_level = may          # on MX 25 — encrypt where declared; see MTA-STS for enforcement path
smtpd_tls_mandatory_protocols = >=TLSv1.2
smtpd_tls_mandatory_ciphers = high
tls_high_cipherlist = (modern AEAD set)
smtp_tls_security_level = dane          # outbound DANE where the destination publishes TLSA — downgrade to encrypt if unmaintained
smtpd_client_restrictions = permit_mynetworks, permit_sasl_authenticated, reject (via the full chain below)
smtpd_helo_required = yes
smtpd_helo_restrictions = permit_mynetworks, reject_invalid_helo_hostname, reject_unknown_helo_hostname
smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
smtpd_forbid_unauth_pipelining = yes
message_size_limit / mailbox_size_limit — documented per class
```

- **postscreen on :25** (postscreen_dnsbl_action=enforce after a test period, pipelining enforcement, barrage) — the biggest anti-spam/anti-flood win for the same daemon.
- Submission (587) + smtps (465): `smtpd_tls_security_level=encrypt`, SASL via Dovecot, TLS required.
- Relay domains: only ours; `mynetworks` minimal (no /0); backscatter guards (address verification for relayed mail) if any relay is ever added.

## Dovecot

```
disable_plaintext_auth = yes
ssl = required
ssl_min_protocol = TLSv1.2
auth_mechanisms = plain login          # over TLS only — that's the constraint, plaintext inside TLS is standard
mail_location perms: mail dirs 0700, user uid/gid non-root
```

- per-user rate limits on IMAP (dovecot auth rate) if the SOC shows brute-force patterns; fail2ban jails (postfix auth + dovecot) active on this host.

## rspamd / domain posture

- DKIM: per-domains signing keyset, rotation documented; SPF: correct v=spf1 per domain (no +all); **DMARC: rua reporting first → p=quarantine → p=reject** (gradual, with report review — never direct reject on a live domain).
- MTA-STS (+ TLS-RPT) per sending domain: publish policy `mode: testing` first.
- rspamd actions tuned (reject spam threshold not overzealous — false positives on the owner's real mail are costlier than spam); no autolearn surprises on outbound.

## Verify

```
postfix: postconf -n review vs this guide; ss -tlnp (25/587/465 binds), postfix check
doveconf -n | grep -E 'ssl|plaintext'; ss binds
rspamadm configtest; dkim keys rotation dates
external: internet.nl + mail-tester on each domain (score + SPF/DKIM/DMARC/TLS)
fail2ban-client status (postfix+dovecot jails firing)
```

## Change risk

- postscreen enforce mode = legit senders greylisted — run soft (force/enforce-testing) a week, watch the log for real correspondents getting stuck.
- DMARC p=reject on a domain with unmanaged senders breaks them silently — rua data first, align every legitimate sender (the stsphotos fate decision affects its domain policies too).