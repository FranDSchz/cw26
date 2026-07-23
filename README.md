# Cyber War 2026 — repositorio técnico

Fuente de verdad para scripts, servicios, exploits de laboratorio, runbooks y postmortems.

## Reglas

- Prohibido guardar credenciales, tokens, VPN, flags reales o `.env`.
- Todo cambio técnico entra por rama y PR.
- Un parche requiere checker verde y rollback.
- Un script requiere timeout, manejo de errores, logs y README de uso.
- Cada procedimiento crítico debe ser probado por alguien distinto del autor.

## Estructura

- `rules/`: reglamento y decisiones técnicas derivadas.
- `runbooks/`: inventario, recuperación, apertura y cierre.
- `scripts/`: healthchecks, automatización y utilidades.
- `exploits/`: pruebas autorizadas y runners.
- `services/`: Compose, configuraciones y parches de laboratorio.
- `postmortems/`: hechos, impacto, causa y acciones.

