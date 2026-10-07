# Minecraft server (itzg/minecraft-server) — hardening guide

_Sources: none formal (a game server on the home LAN — container isolation is the security model, guide 06 applies). Fleet: itzg/minecraft-server container on thing1, up and healthy._

## Controls

1. **Port exposure**: published port bound to the home-LAN interface only (not 0.0.0.0 per the Docker guide) — a Minecraft port on the WAN is a botnet-scan magnet for zero value.
2. `online-mode=true` (default) — no cracked clients; `enforce-secure-profile=true` (default on modern versions) so chat/reporting identity holds.
3. **Whitelist on** + explicit player list; `whitelist.json` + ops list minimal (no casual OP grants; ops = trust boundary).
4. RCON disabled, or if the container tooling needs it: bound to 127.0.0.1 **inside the container** only, strong password, never published externally.
5. `server.properties` permissions: container user-owned, 0600-ish (contains nothing secret but keep the perms clean per the controls.yaml pattern).
6. Backups: the itzg backup tooling scheduled for the world dirs — off the container volume, rotating; survival work is un-replaceable if the volume dies.
7. Container limits: explicit memory/CPU (world gen spikes; an OOM-killed gateway host is worse than a dead game).
8. Log rotation via the itzg tooling; crash patterns visible in the dashboard (it already reports healthy — keep the healthcheck).

## Verify

```
docker inspect mc --format '{{.HostConfig.PortBindings}}'    # LAN-only bind
grep -E 'online-mode|enforce-secure-profile|white-list|rcon' server.properties (inside container volume)
ss -tlnp | grep <mc-port>                                     # iface-specific bind, not WAN
backup dir: newest file age < schedule                        (world backups flowing)
```

## Change risk

- Enabling whitelist without the owner's player list = locking people out of their own game (collect the list first — it's the rare "security" control whose failure mode is annoyance, not outage).
- World backups: verify restore once (unzip + boot a temp instance) — same restore-drill discipline as everything with crown-jewel value: the world is it.