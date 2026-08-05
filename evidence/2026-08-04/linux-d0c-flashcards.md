# Flashcards selectivas — Linux operativo y D0-C

Estas tarjetas cubren únicamente conocimientos con transferencia directa a una
competencia Attack/Defense. No intentan convertir cada opción de cada comando en
memoria obligatoria.

## Cómo priorizarlas

- **P0:** debe poder recuperarse bajo presión. Incorporar a Anki ahora.
- **P1:** importante, pero puede apoyarse en una chuleta. Incorporar después de
  estabilizar P0.
- **P2:** contexto útil. Mantener suspendida salvo que aparezca una brecha real.

Clases:

- **FLUIDEZ:** decisión, relación o comando corto que debe salir con poca ayuda.
- **CONCEPTUAL:** debe poder explicarse y aplicarse; no exige recitar sintaxis.
- **REFERENCIA:** debe reconocerse y saberse cuándo consultarlo; no memorizar la
  línea completa.

Carga inicial recomendada: las 35 tarjetas P0. No activar P1 y P2 el mismo día.

---

## P0 — modelos y decisiones

### F01 — Programa y proceso

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `proceso` `p0`
- Pregunta: ¿Cuál es la diferencia entre un programa y un proceso?
- Respuesta: Un programa es código almacenado. Un proceso es una instancia de
  ese programa en ejecución, con PID, identidad, memoria, estado y recursos
  administrados por el kernel.

### F02 — Proceso, listener y servicio

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `servicio` `listener` `p0`
- Pregunta: ¿Cómo se diferencian proceso, listener y servicio?
- Respuesta: El proceso ejecuta código; el listener TCP es un socket del kernel
  preparado para aceptar conexiones; el servicio es la capacidad funcional
  ofrecida. Un proceso puede existir sin listener y un listener no demuestra que
  la función sea correcta.

### F03 — Unidad y proceso

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `systemd` `p0`
- Pregunta: ¿Qué relación existe entre una unidad de systemd y un proceso?
- Respuesta: La unidad describe cómo systemd administra un recurso y puede
  iniciar o supervisar procesos. No son el mismo objeto: hay que verificar la
  unidad, su Main PID y los procesos reales.

### F04 — Active no equivale a funcional

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::diagnostico` `systemd` `p0`
- Pregunta: ¿Por qué `active (running)` no demuestra que el servicio funciona de
  extremo a extremo?
- Respuesta: Solo demuestra el estado que systemd conoce y que existe ejecución.
  Todavía pueden fallar el bind, la configuración, una dependencia, los datos o
  la función que valida el checker.

### F05 — Última etapa demostrada

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::diagnostico` `capas` `p0`
- Pregunta: ¿Qué significa buscar la última etapa demostrada?
- Respuesta: Identificar hasta dónde existe evidencia real —DNS, ruta, listener,
  TCP, protocolo, status o contenido— y comenzar a investigar inmediatamente
  después. Evita reparar una capa que ya funcionó.

### F06 — Recorrido diagnóstico

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::diagnostico` `recuperacion` `p0`
- Pregunta: ¿Cuál es el recorrido mental mínimo ante un fallo?
- Respuesta: Síntoma → última etapa demostrada → hipótesis → prueba discriminante
  → cambio mínimo → checker completo → evidencia → handoff.

### F07 — Prueba discriminante

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::diagnostico` `hipotesis` `p0`
- Pregunta: ¿Qué es una prueba discriminante?
- Respuesta: Una observación elegida para separar hipótesis competidoras. Debe
  cambiar la decisión siguiente; no es ejecutar comandos por costumbre.

### F08 — Arquitectura y binarios

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `arquitectura` `explotacion` `p0`
- Pregunta: ¿Por qué importa distinguir `x86_64` de `arm64` en Attack/Defense?
- Respuesta: Un binario compilado para una ISA normalmente no ejecuta en la otra.
  La arquitectura condiciona herramientas, exploits y payloads; 64 bits no
  significa automáticamente ARM64.

### F09 — Portabilidad de scripts

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `scripts` `explotacion` `p0`
- Pregunta: ¿Por qué un script de Python suele ser más portable que un binario?
- Respuesta: El intérprete traduce el script para la arquitectura local. Aun así,
  depende de que Python, las librerías y las llamadas utilizadas estén
  disponibles y sean compatibles.

