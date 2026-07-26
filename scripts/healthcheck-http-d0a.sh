#!/usr/bin/env bash

set -uo pipefail

BASE_URL="${1:-http://localhost:8080}"
TIMEOUT="${TIMEOUT:-3}"

log() {
    printf '%s %s\n' "$(date -Iseconds)" "$*" >&2
}

main_body="$(
    curl \
        --fail \
        --silent \
        --show-error \
        --max-time "$TIMEOUT" \
        "$BASE_URL/"
)" || {
    log "CRITICAL: no se pudo consultar la funcionalidad principal"
    exit 2
}

if ! grep -q 'Estado funcional: operativo' <<<"$main_body"; then
    log "CRITICAL: la página principal no contiene el estado esperado"
    exit 3
fi

health_body="$(
    curl \
        --fail \
        --silent \
        --show-error \
        --max-time "$TIMEOUT" \
        "$BASE_URL/health"
)" || {
    log "CRITICAL: no se pudo consultar /health"
    exit 4
}

if [[ "$health_body" != "ok" ]]; then
    log "CRITICAL: /health devolvió contenido inesperado: '$health_body'"
    exit 5
fi

log "OK: funcionalidad principal y /health operativos"
exit 0
