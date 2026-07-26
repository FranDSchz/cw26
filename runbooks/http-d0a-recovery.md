# Runbook de recuperación — HTTP D0-A

## Objetivo

Diagnosticar y recuperar el servicio HTTP D0-A ante:

- contenedor o proceso detenido;
- configuración de Nginx dañada;
- contenedor que no puede iniciar;
- pérdida o corrupción de los archivos del servicio.

## Información del servicio

- Archivo Compose: `services/http-d0a/compose.yaml`
- Servicio Compose: `web`
- Contenedor: `cw26-http-d0a`
- Puerto publicado: `8080`
- Puerto interno: `80`
- Endpoint principal: `http://localhost:8080/`
- Endpoint de salud: `http://localhost:8080/health`
- Configuración: `services/http-d0a/config/default.conf`
- Contenido: `services/http-d0a/site/index.html`
- Healthcheck: `scripts/healthcheck-http-d0a.sh`

## Estado conocido como bueno

Desde la raíz del repositorio:

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
echo "Código de salida: $?"
```

Resultado esperado:

```text
OK: funcionalidad principal y /health operativos
Código de salida: 0
```

Desde el directorio del servicio:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps
docker compose exec web nginx -t
```

El contenedor debe aparecer como `Up` y `nginx -t` debe indicar que la configuración es válida.

## Diagnóstico inicial

Ejecutar primero:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps --all
docker compose logs --tail=30 web
```

Después ejecutar el healthcheck:

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
echo "Código de salida: $?"
```

Interpretación inicial:

- `Up`: el contenedor está en ejecución.
- `Exited`: el contenedor está detenido.
- `Restarting`: el proceso falla repetidamente al iniciar.
- Código `0` del healthcheck: funcionalidad aprobada.
- Código distinto de `0`: servicio no disponible o funcionalidad incorrecta.

## Incidente 1 — Contenedor detenido

### Síntomas

- El contenedor aparece como `Exited`.
- El puerto `8080` no responde.
- El healthcheck informa que no puede consultar la funcionalidad principal.

### Confirmación

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps --all
```

```bash
curl -i --max-time 3 http://localhost:8080/
```

### Recuperación principal

Si el contenedor existe y solamente está detenido:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose start web
docker compose ps
```

### Alternativa

Si el contenedor no existe, no inicia correctamente o debe reconciliarse con `compose.yaml`:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose up -d web
docker compose ps
```

### Verificación

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
echo "Código de salida: $?"
```

La recuperación termina únicamente cuando el healthcheck devuelve código `0`.

## Incidente 2 — Configuración de Nginx dañada

### Posibles síntomas

- `nginx -t` informa un error de sintaxis.
- Los logs indican un archivo y una línea concreta.
- El contenedor aparece como `Restarting` o `Exited`.
- El healthcheck devuelve un código distinto de `0`.

### Observación importante

El archivo de configuración puede estar dañado en disco mientras Nginx continúa funcionando con la configuración válida que cargó anteriormente en memoria.

Por eso deben comprobarse por separado:

1. la validez del archivo con `nginx -t`;
2. la funcionalidad real con el healthcheck.

### Diagnóstico

Si el contenedor permanece en ejecución:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose exec web nginx -t
```

En todos los casos:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps --all
docker compose logs --tail=30 web
```

Revisar el cambio local:

```bash
cd ~/cyberwar/cw26
git diff -- services/http-d0a/config/default.conf
```

### Restauración mediante Git

Restaurar la última versión confirmada del archivo:

```bash
cd ~/cyberwar/cw26
git restore services/http-d0a/config/default.conf
```

Confirmar que ya no existan diferencias en ese archivo:

```bash
git diff -- services/http-d0a/config/default.conf
```

Si no aparece ninguna salida, el archivo coincide con la versión almacenada en Git.

### Levantar el servicio

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose stop web
docker compose up -d web
docker compose ps
```

Validar la configuración:

```bash
docker compose exec web nginx -t
```

### Verificación funcional

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
echo "Código de salida: $?"
```

La recuperación termina únicamente cuando:

- el contenedor aparece como `Up`;
- `nginx -t` es exitoso;
- el healthcheck devuelve código `0`.

## Rollback desde backup

### Backup conocido como bueno

```text
~/cyberwar/backups/http-d0a-known-good.tar.gz
```

### Verificar el backup

```bash
sha256sum ~/cyberwar/backups/http-d0a-known-good.tar.gz
```

Hash conocido:

```text
f61125896e4b277f6bd2b0ee5e9fc8eb379c137791fb7e0965722d99281443e5
```

Si el hash no coincide, no asumir que el backup es confiable.

### Restaurar

