# Cierre de módulo — D0-A

## Estado general

- Módulo: D0-A — procesos, puertos, servicios, configuración, logs y recuperación.
- Estado individual de Franco: completado.
- Nivel provisional: 3/4.
- Estado grupal: parcial.
- PR técnico: #3.
- D0-B: no iniciado.

## Trabajo realizado

### Fundamentos Attack/Defense

Se construyó y documentó el modelo mental de:

- servicio;
- flag;
- checker;
- gameserver;
- vulnbox;
- rondas o ticks;
- SLA y disponibilidad;
- flags rotativas;
- flujos ofensivo y defensivo;
- necesidad de automatizar ataques repetibles.

Evidencia:

- `rules/attack-defense.md`
- PR #2 fusionado.

### Entorno

Se verificó:

- Ubuntu 24.04 sobre WSL2;
- Git;
- Python;
- Docker;
- Docker Compose;
- curl;
- ejecución de contenedores.

Evidencia:

- `evidence/2026-07-25/franco-entorno.md`

### Laboratorio HTTP

Se creó un servicio reproducible con:

- Nginx;
- Docker Compose;
- puerto publicado `8080`;
- puerto interno `80`;
- configuración montada;
- contenido estático montado;
- endpoint `/`;
- endpoint `/health`.

Artefactos:

- `services/http-d0a/compose.yaml`
- `services/http-d0a/config/default.conf`
- `services/http-d0a/site/index.html`

### Healthcheck

Se creó un healthcheck que:

- aplica timeout;
- falla ante errores HTTP o de conexión;
- valida contenido funcional;
- valida `/health`;
- genera mensajes inequívocos;
- utiliza códigos de salida.

Artefacto:

- `scripts/healthcheck-http-d0a.sh`

### Runbook

Se documentaron procedimientos para:

- contenedor detenido;
- configuración dañada;
- restauración mediante Git;
- rollback desde backup;
- fallo de montaje o runtime;
- recreación controlada;
- validación funcional posterior.

Artefacto:

- `runbooks/http-d0a-recovery.md`

## Resultados de las recuperaciones

### Contenedor detenido — ejecución guiada

- Tiempo: 12,98 segundos.
- Ayuda: comando de validación proporcionado.
- Resultado: recuperado.

### Contenedor detenido — replay autónomo

- Tiempo: 1 minuto 52 segundos.
- Ayudas: ninguna.
- Resultado: recuperado.
- Error menor: solicitud inicial a `/healt` en vez de `/health`.

### Configuración dañada — primera ejecución

- Tiempo: 7 minutos 13 segundos.
- Ayuda: consulta externa por un fallo adicional del runtime de Docker.
- Resultado: recuperado.
- Incidente adicional: fallo del bind mount individual.

### Configuración dañada — replay autónomo

- Tiempo: 3 minutos 38 segundos.
- Ayudas: ninguna.
- Resultado: recuperado.
- Errores operativos:
  - `git --diff` en vez de `git diff`;
  - Compose ejecutado desde una ubicación incorrecta;
  - orden incorrecto en `docker compose exec`.

### Rollback desde backup

- Se dañó deliberadamente `site/index.html`.
- El healthcheck detectó la pérdida funcional y devolvió código 3.
- El backup sobrescribió los archivos dañados.
- Nginx y el healthcheck volvieron al estado correcto.
- Resultado: restauración comprobada.

## Conceptos aprendidos

### Servicio, proceso y funcionalidad

- Un proceso es una instancia de un programa en ejecución.
- Un servicio es la capacidad ofrecida a un cliente.
- Un proceso activo no garantiza que el servicio funcione.
- Un puerto abierto tampoco garantiza funcionalidad.
- La verificación debe comprobar resultados reales.

### Puertos y Docker

La publicación `8080:80` significa:

- puerto `8080` en el host;
- puerto `80` dentro del contenedor.

Recorrido:

cliente → host:8080 → redirección de Docker → contenedor:80 → Nginx.