### F10 — Memoria disponible

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `memoria` `p0`
- Pregunta: En `free`, ¿por qué `available` suele ser más útil que `free`?
- Respuesta: `available` estima cuánta memoria puede usarse sin presión severa e
  incluye caché recuperable. `free` solo muestra RAM completamente sin usar. No
  es una garantía rígida para un único proceso.

### F11 — Matar por RSS

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `procesos` `memoria` `p0`
- Pregunta: ¿Por qué no hay que matar automáticamente el proceso con mayor RSS?
- Respuesta: Ser el mayor consumidor no demuestra presión ni anomalía. Primero se
  compara con `available`, la función del proceso, su evolución y los logs.

### F12 — Riesgo de filesystem lleno

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `filesystem` `disponibilidad` `p0`
- Pregunta: ¿Cómo puede un filesystem lleno romper un servicio que sigue activo?
- Respuesta: Puede impedir escribir logs, flags, temporales o estado. El proceso
  puede seguir ejecutándose mientras la función falla, afectando checker y SLA.

### F13 — Identidad y grupos

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `permisos` `p0`
- Pregunta: ¿Qué demuestra `id` y qué no demuestra?
- Respuesta: Muestra UID, GID principal y grupos adicionales. Sugiere capacidades,
  pero no demuestra cada permiso efectivo ni la política concreta de sudo,
  Docker, ACL u otros controles.

### F14 — Grupos privilegiados

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `privilegios` `p0`
- Pregunta: ¿Qué riesgos sugieren los grupos `sudo`, `docker` y `adm`?
- Respuesta: `sudo` puede permitir ejecutar como otra identidad según sudoers;
  `docker` suele implicar control altamente privilegiado, a menudo equivalente a
  root; `adm` suele permitir leer ciertos logs, no administrar todo el sistema.

### F15 — `x` en archivo y directorio

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `permisos` `p0`
- Pregunta: ¿Qué significa `x` sobre un archivo y sobre un directorio?
- Respuesta: En un archivo permite solicitar ejecución, pero no garantiza que
  funcione. En un directorio permite atravesarlo y acceder a entradas conocidas;
  no equivale simplemente a “ejecutar la carpeta”.

### F16 — Ruta no es conectividad

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::red` `ruta` `p0`
- Pregunta: ¿Qué demuestra `ip route get DESTINO` y qué no demuestra?
- Respuesta: Demuestra la decisión configurada del kernel: interfaz, gateway y
  origen. No envía una prueba funcional ni demuestra gateway, TCP o aplicación.

### F17 — Bind local y global

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::red` `listener` `p0`
- Pregunta: ¿Cómo cambia el alcance entre `127.0.0.1:8080` y `0.0.0.0:8080`?
- Respuesta: `127.0.0.1` liga el socket a loopback; `0.0.0.0` lo liga a todas las
  direcciones IPv4 locales. Se interpreta `Local Address`, no `Peer Address`.

### F18 — Loopback UNKNOWN

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::red` `loopback` `p0`
- Pregunta: Si `lo` aparece `UNKNOWN` pero tiene `127.0.0.1`, ¿puede declararse
  inactiva?
- Respuesta: No. Ese campo no basta para declararla inactiva; se consideran sus
  direcciones, rutas y pruebas locales reales.

### F19 — TCP y UDP en `ss`

- Prioridad: **P0**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::red` `tcp` `udp` `p0`
- Pregunta: ¿Por qué TCP aparece como `LISTEN` y UDP suele aparecer `UNCONN`?
- Respuesta: TCP acepta conexiones y mantiene estado. UDP liga un socket y recibe
  datagramas sin handshake ni estado TCP `LISTEN`/`ESTAB`.

### F20 — Cero unidades fallidas

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::systemd` `diagnostico` `p0`
- Pregunta: ¿Qué demuestra `systemctl --failed` sin resultados?
- Respuesta: Que systemd no marca unidades como fallidas en ese momento. No
  demuestra que todos los servicios sean funcionales ni que sus datos sean
  correctos.

### F21 — Evento de journal

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::logs` `diagnostico` `p0`
- Pregunta: ¿Qué demuestra un evento encontrado en `journalctl`?
- Respuesta: Que el journal registró un mensaje atribuido a una fuente y momento.
  No demuestra por sí solo causa raíz ni función end-to-end.

