#!/usr/bin/env bash
# run-kube-bench.sh — CIS Kubernetes benchmark runner (evidence generator).
# Downloads the pinned kube-bench release on first use, runs per-node checks,
# writes JSON + text evidence into results/, prints an OK marker on success.
# Non-root use needs a reachable kubelet + control-plane configs; run as root
# on a node (or in a debug container) for full coverage.
set -u
VERSION="${KUBE_BENCH_VERSION:-v0.16.0}"
BENCHMARK="${KUBE_BENCH_BENCHMARK:-}"
OUT_DIR="${KUBE_BENCH_OUT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/results}"
BIN_DIR="${KUBE_BENCH_BIN:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.tools}"
EXTRA_ARGS="${KUBE_BENCH_ARGS:-}"

usage() {
  cat <<EOF
Usage: run-kube-bench.sh [options]

Env-var configuration:
  KUBE_BENCH_VERSION=<tag>    pinned release (default: ${VERSION})
  KUBE_BENCH_BENCHMARK=<id>   benchmark id, e.g. cis-1.12 (default: auto-detect)
  KUBE_BENCH_OUT=<dir>        evidence dir (default: baselines/kubernetes/results)
  KUBE_BENCH_BIN=<dir>        binary cache (default: baselines/kubernetes/.tools)
  KUBE_BENCH_ARGS="..."       extra kube-bench run arguments

Evidence files: results/<ts>-benchmark.json + <ts>-benchmark.txt
Exit contract: prints KUBE-BENCH-OK on a completed run; non-zero on failure.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

set -e
mkdir -p "$OUT_DIR" "$BIN_DIR"

ARCH="$(uname -m)"; case "$ARCH" in x86_64) A=amd64;; aarch64) A=arm64;; *) echo "unsupported arch $ARCH"; exit 2;; esac
VER_NO="${VERSION#v}"
TARBALL="kube-bench_${VER_NO}_linux_${A}.tar.gz"
URL="https://github.com/aquasecurity/kube-bench/releases/download/${VERSION}/${TARBALL}"
SBIN="$BIN_DIR/kube-bench-${VERSION}"

if [ ! -x "$SBIN" ]; then
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL --max-time 120 "$URL" -o "$TMP/$TARBALL"
  tar -xzf "$TMP/$TARBALL" -C "$TMP"
  mv "$TMP/kube-bench" "$SBIN"
  chmod 700 "$SBIN"
fi

TS=$(date -u +%Y%m%dT%H%M%SZ)
BENCH_ARGS=(run --outputfile "$OUT_DIR/$TS-benchmark.json" --json)
[ -n "$BENCHMARK" ] && BENCH_ARGS+=(--benchmark "$BENCHMARK")
# shellcheck disable=SC2086
"$SBIN" "${BENCH_ARGS[@]}" "$EXTRA_ARGS" 2>"$OUT_DIR/$TS-benchmark.err" | tee "$OUT_DIR/$TS-benchmark.txt"

if [ -s "$OUT_DIR/$TS-benchmark.json" ]; then
  python3 - "$OUT_DIR/$TS-benchmark.json" <<'PY' && true
import json, sys
d = json.load(open(sys.argv[1]))
tot = fail = 0
for cc in d.get("Controls", []):
    for t in cc.get("tests", []):
        for r in t.get("results", []):
            tot += 1
            if r.get("status") == "FAIL": fail += 1
print(f"KUBE-BENCH-SUMMARY total={tot} fail={fail}")
PY
  echo KUBE-BENCH-OK
  exit 0
fi
echo "KUBE-BENCH-FAIL: no JSON evidence produced"
exit 1