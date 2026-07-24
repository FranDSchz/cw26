# Runbook: Recuperación de n0t3b00k

## 1. Cuándo usarlo
Este runbook debe utilizarse en las siguientes situaciones:
- El servicio "n0t3b00k" aparece como `DOWN` en el dashboard de ENOWARS.
- El comando de comprobación manual (test) falla.
- Sospechas que los archivos del servicio (`src/`, `Dockerfile`, `docker-compose.yml`) o los datos (`data/`) han sido modificados por un atacante y quieres volver a un estado estable.
- Necesitas investigar errores que se están registrando en el servicio.

## 2. Estado Conocido como Bueno (Known Good State)
El estado conocido y funcional está documentado en los archivos comprimidos dentro de la carpeta `backups/`.
- **Ruta de backups**: `/home/blob/dev/active projects/enowars-service-example/service/backups/`
- Antes de aplicar cualquier modificación manual, se debe correr `./crear_backup.sh` para resguardar el estado actual.

## 3. Evidencia y Logs
Para diagnosticar qué está fallando o capturar evidencia, ejecuta estos comandos desde la carpeta del servicio (`cd "/home/blob/dev/active projects/enowars-service-example/service"`):

> [!NOTE]
> Captura la salida de estos comandos si necesitas reportar el error o pedir ayuda (nivel D0).

**Ver estado de contenedores:**
```bash
docker-compose ps
```

**Ver logs del servicio (últimas 100 líneas):**
```bash
docker-compose logs --tail=100 -f n0t3b00k
```

## 4. Comprobación Funcional
Para verificar si el servicio está operativo y procesando los comandos correctamente:

**Rápida (manual con netcat):**
```bash
nc localhost 2323
```
*Se espera que el servicio salude con `Welcome to the 1337 n0t3b00k!`*

**Test Automático (Script Python):**
Puedes utilizar el script que comprueba todos los endpoints (`reg`, `log`, `set`, `list`).
```bash
python3 /tmp/test_service.py
```
*(Asegúrate de que este script exista o guárdalo permanentemente en el entorno).*

## 5. Pasos exactos de Recuperación (Restart y Rebuild)

**Opción A: El contenedor se detuvo o colgó (Recuperación simple)**
```bash
cd "/home/blob/dev/active projects/enowars-service-example/service"
docker-compose restart n0t3b00k
```

**Opción B: Se modificó la configuración (Rebuild)**
```bash
cd "/home/blob/dev/active projects/enowars-service-example/service"
docker-compose up --build -d
```

## 6. Rollback (Restaurar desde un Backup)

> [!WARNING]
> Hacer rollback a un estado anterior sobreescribirá el código actual y/o la base de datos de persistencia en `data/`.

Si el servicio fue vulnerado de forma irremediable, o metiste un parche (patch) que rompió la funcionalidad (el checker no pasa):

1. **Localiza el último backup bueno:**
   ```bash
   cd "/home/blob/dev/active projects/enowars-service-example/service"
   ls -lah backups/
   ```
2. **Apaga el servicio:**
   ```bash
   docker-compose down
   ```
3. **Restaura los archivos (reemplaza `backup_NOMBRE.tar.gz` por el archivo correcto):**
   ```bash
   tar -xzf backups/backup_NOMBRE.tar.gz
   ```
4. **Levanta nuevamente el servicio:**
   ```bash
   docker-compose up --build -d
   ```
5. **Verifica funcionalidad:** (Punto 4 de este runbook).

## 7. Validaciones
- **Validado por:** (Dejar en blanco para que lo firme un compañero en la prueba cruzada)
- **Fecha y Tiempo:** (Rellenar durante la prueba cruzada)
