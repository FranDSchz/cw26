# Evidencia D0-A — Franco

## Objetivo

Relacionar proceso, puerto, servicio, configuración, contenido y logs; recuperar un contenedor detenido y una configuración dañada; crear un healthcheck y documentar el rollback.

## Servicio utilizado

- Servicio: Nginx en Docker Compose
- Puerto publicado: 8080
- Puerto interno: 80
- Configuración: services/http-d0a/config/default.conf
- Contenido: services/http-d0a/site/index.html
- Healthcheck: scripts/healthcheck-http-d0a.sh
- Runbook: runbooks/http-d0a-recovery.md

## Resultado funcional

- Docker Compose válido.
- Configuración de Nginx válida.
- Página principal comprobada mediante HTTP.
- Endpoint /health comprobado.
- Healthcheck final con código de salida 0.
- Backup creado y restauración comprobada.
- Hash del backup:
  f61125896e4b277f6bd2b0ee5e9fc8eb379c137791fb7e0965722d99281443e5

## Incidente 1 — Contenedor detenido

### Ejecución guiada

- Tiempo: 12,98 segundos.
- Resultado: servicio recuperado.
- Ayuda: comando de validación proporcionado.

### Replay autónomo

- Tiempo: 1 minuto 52 segundos.
- Ayudas: ninguna.
- Resultado: servicio recuperado y endpoints comprobados.
- Error: primera solicitud realizada contra /healt en lugar de /health.

## Incidente 2 — Configuración dañada

### Primera ejecución

- Tiempo: 7 minutos 13 segundos.
- Resultado: servicio recuperado.
- Ayuda: consulta externa ante un error del runtime de Docker.
- Incidente adicional: fallo del bind mount individual.
- Solución: restauración con Git y recreación del contenedor.

### Replay autónomo

- Tiempo: 3 minutos 38 segundos.
- Ayudas: ninguna.
- Resultado: configuración restaurada, nginx -t exitoso y healthcheck con código 0.
- Errores:
  - git --diff en lugar de git diff;
  - Compose ejecutado desde el directorio incorrecto;
  - orden incorrecto en docker compose exec.

## Rollback desde backup

- Se reemplazó deliberadamente index.html con contenido incorrecto.
- El healthcheck detectó la pérdida de funcionalidad y devolvió código 3.
- Se extrajo el backup dentro del directorio del servicio.
- Los archivos existentes fueron sobrescritos con el estado conocido como bueno.
- El servicio volvió a superar nginx -t y el healthcheck.

## Modelo mental demostrado

- Un proceso activo no garantiza funcionalidad.
- Un puerto abierto no garantiza que el checker sea exitoso.
- Los bind mounts reflejan inmediatamente cambios de archivos del host.
- El contenido estático puede cambiar sin reiniciar Nginx.
- Los cambios de configuración requieren reload o restart para aplicarse.
- Un rollback debe terminar con una comprobación funcional, no solo con archivos restaurados.

## Nivel provisional

D0-A nivel 3: ejecución autónoma, diagnóstico correcto y recuperación exitosa, con errores operativos menores corregidos sin asistencia.

## Próximas mejoras

- Reducir la recuperación de configuración dañada a menos de dos minutos.
- Ejecutar el runbook sin errores de ubicación o sintaxis.
- Hacer que otro integrante recupere ambos incidentes usando solamente el runbook.
