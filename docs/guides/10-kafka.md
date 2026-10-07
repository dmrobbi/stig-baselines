# Apache Kafka (FORGE topics) — hardening guide

_Sources: no product STIG — custom benchmark built from the General Application SRG (roadmap Tier 3 via our xccdf2ckl pipeline) + Confluent/Kafka security documentation. Fleet: miner stack (market, trade, auth, satellite, cicerone producers/consumers)._

## Listeners / transport

- Every listener on **SASL_SSL** — client listener and inter-broker alike; no plaintext broker listener except throwaway localdev (then bound to 127.0.0.1).
- Broker TLS: `ssl.protocol=TLSv1.2`, `ssl.enabled.protocols=TLSv1.2,TLSv1.3`, `ssl.client.auth=REQUIRED` at minimum for the inter-broker endpoint; certs from the internal CA with sane lifetimes.
- JMX: bind `127.0.0.1`, `-Dcom.sun.management.jmxremote.authenticate=true` (or no JMX).

## AuthN / AuthZ

- SASL **SCRAM-SHA-512**, one principal per app (market, trade, auth, satellite, cicerone, + ops tooling).
- Authorization via ACL authorizer with **deny-by-default**:

```
authorizer.class.name=kafka.security.authorizer.AclAuthorizer   # ZK era; KRaft uses the standard authorizer equivalent
allow.everyone.if.no.acl.found=false
super.users=User:kafka
```

- Grant per principal exactly: describe/produce/consume on named topics + read on its consumer group. No wildcard principals.
- `auto.create.topics.enable=false`; topic creation via ops runbook only.

## Broker posture

- `replication.factor>=3`, `min.insync.replicas=2` (acks=all producers enforced by our client wrappers), `unclean.leader.election.enable=false`.
- Quotas per tenant (bytes/sec) so one app can't starve the rest.
- Retention: topic-level retentions documented per data class; audit-adjacent topics live longer than the app topics.
- ZK (if still co-deployed): SASL + TLS on 2181 — a plaintext ZK undoes broker ACL enforcement. KRaft: the controller listener also needs SASL_SSL.

## Runtime (containers on miner)

- cap_drop ALL, no privileged, explicit memory limits (JVM heap + container), SCRAM creds via env files 0600 outside git (or the eventual secret store), network policies so only miners reach 9092-9093.

## Verify

```
kafka-configs --bootstrap-server <b>:9093 --describe --entity-type users         # SCRAM entries exist per principal
kafka-acls --bootstrap-server <b>:9093 --list                                    # wildcard-free grants
kafka-topics --describe --topic <t>                                             # rf, min.insync, no unclean flags
openssl s_client -connect <b>:9093 -showcerts                                    # cert chain + TLS version
kafka-configs --describe --entity-type brokers --all | grep -E 'listener.security.protocol|allow.everyone'
```

## Change risk

- Flipping `allow.everyone.if.no.acl.found=false` instantly denies every existing consumer — build the full principal+topic ACL allowlist FIRST, then flip, in a window.
- SCRAM is per-broker-broadcast state; add creds to all brokers before clients switch ports.