Detener primero el servicio:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose stop web
```

Extraer el backup dentro del directorio del servicio:

```bash
cd ~/cyberwar/cw26/services/http-d0a
tar -xzf ~/cyberwar/backups/http-d0a-known-good.tar.gz
```

Levantar y validar:

```bash
docker compose up -d web
docker compose exec web nginx -t
```

Ejecutar la comprobación funcional:

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
echo "Código de salida: $?"
```

## Fallo de montaje o runtime de Docker

### Síntomas

- El archivo de configuración existe y es válido.
- Docker no puede iniciar el contenedor.
- Aparecen errores relacionados con `mount`, `OCI runtime`, `runc` o inicialización del contenedor.

### Diagnóstico

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps --all
docker compose config
docker compose logs --tail=30 web
```

Confirmar que existen los directorios montados:

```bash
ls -la config
ls -la site
```

### Recreación controlada

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose down
docker compose up -d web
```

Después:

```bash
docker compose ps
docker compose exec web nginx -t
```

Y finalmente:

```bash
cd ~/cyberwar/cw26
./scripts/healthcheck-http-d0a.sh
```

`docker compose down` elimina el contenedor y la red del proyecto. Debe utilizarse con cuidado si existen datos no persistidos o componentes adicionales.

## Diferencia entre comandos de recuperación

### `docker compose start web`

Inicia un contenedor existente que se encuentra detenido.

No crea un contenedor nuevo.

### `docker compose restart web`

Detiene y vuelve a iniciar el contenedor existente.

No soluciona necesariamente configuraciones de montaje o metadatos dañados.

### `docker compose up -d web`

Intenta alcanzar el estado definido en `compose.yaml`.

Puede crear, iniciar o recrear el contenedor según sea necesario.

### `docker compose down`

Elimina los contenedores y la red del proyecto Compose.

Se utiliza cuando es necesario reconstruir el entorno, pero puede aumentar el tiempo de caída.

## Errores frecuentes

### Compose ejecutado desde el directorio incorrecto

Error:

```text
no configuration file provided: not found
```

Solución:

```bash
cd ~/cyberwar/cw26/services/http-d0a
docker compose ps
```

### Ruta incorrecta en Git

Ruta correcta:

```text
services/http-d0a/config/default.conf
```

Restauración correcta:

```bash
git restore services/http-d0a/config/default.conf
```

### Sintaxis incorrecta de `git diff`

Incorrecto:

```bash
git --diff
```

Correcto:

```bash
git diff
```

### Orden incorrecto en `docker compose exec`

Incorrecto:

```bash
docker compose exec nginx -t web
```

Correcto:

```bash
docker compose exec web nginx -t
```

`web` es el servicio Compose. `nginx -t` es el comando ejecutado dentro del contenedor.

### Ruta incorrecta del script

Incorrecto:

```bash
.scripts/healthcheck-http-d0a.sh
```

Correcto:

```bash
./scripts/healthcheck-http-d0a.sh
```

## Criterio de recuperación completa

El incidente se considera resuelto únicamente cuando se cumplen todas estas condiciones:

1. El contenedor aparece como `Up`.
2. El puerto `8080` está publicado.
3. `nginx -t` es exitoso.
4. La página principal contiene el texto esperado.
5. `/health` devuelve exactamente `ok`.
6. El healthcheck termina con código `0`.
7. El cambio o rollback realizado queda identificado.
8. El tiempo y los errores se registran para mejorar el procedimiento.

## Resultados obtenidos durante D0-A

### Contenedor detenido — ejecución guiada

- Tiempo: 12,98 segundos.
- Resultado: recuperado.
- Ayuda: comando de validación proporcionado.

### Contenedor detenido — replay autónomo

- Tiempo: 1 minuto 52 segundos.
- Ayudas: ninguna.
- Resultado: recuperado.
- Error menor: primera solicitud realizada contra `/healt` en lugar de `/health`.

### Configuración dañada — primera ejecución

- Tiempo: 7 minutos 13 segundos.
- Resultado: recuperado.
- Ayuda: consulta externa ante un fallo del runtime de Docker.
- Incidencia adicional: bind mount individual del archivo.
- Solución: recreación mediante `docker compose down` y `up`.

### Configuración dañada — replay autónomo

- Tiempo: 3 minutos 38 segundos.
- Ayudas: ninguna.
- Resultado: configuración restaurada, Nginx válido y healthcheck con código `0`.
- Errores menores:
  - `git --diff` en lugar de `git diff`;
  - Compose ejecutado desde el directorio incorrecto;
  - orden incorrecto en `docker compose exec`.

## Próxima mejora

- Reducir la recuperación de configuración dañada a menos de dos minutos.
- Ejecutar el procedimiento siguiendo únicamente este runbook.
- Hacer que otro integrante recupere el servicio sin ayuda del autor.
- Convertir el diagnóstico inicial en una secuencia más breve y repetible.
