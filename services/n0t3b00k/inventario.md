# Inventario del Servicio: n0t3b00k

Este documento cumple con el requisito "Inventario del servicio" de la ficha D0-A del PDF.

## 1. SO, IP, Usuarios y Recursos Principales
- **Sistema Operativo del Host**: Linux (Ubuntu/Debian genérico).
- **Sistema Operativo del Contenedor**: `python:3-alpine` (Alpine Linux ligero).
- **IP Local**: `127.0.0.1` (localhost).
- **Usuario del sistema (Host)**: Tu usuario actual (ej. `blob`).
- **Usuario del sistema (Contenedor)**: `service` (UID 1000), configurado en el `Dockerfile` por motivos de seguridad (no corre como root).
- **Persistencia (Recurso Principal)**: Los datos (usuarios, notas) se guardan en el volumen local `./data/`, montado en `/data` dentro del contenedor.

## 2. Proceso y PID
- **Proceso Principal**: `python3 src/n0t3b00k.py`.
- **PID**: Dentro del contenedor es el PID `1` (arrancado vía `entrypoint.sh`).

## 3. Puerto y Protocolo
- **Puerto Interno (Contenedor)**: `8000`
- **Puerto Externo (Host)**: `2323` (establecido en `docker-compose.yml`).
- **Protocolo**: TCP plano (raw sockets). Es un servicio interactivo de texto basado en comandos, NO es HTTP/Web.

## 4. Servicio o Contenedor Responsable
- **Gestor**: Docker Compose
- **Servicio en docker-compose**: `n0t3b00k`
- **Nombre típico del contenedor**: `service-n0t3b00k-1` o `n0t3b00k_service-n0t3b00k-1`

## 5. Archivos de Configuración y Variables Relevantes
- **`docker-compose.yml`**: Orquesta el contenedor, mapea el volumen `data` y los puertos.
- **`Dockerfile`**: Define el entorno (Alpine + Python), creación del usuario `service` y permisos.
- **`entrypoint.sh`**: Script de arranque que inicializa la base de datos de notas.
- **`src/n0t3b00k.py`**: El código fuente base del servicio.

## 6. Logs del Servicio
- **Cómo acceder a ellos**: Ya que corre en Docker, la forma correcta de ver los logs es a través del demonio de Docker.
- **Comando**: `cd service && docker-compose logs -f n0t3b00k`

## 7. Comprobación Funcional
Para comprobar que el servicio está activo y funciona correctamente, se usa un script TCP (ver Runbook) o interactivamente vía Netcat:
```bash
nc localhost 2323
```
Y comandos básicos: `reg user pass`, `log user pass`, `set test`.
