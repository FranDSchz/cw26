#!/usr/bin/env bash

set -uo pipefail

TARGET_IP="${TARGET_IP:-127.0.0.1}"
TARGET_PORT="${TARGET_PORT:-8080}"
BASE_URL="http://${TARGET_IP}:${TARGET_PORT}"
TIMEOUT="${TIMEOUT:-3}"

log() {
    printf '%s %s\n' "$(date -Iseconds)" "$*" >&2
}

log "INFO: direcciones del host"
ip -br addr >&2

log "INFO: ruta hacia $TARGET_IP"
ip route get "$TARGET_IP" >&2

log "INFO: listener TCP esperado en $TARGET_PORT"
listener_output="$(ss -H -lnt "sport = :$TARGET_PORT")"

if [[ -z "$listener_output" ]]; then
    log "CRITICAL: no existe listener TCP en $TARGET_PORT"
    exit 6
fi

printf '%s\n' "$listener_output" >&2

log "INFO: GET $BASE_URL/"
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

log "OK: GET / devolvió HTTP exitoso y contenido esperado"

log "INFO: GET $BASE_URL/health"
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

log "OK: GET /health devolvió 'ok'"
log "RESULT OK: red, listener y funcionalidad HTTP operativos"
exit 0
