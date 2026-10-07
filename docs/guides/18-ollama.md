# Ollama — hardening guide

_Sources: no STIG/CIS exists; vendor docs are thin — treat under the App-Sec-Dev SRG route (guide 17's application controls apply) + general service-exposure discipline. Fleet: ollama.service on thing1 (and gus2 as the app/llama host), node v24-class clients, SOC services as consumers._

## Network / exposure

1. `OLLAMA_HOST=127.0.0.1` (default keep), port 11434 — **Ollama has no built-in auth**. Any LAN/WAN exposure is anonymous API access to compute + models: forbidden on this fleet. If remote inference is needed, front it with nginx (guide 13: TLS + auth + rate limit) or keep clients local/VPN.
2. `OLLAMA_ORIGINS` unset/locked-down (origin allowlist only matters when it's actually reachable — do not "fix CORS" by opening it).
3. Verify the unit doesn't publish on the docker bridge or extra interfaces.

## Filesystem / runtime

- Models dir (`~/.ollama/models` or `OLLAMA_MODELS`): 0700/0750, owner the service user; model pulls happen as that user only.
- Systemd sandbox (guide 17 template): `NoNewPrivileges`, `ProtectSystem=strict` + `ReadWritePaths=<models-dir>`, `PrivateTmp`, `CapabilityBoundingSet=`, `MemoryMax=` sized to the largest model + KV cache (OOM-protect the host: an LLM swapping the gateway host into a coma is a self-inflicted outage), `RestrictAddressFamilies` per the template.
- Model supply: pull only by explicit names/tags from the local registry mirror or ollama.com by name — no " somebody's random GGUF" policy; big models from untrusted sources are an unreviewed-supply-chain surface (document pulls in the kit's ignore_list pattern when this becomes a benchmark).

## Application controls (V6R4 lens)

- Consumers (SOC services, openclaw): API calls validated (prompt/context size caps — a 90-second-decision class incident already exists from unconstrained LLM paths; keep the laya lessons intact — timeouts + fallbacks stay).
- Prompt/response logging: no credential or sensitive data into stored transcripts (SOC data crosses paths here) — the existing logging rules in guide 17 apply.

## Verify

```
ss -tlnp | grep 11434                       # 127.0.0.1 only
systemd-analyze security ollama.service
systemctl cat ollama | grep -E 'Protect|Restrict|MemoryMax'
ollama list                                  # model inventory matches the documented pulls
```

## Change risk

- Sandboxing with the models dir on a different path than `OLLAMA_MODELS` points at → downloads fail post-restart; set both consistently.
- `MemoryMax` too low = mid-inference OOM kills — size generously but bound (watch `ollama ps` VRAM/RSS during a real inference).