### F22 — Healthcheck y checker

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::checker` `disponibilidad` `p0`
- Pregunta: ¿Cuál es la diferencia entre healthcheck y checker?
- Respuesta: El healthcheck valida una condición limitada. El checker representa
  un contrato funcional más completo, por ejemplo health más recuperación y
  validación de una flag. Ambos solo demuestran lo que implementan.

### F23 — Códigos del checker D0-C

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::checker` `exit-code` `p0`
- Pregunta: ¿Qué significan los exits 0, 2, 3, 4 y 5 del checker D0-C?
- Respuesta: 0 servicio y flag correctos; 2 falta la flag esperada; 3 falla la
  función base; 4 no puede recuperarse la flag; 5 la flag recuperada no coincide.

### F24 — Exit compartido, causas distintas

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::checker` `diagnostico` `p0`
- Pregunta: Si dos incidentes producen exit 3, ¿cómo se distingue la causa?
- Respuesta: El código clasifica la etapa, no la causa raíz. Se comparan URL del
  checker, estado y publicación del contenedor, listener real, error de curl y
  logs de la aplicación.

### F25 — Connection refused

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::red` `tcp` `diagnostico` `p0`
- Pregunta: ¿Qué sugiere `Connection refused` o curl exit 7?
- Respuesta: Se intentó TCP contra un endpoint que rechazó o no tenía listener.
  Investigar proceso, contenedor, puerto, bind y publicación antes de la lógica
  HTTP.

### F26 — Timeout después de conectar

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::http` `timeout` `diagnostico` `p0`
- Pregunta: Si TCP conectó pero la respuesta hace timeout, ¿qué zona se investiga?
- Respuesta: Aplicación, dependencias, bloqueos y recursos. En ataque, el runner
  debe registrar y continuar; un objetivo no puede congelar el barrido.

### F27 — HTTP 404

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::http` `diagnostico` `p0`
- Pregunta: ¿Qué queda demostrado al recibir HTTP 404?
- Respuesta: La red, TCP y HTTP funcionaron lo suficiente para recibir respuesta.
  El recurso o ruta no apareció; investigar método, URI, Host, rutas, archivos y
  configuración, no reiniciar la red primero.

### F28 — HTTP 200 incorrecto

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::http` `funcion` `p0`
- Pregunta: ¿Qué significa HTTP 200 con body o flag incorrectos?
- Respuesta: Transporte y HTTP funcionaron, pero la semántica, lógica o datos no.
  El checker debe fallar aunque el status sea 200.

### F29 — Recuperación demostrada

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::recuperacion` `checker` `p0`
- Pregunta: ¿Cuándo se considera recuperado un incidente?
- Respuesta: Cuando el cambio mínimo fue aplicado, el estado se reobservó y el
  checker funcional completo vuelve a PASS. Archivo restaurado, contenedor Up o
  listener presente no bastan.

### F30 — Secretos y logs

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::seguridad` `flags` `ia` `p0`
- Pregunta: ¿Qué datos no deben imprimirse en logs ni enviarse a una IA externa?
- Respuesta: Flags reales, credenciales, cookies, tokens, claves, `.env`, VPN,
  targets privados, topología, source o capturas sensibles del evento.

### F31 — Orden del inventario

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::linux` `inventario` `p0`
- Pregunta: ¿Cuál es el orden mental del inventario Linux de 10 minutos?
- Respuesta: Host/contexto → identidad → recursos/filesystem → interfaces/rutas →
  procesos/unidades → sockets/listeners → configuración/permisos → logs → checker.

### F32 — Comando `id`

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `identidad` `p0`
- Pregunta: ¿Qué objeto observa `id` y qué buscás en su salida?
- Respuesta: La identidad efectiva del operador: UID, GID principal y grupos.
  Sirve para anticipar permisos y riesgos antes de leer, ejecutar o modificar.

### F33 — Comando `free -h`

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `memoria` `p0`
- Pregunta: ¿Para qué usás `free -h` durante una ronda?
- Respuesta: Para observar RAM, `available` y swap y decidir si existe presión
  inmediata. Es una fotografía: si hay sospecha, se investiga por proceso y logs.

### F34 — Comando `df -hT /`

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `filesystem` `p0`
- Pregunta: ¿Qué comprueba `df -hT /`?
- Respuesta: Tipo, tamaño, uso y espacio disponible del filesystem que contiene
  `/`. No identifica qué directorio consume espacio; para eso se profundiza con
  `du` de forma acotada.

