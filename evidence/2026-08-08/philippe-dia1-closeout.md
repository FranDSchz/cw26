# Día 1 — Cierre (Philippe)

**Fecha real de ejecución:** 8 de agosto de 2026 (Día 1 nominal era 7/08; corrido por
atraso de agenda, ver nota de handoff).
**Modalidad:** sesión individual con tutor IA. Bloque 6 (integración grupal) no
ejecutado — requiere a Mati y Franco presentes, se descarta para este día.

## CAPACIDAD DEMOSTRADA

- Explica el formato territorial (24 VMs, 6 capitales, 18 provincias vacías),
  first-blood, y por qué mismos puertos ≠ mismas vulnerabilidades.
- Resuelve los tres escenarios de decisión bajo presión sin deliberar: checker rojo
  (queda a resolver, no negocia puntos), exploit verificado multi-capital (se dispara,
  no se sigue puliendo), hipótesis sin evidencia a los 8 minutos (se corta).
- Diferencia autenticación de autorización con un caso propio (ver Pruebas).
- Captura, repite y modifica requests HTTP (curl y proxy) con predicción previa.
- Entorno de estudio operativo: Docker, ZAP, Python/Requests, git, SSH local.

## ARTEFACTOS

- `defensa/local-ssh-lab/` (repo `cyberwar/`) — servidor SSH local de práctica,
  reemplaza a la Raspberry Pi para trabajo individual.
- Proxy ZAP (127.0.0.1:8090) verificado end-to-end contra un target local
  (`juice-shop`), incluyendo el fix de red Docker (`pentest-net`) para que ZAP
  pueda alcanzar servicios publicados en localhost del host.
- Hallazgo propio: IDOR en OWASP Juice Shop (`routes/basket.ts`,
  función `retrieveBasket`) — el servidor calcula si el basket pedido pertenece al
  usuario autenticado pero nunca actúa sobre ese resultado antes de responder.
  Diff mínimo propuesto, no aplicado todavía.
- Ya existente de sesiones previas, redescubierto y validado hoy:
  `defensa/sla_monitor.py` + `defensa/checks.example.json` — checker P0 (función,
  no puerto) más adelantado que el cronograma del plan.

## PRUEBAS

- `cw26-http-d0a`: propiedad rota = "el servidor no debería servir un archivo solo
  porque existe en el filesystem, necesita whitelist explícita de qué es público".
  Legítima: `GET /` → 200. Abusiva: `GET /mock-flag.txt` → 200 (debería ser 4xx).
- Juice Shop: propiedad rota = el carrito debe estar scopeado al usuario de la
  sesión. Legítima: `GET /rest/basket/6` (propio) → 200. Abusiva:
  `GET /rest/basket/5` (ajeno, `UserId` distinto) → 200 con datos de otro usuario,
  debería ser 403.

## ERRORES

- Confundió capital con provincia en la primera explicación del formato (corregido).
- Primer intento de "IDOR" fue sobre `/rest/products/{id}/reviews` — dato público de
  catálogo, no objeto scopeado a usuario; no probaba lo que creía. Redirigido al
  endpoint correcto (`/rest/basket/{id}`), ahí sí encontró un caso real.
- Etiquetó el problema de `mock-flag.txt` como falla de autenticación cuando era de
  autorización/exposición — corregido, y ya no repitió el error en el hallazgo
  siguiente.
- Pegó un JWT/cookie de sesión sin redactar en el chat dos veces (cuenta descartable
  local, riesgo real nulo, pero es el hábito que hay que tener automático antes de
  la competencia real).

## PARKING LOT

- Software Seguro vs. PortSwigger Academy como lab de referencia — no se resolvió,
  terminó no haciendo falta (Juice Shop local lo cubrió).
- `cyberwar/` (carpeta de estudio, distinta de este repo) no tiene git — ofrecido
  `git init`, no decidido.
- El diff propuesto sobre `routes/basket.ts` no se aplicó — ver siguiente acción.

## SIGUIENTE ACCIÓN EXACTA

Aplicar el fix del basket IDOR con ciclo completo (snapshot, diff, prueba
positiva/negativa, regresión) — natural para el estudio de IDOR/autorización, se
puede adelantar respecto al cronograma si hay tiempo.

## REGLAS Y SUPUESTOS VIGENTES

- Plan v4.1. Philippe: único escritor habitual de la capital propia.
- SLA: +100 a −3000; primera caída, por corta que sea, ya cuesta 10 puntos.
- Alcance ofensivo: solo red de servidores. Estaciones rivales y red de
  auditoría/juez, ninguna de las dos — ni atacar ni escanear.
- Nunca reiniciar por precaución; ante checker rojo, actuar primero, diagnosticar
  después; un solo parche a la vez.
