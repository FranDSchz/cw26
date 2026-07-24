#!/bin/bash

# Script de respaldo para n0t3b00k

cd "/home/blob/dev/active projects/enowars-service-example/service" || exit

echo "[+] Creando directorio de respaldos si no existe..."
mkdir -p backups

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

echo "[+] Comprimiendo estado actual (código fuente y datos)..."
# Resguardamos src/ (código), Dockerfile, docker-compose.yml y data/ (la DB de persistencia)
tar -czf "backups/$BACKUP_NAME" src/ Dockerfile docker-compose.yml data/

echo "[+] Backup $BACKUP_NAME creado exitosamente en la carpeta backups/"
ls -lah "backups/$BACKUP_NAME"