### Procesos y PID

- Nginx master aparece como PID 1 dentro del contenedor.
- El mismo proceso tiene otro PID visto desde el host.
- Los worker processes dependen del master.

### Configuración y contenido

- Nginx carga la configuración al iniciar o recargar.
- Modificar `default.conf` no cambia inmediatamente la configuración activa.
- El contenido estático se consulta al atender cada solicitud.
- Un cambio en `index.html` montado mediante bind mount se refleja inmediatamente.

### Bind mounts

- El host y el contenedor observan el mismo directorio montado.
- `:ro` impide que el contenedor escriba, pero no que el host modifique.
- Montar el directorio completo resultó más robusto que montar un archivo individual.

### Recuperación

- `docker compose start`: inicia un contenedor existente detenido.
- `docker compose restart`: detiene y vuelve a iniciar el contenedor existente.
- `docker compose up -d`: crea, inicia o recrea para alcanzar el estado del Compose.
- `docker compose down`: elimina contenedores y red del proyecto.
- Todo cambio debe finalizar con una prueba funcional.

### Backup y rollback

- `tar -xzf` restaura porque extrae y sobrescribe rutas existentes.
- Restaurar archivos no basta: debe validarse configuración y funcionalidad.
- El backup actual tiene hash:

`f61125896e4b277f6bd2b0ee5e9fc8eb379c137791fb7e0965722d99281443e5`

## Errores que no deben repetirse

- Ejecutar Compose fuera del directorio que contiene `compose.yaml`.
- Confundir el orden de servicio y comando en `docker compose exec`.
- Usar `git --diff` en vez de `git diff`.
- Confundir `/health` con rutas similares.
- Considerar un `200` o un puerto abierto como prueba funcional suficiente.
- Modificar una configuración sin ejecutar primero una validación.
- Hacer cambios sin mantener rollback.

## Estado pendiente

### Pendientes grupales

- D0-A de Philippe.
- D0-A de Mati.
- Ejecución cruzada del runbook por otro integrante.
- Registrar sus tiempos, ayudas y errores.
- Corregir el runbook si otro integrante encuentra pasos ambiguos.

### Pendientes administrativos

- Fusionar PR #3.
- Actualizar el Excel operativo.
- Solicitar el rebase del plan desde el 26/07.
- Crear el nuevo chat tutor para D0-B.

## Parking Lot

### Internals de contenedores y namespaces

- Apareció al comparar PID interno y PID del host.
- No es necesario profundizar para D0-A.
- Retomar cuando se estudie aislamiento de contenedores.

### Networking interno de Docker

- Apareció al observar `172.18.0.2`.
- Impacto futuro: diagnóstico y conexión entre servicios.
- Retomar durante D0-B o Docker multi-container.

### Healthchecks más avanzados

- Reintentos.
- Métricas.
- JSON.
- Integración con varios servicios.
- Retomar en el módulo de automatización y observabilidad.

### Persistencia y backups de bases de datos

- El laboratorio solo utilizó archivos estáticos.
- Requiere procedimientos de consistencia diferentes.
- Retomar al trabajar con servicios con base de datos.

## Carga registrada

- 24/07: 9 horas netas aproximadas.
- 25/07: 9 horas netas aproximadas.
- Madrugada del 26/07: 1 hora neta aproximada.
- Total del módulo hasta el cierre: 19 horas netas aproximadas.

## Recuperación

- Sueño previo: aproximadamente 9 horas, de 05:00 a 14:00.
- Energía al cierre: 2,5/5.
- Decisión: no iniciar D0-B durante la madrugada.
- Próximo descanso previsto: 04:00–11:00.

## Próxima acción exacta

1. Actualizar el Excel operativo.
2. Fusionar el PR #3.
3. Pedir al planificador un rebase desde el estado actual.
4. Abrir un nuevo chat tutor.
5. Comenzar D0-B: redes, HTTP, curl, tráfico y script corto.
