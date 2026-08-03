# Preparación individual D0-C — Franco

Fecha local: 2026-08-02
Entorno: laboratorio aislado WSL/Docker
Estado grupal: microsimulación no ejecutada

## Checker

Artefacto: `scripts/checker-d0c.sh`

Contrato:

- valida la funcionalidad base mediante el healthcheck D0-A;
- recupera `/mock-flag.txt` con timeout;
- compara exactamente la flag recuperada con la esperada;
- emite mensajes con timestamp;
- devuelve códigos diferentes según la etapa que falla;
- no imprime el contenido de las flags.

Códigos:

| Código | Significado |
|---:|---|
| 0 | Servicio y flag mock correctos |
| 2 | No se proporcionó la flag esperada |
| 3 | Falló la funcionalidad base |
| 4 | No se pudo recuperar la flag |
| 5 | La flag recuperada no coincide |

Limitaciones:

- mock público y aislado, no un diseño seguro;
- la flag esperada se pasa como argumento;
- no existe autenticación ni operación legítima de almacenamiento;
- el código 3 requiere diagnóstico adicional.

## Tarjeta 1 — Flag ausente

Estado bueno:

- contenedor activo;
- `/` y `/health` correctos;
- `/mock-flag.txt` presente;
- checker con código 0.

Incidente:

- se movió temporalmente `mock-flag.txt`;
- `/` y `/health` permanecieron funcionales;
- la consulta de la flag devolvió HTTP 404;
- checker con código 4.

Recuperación:

- restaurar `mock-flag.txt`;
- ejecutar nuevamente el checker;
- aceptar recuperación únicamente con PASS.

Métricas aproximadas:

- incidente: 23:56:22 UTC;
- detección: 23:58:20 UTC;
- recuperación validada: 23:58:43 UTC;
- MTTD aproximado: 1 min 58 s;
- detección a PASS: 23 s;
- incidente a PASS: 2 min 21 s.

## Tarjeta 2 — Servicio detenido

Estado bueno:

- contenedor `cw26-http-d0a` activo;
- publicación `8080:80`;
- listener presente;
- checker con código 0.

Incidente:

- servicio `web` detenido;
- Compose sin contenedor en ejecución;
- listener 8080 ausente;
- `curl` produjo error 7, conexión rechazada;
- checker con código 3.

Recuperación:

- iniciar el servicio `web`;
- verificar estado y publicación;
- ejecutar nuevamente el checker.

Métricas:

- detección registrada: 00:51:33 UTC;
- recuperación validada: 00:54:01 UTC;
- detección a PASS: 2 min 28 s;
- MTTD no calculable por falta de marca de inicio;
- código final no capturado, aunque el checker imprimió PASS.

Error operativo:

- se ejecutó `stop web` dos veces; no produjo daño.

## Tarjeta 3 — Puerto incorrecto

Estado bueno:

- servicio publicado en `127.0.0.1:8080`;
- checker configurado para el mismo destino;
- checker con código 0.

Incidente:

- checker ejecutado contra `127.0.0.1:18080`;
- conexión rechazada;
- checker con código 3.

Diagnóstico:

- comparar URL del checker;
- consultar `docker compose ps -a`;
- comprobar publicación de puertos;
- comprobar listeners reales.

Recuperación:

- si el checker está equivocado, corregir su URL o la configuración del runner;
- si la publicación contradice el contrato, corregir `compose.yaml` y aplicar con `up -d`;
- validar nuevamente con el checker completo.

## Scoreboard del dry-run individual

| Ronda | Rol | Incidente | Resultado durante incidente | MTTD | Detección a PASS | Resultado final |
|---:|---|---|---|---|---|---|
| 1 | Operador/checker | Flag ausente | Exit 4 | 1 min 58 s | 23 s | Exit 0 |
| 2 | Operador/checker | Servicio detenido | Exit 3 | No medido | 2 min 28 s | PASS; código no capturado |
| 3 | Operador/checker | Puerto incorrecto | Exit 3 | No medido | No medido | Exit 0 |

## Conclusiones

- Un healthcheck verde no demuestra que la flag pueda recuperarse.
- Un mismo código de fallo puede representar causas distintas.
- La recuperación termina únicamente cuando el checker vuelve a PASS.
- El dry-run individual no aprueba la microsimulación grupal ni la rotación de roles.
