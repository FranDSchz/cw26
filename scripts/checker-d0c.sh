#!/usr/bin/env bash

set -uo pipefail

BASE_URL="${1:-http://localhost:8080}"
EXPECTED_FLAG="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMEOUT="${TIMEOUT:-3}"
log() {
    printf '%s %s\n' "$(date -Iseconds)" "$*" >&2
}

if [[ -z "$EXPECTED_FLAG" ]]; then
    log "FAIL: falta la flag mock esperada"
    exit 2
fi

if ! "$SCRIPT_DIR/healthcheck-http-d0a.sh" "$BASE_URL"; then
    log "FAIL: la funcionalidad base no supero el healthcheck"
    exit 3
fi

actual_flag="$(
    curl \
        --fail \
        --silent \
        --show-error \
        --max-time "$TIMEOUT" \
        "$BASE_URL/mock-flag.txt"
)" || {
    log "FAIL: no se pudo recuperar la flag mock"
    exit 4
}

if [[ "$actual_flag" != "$EXPECTED_FLAG" ]]; then
    log "FAIL: la flag mock recuperada no coincide"
    exit 5
fi

log "PASS: servicio y flag mock correctos"
exit 0