### F35 — Comando `ip -br addr`

- Prioridad: **P0**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `red` `p0`
- Pregunta: ¿Qué objeto observa `ip -br addr`?
- Respuesta: Interfaces, estado informado y direcciones asignadas. No demuestra
  rutas, conectividad, listener ni función.

---

## P1 — comandos y profundización operativa

### F36 — Comando `hostname`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `host` `p1`
- Pregunta: ¿Qué aporta `hostname` al inventario?
- Respuesta: El nombre configurado del host, útil para contexto, prompts y
  correlación de logs. No identifica por sí solo distribución, IP ni servicio.

### F37 — `/etc/os-release`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `distro` `p1`
- Pregunta: ¿Qué buscás en `cat /etc/os-release`?
- Respuesta: Distribución, versión, familia y codename para elegir paquetes,
  rutas y procedimientos compatibles. No demuestra la versión del kernel.

### F38 — `uname -r` y `uname -m`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `kernel` `arquitectura` `p1`
- Pregunta: ¿Qué diferencia hay entre `uname -r` y `uname -m`?
- Respuesta: `-r` muestra el release del kernel; `-m`, la arquitectura de máquina.
  Sirven para compatibilidad y contexto, no para declarar una vulnerabilidad.

### F39 — Tiempo y uptime

- Prioridad: **P1**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `tiempo` `logs` `p1`
- Pregunta: ¿Por qué registrar zona horaria y uptime antes de correlacionar logs?
- Respuesta: Para convertir timestamps al mismo instante y distinguir eventos
  anteriores o posteriores al arranque. Uptime del host no demuestra uptime de
  un servicio.

### F40 — `date -Is`, `timedatectl` y `uptime`

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `tiempo` `p1`
- Pregunta: ¿Cuándo usar `date -Is`, `timedatectl` y `uptime -p/-s`?
- Respuesta: `date -Is` registra instante y offset; `timedatectl`, zona y
  sincronización; `uptime`, duración e inicio del entorno. La sintaxis exacta
  puede consultarse.

### F41 — `ip route` e `ip route get`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `ruta` `p1`
- Pregunta: ¿Cuándo usás `ip route` y cuándo `ip route get DESTINO`?
- Respuesta: `ip route` muestra la tabla; `ip route get` pregunta qué decisión
  tomaría el kernel para un destino concreto. Ninguno prueba conectividad real.

### F42 — `sudo ss -lntup`

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `listener` `p1`
- Pregunta: ¿Qué buscás con `sudo ss -lntup`?
- Respuesta: Sockets TCP en escucha y UDP ligados, direcciones locales, puertos y
  procesos cuando son atribuibles. Las letras exactas pueden consultarse; lo
  obligatorio es interpretar `Local Address` y los límites.

### F43 — Proceso sin atribuir en `ss`

- Prioridad: **P1**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::red` `procesos` `p1`
- Pregunta: Si `ss` muestra un socket sin proceso, ¿qué concluís?
- Respuesta: El socket fue observado, pero su dueño no quedó atribuido por esa
  salida. Revisar privilegios, PID/FD, contenedor o namespace; no inventar un
  proceso responsable.

### F44 — `ps` para procesos

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `procesos` `p1`
- Pregunta: ¿Qué campos importan en un listado `ps` de diagnóstico?
- Respuesta: PID, PPID, usuario, estado, memoria/RSS, nombre corto y argumentos.
  La línea exacta y el ordenamiento son REFERENCIA; importa relacionar identidad,
  padre, consumo y comando real.

### F45 — `COMM`, `args` y unidad

- Prioridad: **P1**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::procesos` `systemd` `p1`
- Pregunta: ¿Por qué pueden diferir `COMM`, `args` y el nombre de una unidad?
- Respuesta: `COMM` es el nombre corto del proceso, `args` muestra su invocación y
  la unidad es el objeto administrativo de systemd, normalmente con sufijo como
  `.service`.

### F46 — `systemctl status UNIDAD --no-pager`

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `systemd` `p1`
- Pregunta: ¿Qué extraés de `systemctl status UNIDAD --no-pager`?
- Respuesta: Si fue encontrada y cargada, estado exacto, Main PID, momento de
  activación y mensajes recientes. No demuestra la función completa.

### F47 — `journalctl -u UNIDAD -b -n 20`

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `logs` `p1`
- Pregunta: ¿Qué limita cada parte de `journalctl -u UNIDAD -b -n 20`?
- Respuesta: `-u` filtra una unidad, `-b` el boot actual y `-n 20` las últimas 20
  entradas. `--no-pager` evita el paginador. La sintaxis es consultable; hay que
  elegir una fuente relevante.

### F48 — Journal y logs de Compose

- Prioridad: **P1**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::logs` `docker` `p1`
- Pregunta: ¿Son `journalctl` y `docker compose logs` los mismos logs?
- Respuesta: No necesariamente. Journal reúne eventos del sistema y fuentes
  integradas; Compose muestra stdout/stderr de contenedores del proyecto. Se
  selecciona la fuente según el objeto investigado.

### F49 — `getent ahostsv4 NOMBRE`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `dns` `p1`
- Pregunta: ¿Qué demuestra `getent ahostsv4 example.com` con exit 0 y direcciones?
- Respuesta: Que el resolver configurado obtuvo IPv4 para el nombre. No demuestra
  ruta real, TCP, HTTP ni función del destino.

### F50 — Curl funcional con timeout

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `http` `p1`
- Pregunta: ¿Qué aporta `curl --fail --silent --show-error --max-time 3 URL`?
- Respuesta: Limita tiempo, conserva errores, falla ante HTTP 4xx/5xx y permite
  automatización. Todavía debe validarse el contenido. Las opciones exactas son
  REFERENCIA; timeout y validación son FLUIDEZ.

### F51 — Estado de Docker Compose

- Prioridad: **P1**
- Clase: **REFERENCIA**
- Etiquetas: `cw26::comandos` `docker` `p1`
- Pregunta: ¿Qué buscás en `docker compose -f ARCHIVO ps --all`?
- Respuesta: Estado de contenedores, servicio y publicación de puertos del
  proyecto. Un contenedor Up no demuestra que la aplicación o checker funcionen.

### F52 — Permisos con `ls -l` y `ls -ld`

- Prioridad: **P1**
- Clase: **FLUIDEZ**
- Etiquetas: `cw26::comandos` `permisos` `p1`
- Pregunta: ¿Cuándo usar `ls -l OBJETO` y `ls -ld DIRECTORIO`?
- Respuesta: `ls -l` observa metadatos del objeto; `-d` evita listar el contenido
  y muestra el directorio mismo. Interpretar tipo, owner, grupo y bits; ACL y
  otros controles pueden requerir otra prueba.

---

## P2 — contexto suspendible

### F53 — Todo es un archivo

- Prioridad: **P2**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::linux` `internals` `p2`
- Pregunta: ¿“Todo es un archivo” es una definición literal completa de Linux?
- Respuesta: No. Es una aproximación útil porque muchos recursos se exponen con
  interfaces tipo archivo, pero procesos, sockets, unidades y configuración son
  objetos distintos y no deben confundirse.

### F54 — PPID 1

- Prioridad: **P2**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::procesos` `systemd` `p2`
- Pregunta: ¿PPID 1 demuestra que un proceso pertenece a una unidad de servicio?
- Respuesta: No. Sugiere relación con init/systemd o adopción de un proceso, pero
  la unidad concreta se demuestra comparando estado, cgroup, Main PID y comando.

### F55 — WSL, Ubuntu y Microsoft

- Prioridad: **P2**
- Clase: **CONCEPTUAL**
- Etiquetas: `cw26::wsl` `kernel` `p2`
- Pregunta: ¿Es contradictorio que `/etc/os-release` diga Ubuntu y el kernel
  mencione Microsoft/WSL2?
- Respuesta: No. Ubuntu describe la distribución de user space; Microsoft/WSL2
  identifica el kernel adaptado que ejecuta el entorno Linux sobre Windows.

---

## Control de volumen para Anki

- Total: **55 tarjetas**.
- Activar ahora: **F01–F35 (P0)**.
- Activar después de dos repasos P0 con buena retención: **F36–F52 (P1)**.
- Mantener suspendidas por defecto: **F53–F55 (P2)**.
- Si una tarjeta se responde por memoria verbal pero no se aplica en una práctica,
  no subir su madurez: crear o ejecutar una variante corta.
- Si una tarjeta no cambia decisiones durante laboratorios web o simulaciones,
  suspenderla en vez de aumentar el volumen.
