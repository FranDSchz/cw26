# Evidencia D0-B — Franco

## Resultado

- Módulo: D0-B — redes, TCP, DNS, HTTP, captura y diagnóstico por capas.
- Resultado final del gate: **PASS CON CORRECCIONES**.
- Nivel demostrado: **3/4**.
- Trabajo neto aproximado: **12 horas** distribuidas en dos jornadas.
- Correcciones no bloqueantes:
  - consolidar el recorrido `síntoma → hipótesis → prueba → validación → recuperación`;
  - mantener a mano la sintaxis de captura hasta poder iniciar una PCAP con mayor fluidez;
  - repetir una captura breve mediante práctica espaciada, sin rehacer D0-B.

El resultado permite avanzar. No se asigna nivel 4 porque el replay final requirió una consulta puntual de la sintaxis de `tcpdump` y todavía no existe fluidez estable al elegir todos los comandos de diagnóstico bajo presión.

## Objetivo

Explicar y observar el recorrido:

```text
cliente
  → resolución de nombre cuando corresponde
  → IP y ruta
  → conexión TCP al puerto 8080
  → publicación Docker 8080:80
  → Nginx en el contenedor
  → solicitud y respuesta HTTP
  → validación funcional
```

Además:

- diferenciar TCP y UDP;
- identificar un 5-tuple y el handshake TCP;
- observar solicitudes, headers, códigos y body HTTP;
- separar DNS de HTTP;
- interpretar tráfico capturado;
- distinguir cinco familias de síntomas;
- recuperar dos incidentes controlados;
- automatizar una observación corta;
- repetir el recorrido crítico con ayuda mínima.

## Estado de partida

- Repositorio: `/home/franco/cyberwar/cw26`
- Rama creada desde `main`: `lab/franco-d0b-network-observation`
- Base inicial: commit `0078b5a`, PR #3 de D0-A fusionado.
- Servicio reutilizado: `services/http-d0a/`
- Host: `127.0.0.1`
- Puerto publicado: `8080/tcp`
- Puerto interno: `80/tcp`
- Proceso servidor: Nginx.
- Endpoint principal: `/`
- Endpoint de salud: `/health`
- Baseline inicial: healthcheck con código de salida `0`.

## Modelo mental explicado con palabras propias

El cliente puede ser `curl`, un healthcheck, un checker o un exploit. Si usa un nombre, primero debe convertirlo en una dirección IP mediante las fuentes de resolución disponibles. Con la IP conocida, el sistema elige una ruta. Para `127.0.0.1`, la ruta es local y utiliza la interfaz `lo`.

En este laboratorio, el cliente abre una conexión TCP desde un puerto efímero hacia `127.0.0.1:8080`. TCP establece la conexión mediante `SYN → SYN-ACK → ACK`. La publicación de Docker recibe el tráfico del puerto `8080` del host y lo entrega al puerto `80` del contenedor, donde Nginx escucha y procesa la solicitud HTTP.

Una conexión TCP establecida no demuestra por sí sola que haya existido HTTP. Después del handshake deben aparecer una solicitud HTTP y una respuesta. El checker tampoco debería aprobar solamente porque haya conexión o un código `200`: debe comprobar el contenido y el flujo funcional esperado.

En Attack/Defense este recorrido sirve tanto para decidir dónde falló un exploit como para recuperar un servicio sin aplicar cambios a ciegas.

## Diagrama cliente-servidor

```text
curl / checker / exploit
        |
        | GET / HTTP/1.1
        | destino 127.0.0.1:8080
        v
  ruta local mediante lo
        |
        | TCP: SYN, SYN-ACK, ACK
        v
 publicación Docker 8080:80
        |
        v
 contenedor web → Nginx:80
        |
        | HTTP/1.1 200 / 404 / 5xx
        v
 validación de status + headers + body
```

## Tabla IP, puerto, proceso y servicio

| Elemento | Valor observado | Interpretación |
|---|---|---|
| Cliente | `curl` o script Bash | Genera la solicitud |
| IP de origen | `127.0.0.1` | Cliente local |
| Puerto de origen | Efímero; por ejemplo `38496` | Endpoint temporal elegido para esa conexión |
| IP de destino | `127.0.0.1` | Loopback |
| Ruta | `local ... dev lo src 127.0.0.1` | El tráfico no utiliza `eth0` |
| Puerto publicado | `8080/tcp` | Endpoint visible en el host |
| Publicación | `8080:80` | Traducción host → contenedor |
| Puerto interno | `80/tcp` | Puerto donde escucha Nginx |
| Proceso | `nginx` | Implementa el servicio HTTP |
| Funcionalidad | `/` y `/health` | Resultado que valida el checker |

## Observación de IP, ruta, listener y publicación

Se utilizaron:

```bash
ip -br addr
ip route
ip route get 127.0.0.1
ss -lntp 'sport = :8080'
docker compose -f services/http-d0a/compose.yaml ps --all
docker compose -f services/http-d0a/compose.yaml port web 80
```

Resultados interpretados:

- `127.0.0.1` utilizó la interfaz `lo`.
- Existió un listener TCP en `*:8080` durante el estado operativo.
- Compose publicó `0.0.0.0:8080 → 80/tcp`.
- `Container Up`, listener abierto y HTTP `200` se trataron como pruebas parciales, no como validación funcional suficiente.

## HTTP observado con curl

| Solicitud | Resultado | Aprendizaje |
|---|---:|---|
| `GET /` | `200` | Headers y body correcto |
| `HEAD /` | `200` | Headers sin body |
| `GET /no-existe` | `404` | TCP y HTTP funcionaron; no existe el recurso |
| `GET /` con `Host: cw26.local:8080` | `200` | `Host` es un dato HTTP independiente de una consulta DNS |
| Servidor temporal en `18082` | `503` | HTTP respondió, pero el servicio declaró indisponibilidad |

La línea en blanco `\r\n\r\n` separa los headers del body. Los símbolos `<` y `>` de `curl -v` indican dirección de los datos y no forman parte del protocolo.

`curl` sin `--fail` devolvió código de proceso `0` ante `404` y `503` porque la transferencia HTTP se completó. Con `--fail` o `--fail-with-body` devolvió `22`. Por eso un checker debe evaluar tanto el resultado de transporte como el significado de la respuesta y su contenido.

## TCP y 5-tuple

Una conexión observada quedó identificada como:

```text
protocolo: TCP
IP origen: 127.0.0.1
puerto origen: 38496
IP destino: 127.0.0.1
puerto destino: 8080
```

Handshake:

```text
127.0.0.1:38496 → 127.0.0.1:8080  [S]   SYN
127.0.0.1:8080  → 127.0.0.1:38496 [S.]  SYN-ACK
127.0.0.1:38496 → 127.0.0.1:8080  [.]   ACK
```

Después se observó `GET / HTTP/1.1`, la respuesta `HTTP/1.1 200 OK` y el cierre mediante segmentos `FIN/ACK`.

El puerto de origen no identifica al servicio: forma parte del endpoint del cliente para esa conexión. Dos hosts distintos pueden utilizar el mismo número de puerto. Incluso dos extremos pueden coincidir numéricamente si el conjunto protocolo/IP/puerto sigue siendo distinto.

## Captura HTTP

Artefacto:

`evidence/2026-07-26/pcap/http-d0b.pcap`

- Paquetes: `42`
- Tamaño: `5260 bytes`
- SHA-256: `fda987a9ea341b7d2d39c594e5987dffc22eccdc95bdab48fa0be3871d330c92`

Streams identificados:

| Stream | Origen | Destino | Método y URI | Host | Status |
|---:|---|---|---|---|---:|
| 0 | `127.0.0.1:38496` | `127.0.0.1:8080` | `GET /` | `127.0.0.1:8080` | `200` |
| 1 | `127.0.0.1:54804` | `127.0.0.1:8080` | `HEAD /` | `127.0.0.1:8080` | `200` |
| 2 | `127.0.0.1:54814` | `127.0.0.1:8080` | `GET /no-existe` | `127.0.0.1:8080` | `404` |
| 3 | `127.0.0.1:59980` | `127.0.0.1:8080` | `GET /` | `cw26.local:8080` | `200` |

La respuesta `GET /` no coincidió siempre con un solo paquete TCP. En el stream 3 se observaron segmentos de `237` y `195` bytes, suma `432`. La diferencia entre la respuesta GET y HEAD fue `195`, igual al `Content-Length` del body. Esto demostró que un mensaje de aplicación puede estar segmentado y que “un paquete” no equivale necesariamente a “una respuesta HTTP completa”.

La sección 7.2, “Following Protocol Streams”, de la guía de Wireshark fue leída como recurso acotado.

## DNS live

Artefacto:

`evidence/2026-07-26/pcap/dns-d0b-live.pcap`

- Paquetes: `4`
- Tamaño: `623 bytes`
- SHA-256: `130da7264b5708022bb57e8c23a98d73cbc4cfe11686634f1452f2d653634c80`
- Nameserver observado: `10.255.255.254`
- Sufijo de búsqueda: `hitronhub.home`

Consulta:

`d0b-1785121588.example.com`

Resultados:

- Primera respuesta: `RCODE 0`, sin una dirección IPv4 utilizable.
- Segunda consulta: nombre con el sufijo `.hitronhub.home`.
- Segunda respuesta: `RCODE 3`, `NXDOMAIN`.
- `getent` terminó con código `2`.

Correcciones conceptuales:

- DNS también puede utilizarse dentro de redes locales; no corresponde solamente a Internet.
- `RCODE 0` significa que la respuesta DNS no declaró un error de protocolo, pero no garantiza que contenga un registro `A` o `AAAA` utilizable.
- Que una PCAP no contenga DNS no prueba que el sistema no haya hecho DNS.
- La PCAP HTTP fue filtrada por `tcp port 8080`, por lo que excluyó DNS.
- `curl --resolve` inyectó manualmente la asociación nombre-IP y no produjo una consulta DNS real.

## Matriz síntoma → hipótesis → prueba → acción

| Síntoma | Última etapa demostrada | Hipótesis inicial | Primera prueba útil | Acción probable en A/D |
|---|---|---|---|---|
| `Could not resolve host` | El cliente intentó resolver un nombre | Nombre incorrecto o resolución fallida | `getent ahostsv4 NOMBRE` y captura DNS si hace falta | Corregir nombre/resolución; no culpar al servicio todavía |
| `Connection refused` / salida `7` | IP y ruta alcanzaron el destino; se recibió RST | No existe listener, servicio detenido o puerto/publicación incorrectos | `ss -lnt`, `docker compose ... ps --all`, publicación real | Recuperar listener o corregir puerto; en ataque, registrar host y continuar |
| `Connected` y luego timeout / salida `28` | Handshake TCP y envío de solicitud | Aplicación bloqueada, dependencia lenta o respuesta ausente | `curl -v --max-time`, logs y estado de dependencias | Limitar tiempo para no congelar checkers/exploits; investigar aplicación |
| HTTP `404` | TCP y HTTP respondieron | Ruta o `Host` incorrectos, recurso inexistente | Ver request exacta, URI, `Host` y logs | Corregir endpoint; no reiniciar la red |
| HTTP `503` | TCP y HTTP respondieron | Aplicación o dependencia indisponible | Body, headers y logs del servicio | Recuperar aplicación/dependencia; el puerto abierto no basta |
| HTTP `200` con contenido/flag incorrectos | Transporte y HTTP básico | Estado funcional o datos incorrectos | Healthcheck/checker con contenido exacto y `git diff` | Restaurar datos/configuración o hacer rollback validado |

Regla operacional:

```text
síntoma
  → última etapa que funcionó
  → hipótesis acotada
  → prueba que más reduce posibilidades
  → reparación mínima
  → validación funcional completa
```

## Síntomas aislados reproducibles

### Rechazo TCP

- Destino: `127.0.0.1:18081`.
- Captura: `SYN` seguido de `RST,ACK`.
- `curl`: `Connection refused`.
- Código de salida: `7`.
- Interpretación: la ruta funcionó, pero no se completó el handshake porque no había listener.

### HTTP 503

- Servidor temporal aislado en `127.0.0.1:18082`.
- Respuesta: `HTTP/1.0 503 Service Unavailable`.
- `curl` normal: salida `0`.
- `curl --fail-with-body`: salida `22`.
- Rollback: `Ctrl+C`.
- Validación: puerto `18082` sin listener y servicio D0-A operativo.

### Timeout determinista

- Servidor temporal aislado en `127.0.0.1:18083`.
- Aceptó TCP y mantuvo la conexión sin responder durante 30 segundos.
- `curl --max-time 2`: conectado, `http_code=000`, salida `28`, total aproximado `2,09 s`.
- Rollback: `Ctrl+C`.
- Validación: puerto `18083` sin listener y healthcheck D0-A con salida `0`.

En Attack/Defense, `--max-time` impide que un checker o exploit que recorre múltiples equipos quede bloqueado por un solo objetivo.

## Incidentes controlados obligatorios

### Incidente 1 — Publicación Docker incorrecta

Estado bueno:

- Compose contenía `"8080:80"`.
- Healthcheck funcional.

Inyección:

- Se modificó temporalmente la publicación a `"18080:80"`.
- Se recreó el contenedor con Compose.

Síntoma:

- `127.0.0.1:8080` devolvió `Connection refused`, salida `7`.
- El contenedor figuró `Up`.
- Compose mostró `18080 → 80`.
- El servicio respondió mediante `18080`.

Causa:

- El proceso estaba activo, pero el puerto publicado no coincidía con el endpoint esperado por el cliente/checker.

Recuperación:

- `git restore services/http-d0a/compose.yaml`
- recreación con `docker compose ... up -d`;
- validación mediante healthcheck.

Tiempo:

- `710 s` (`11 min 50 s`).

### Incidente 2 — HTTP 200 con contenido funcional incorrecto

Estado bueno:

- La página contenía `Estado funcional: operativo`.

Inyección:

- Se cambió temporalmente `operativo` por `degradado`.

Síntoma:

- `curl` recibió `HTTP 200` y terminó con salida `0`.
- El body era incorrecto.
- El healthcheck devolvió salida `3`.
- El contenedor continuó `Up` y el listener permaneció disponible.

Causa:

- Fallo de contenido/estado funcional, no de red ni de proceso.

Recuperación:

- `git restore services/http-d0a/site/index.html`
- no fue necesario reiniciar Nginx porque el archivo estaba montado;
- healthcheck funcional final.

Tiempo:

- `266 s` (`4 min 26 s`).

Conclusión:

Un checker que solo espere `200` puede aprobar un servicio roto. Debe validar el flujo y el contenido esperado.

## Automatización

Artefacto:

`scripts/observe-http-d0b.sh`

El script:

- muestra direcciones;
- consulta la ruta al destino;
- comprueba el listener;
- utiliza timeout;
- consulta `/`;
- valida el contenido principal;
- consulta `/health`;
- valida su contenido;
- devuelve mensajes y códigos de salida inequívocos.

Se validó su sintaxis con `bash -n`. En estado operativo terminó con salida `0`. Con el servicio detenido terminó en la comprobación del listener con salida `6`.

No reemplaza un checker completo de competencia. Es un observador interno con dos comprobaciones funcionales poco profundas. Un checker real debe ejecutar el flujo legítimo y validar estado o flags.

## Replays y evolución de autonomía

| Intento | Condición | Tiempo | Ayudas | Resultado |
|---|---|---:|---|---|
| Replay inicial | Sin apuntes | `1001 s` | Ninguna | **FAIL**: no pudo completar la secuencia ni elegir comandos |
| Replay abierto | Apunte disponible | `1181 s` | Consulta del apunte para captura/lectura de PCAP | **PASS de aprendizaje**: recorrido completo con correcciones |
| Replay final | Ayuda mínima | `803 s` | Una consulta de sintaxis para iniciar `tcpdump` | **PASS CON CORRECCIONES**: menos de 15 min |

En el replay final se logró:

- confirmar baseline;
- mostrar ruta, listener y publicación;
- capturar una solicitud;
- identificar protocolo, IP y puertos;
- identificar handshake, request, status y cierre;
- detener el servicio de forma autorizada;
- detectar la ausencia del listener;
- elegir Compose como prueba;
- identificar el contenedor detenido;
- recuperarlo;
- validar la función completa.

La mejora importante no fue memorizar todos los comandos: fue poder explicar el recorrido y usar una referencia puntual sin perder el diagnóstico.

## Métricas de jornada

### Primera jornada D0-B

- Sueño previo: `9 h`.
- Energía inicial: `5/5`.
- Hora de inicio: `16:00`.
- Trabajo neto aproximado: `9 h`.
- Pausas aproximadas declaradas durante la jornada: `4 h`.

### Segunda jornada D0-B

- Sueño previo: `9 h`.
- Energía inicial: `5/5`.
- Hora de reanudación: `15:30`.
- Trabajo neto aproximado hasta el cierre técnico: `3 h`.
- Energía declarada: `5/5`.

### Total

- Trabajo neto aproximado D0-B: **12 h**.
- El objetivo original era 8 h, con máximo planificado de 9 h.
- El exceso fue de aproximadamente 3 h netas.
- Motivo principal: la primera implementación pedagógica priorizó ejecución guiada y producción de salidas antes de consolidar el modelo mental. Fue necesario detener el replay, construir un apunte intermedio, dormir y reintentar.

## Autonomía observada

### Sin IA

- Explicar el recorrido completo cliente-servidor.
- Diferenciar conexión TCP de solicitud HTTP.
- Interpretar SYN, SYN-ACK, ACK y FIN/ACK.
- Identificar un 5-tuple a partir de una captura.
- Interpretar `200`, `404`, `503`, rechazo y timeout.
- Relacionar `8080:80` con host y contenedor.
- Detectar que `Container Up` y `HTTP 200` no garantizan funcionalidad.
- Diagnosticar y recuperar un servicio detenido en el replay final.

### Con referencia o pista

- Recordar la sintaxis exacta de captura con `tcpdump`.
- Elegir con más seguridad el conjunto mínimo de comandos cuando el síntoma todavía es ambiguo.
- Construir inicialmente la matriz completa de diagnóstico.

### Todavía no consolidado

- Ejecutar toda la secuencia de captura sin consultar sintaxis.
- Seleccionar con fluidez la primera prueba para cualquier síntoma nuevo.
- Mantener bajo presión el patrón completo de hipótesis, prueba discriminante, reparación mínima y validación.

Estas brechas son importantes para competir, pero no bloquean el avance. Deben practicarse de forma espaciada y aplicarse dentro de los próximos módulos, especialmente checker, automatización y explotación multiobjetivo.

## Errores y ayudas conservados

- Suposición inicial de que DNS solo corresponde a Internet.
- Confusión entre `RCODE 0` y existencia de una dirección utilizable.
- Dificultad para elegir comandos sin un mapa diagnóstico consolidado.
- Primer replay: FAIL, `1001 s`, sin ayudas.
- Replay abierto: `1181 s`, consulta del apunte para sintaxis de captura.
- Replay final: `803 s`, una ayuda limitada a la sintaxis de `tcpdump`.
- Las PCAP estaban ignoradas por `.gitignore`; se detectó antes del commit.
- Corrección pedagógica: exceso de ejecución guiada y falta inicial de consolidación conceptual.

Los errores menores de tipeo o atención que no mostraron un patrón útil no se elevan a brechas principales.

## Retrospectiva pedagógica

### Problema

La primera parte de la tutoría produjo muchas salidas correctas, pero demasiado tiempo se destinó a copiar comandos preparados. Haber ejecutado un comando y obtenido la salida esperada fue tratado prematuramente como evidencia de comprensión.

Esto se hizo visible cuando el primer replay sin apuntes no pudo comenzar: faltaba un mapa que conectara síntoma, etapa, hipótesis y prueba.

### Correcciones solicitadas por Franco

- Explicar por qué cada concepto importa para Attack/Defense.
- Evitar una sucesión de comandos sin comprensión.
- Incluir más teoría cuando el concepto es abstracto.
- Ser algo más redundante con ideas fundamentales.
- Entregar un apunte consolidado antes de exigir otro replay.
- No confundir recuerdo de sintaxis con comprensión técnica.
- Crear flashcards al cierre, priorizando conocimientos importantes.

### Cambios que funcionaron

- Detener el replay guiado en lugar de repetir mecánicamente.
- Construir un apunte intermedio del recorrido y diagnóstico.
- Pedir una explicación oral completa sin terminal.
- Volver al laboratorio con apunte abierto.
- Reducir progresivamente la ayuda.
- Repetir finalmente con una sola consulta de sintaxis.
- Relacionar cada síntoma con su impacto ofensivo y defensivo.

### Qué debe hacer el próximo tutor

1. Comenzar con un modelo mental pequeño y pedir una predicción antes del comando.
2. Explicar para qué sirve el concepto en Attack/Defense.
3. Presentar el comando como una prueba de una hipótesis, no como una receta.
4. Pedir que Franco elija primero qué observaría.
5. Repetir ideas centrales en contextos distintos, no repetir bloques completos.
6. Distinguir memoria de sintaxis, interpretación y autonomía.
7. Permitir una hoja de referencia para sintaxis de tipo REFERENCIA.
8. Exigir fluidez solamente en las acciones clasificadas como FLUIDEZ.
9. Usar recursos externos únicamente con sección, objetivo y tiempo definidos.
10. Si tras 25 minutos no aparece nueva evidencia, cambiar de enfoque.

## Clasificación de habilidades

### FLUIDEZ

Debe poder hacerse o explicarse bajo presión:

- recorrido cliente → IP/ruta → TCP/puerto → aplicación → validación;
- distinguir DNS, rechazo, timeout, error HTTP y contenido incorrecto;
- comprobar baseline con `./scripts/observe-http-d0b.sh`;
- usar `curl` con timeout e interpretar su salida;
- comprobar ruta, listener y estado Compose con las herramientas ya practicadas;
- elegir una primera prueba que reduzca causas;
- recuperar servicio detenido o publicación incorrecta;
- terminar todo rollback con validación funcional;
- explicar la utilidad ofensiva de timeouts y resultados inequívocos.

### REFERENCIA

Debe reconocerse y poder consultarse:

- sintaxis completa de `tcpdump`;
- filtros y campos extensos de `tshark`;
- filtros de visualización de Wireshark;
- numeración exacta de frames y streams;
- opciones menos frecuentes de `curl`;
- comandos largos de extracción tabular.

### CONCEPTUAL

Debe comprenderse sin memorizar detalles internos:

- TCP frente a UDP;
- 5-tuple;
- handshake y cierre TCP;
- puerto efímero;
- diferencia entre DNS y header `Host`;
- segmentación TCP frente a mensajes HTTP;
- métodos, headers, status y body;
- `RCODE 0` frente a presencia de registros;
- diferencia entre observador interno y checker funcional.

### DIFERIDO

- internals profundos de TCP;
- namespaces y networking interno avanzado de contenedores;
- filtros avanzados de Wireshark;
- healthchecks multipunto con métricas y retries;
- backup consistente de datos persistentes;
- especialización definitiva de roles del equipo.

## Relación con Attack/Defense

### Ataque

- Identificar si un exploit falla antes o después de conectar.
- No congelar un runner multiobjetivo.
- Interpretar respuestas HTTP y contenido para extraer flags.
- Separar fallo DNS, host caído, ruta incorrecta y parche rival.
- Registrar resultados inequívocos para continuar con el resto de objetivos.

### Defensa

- Recuperar disponibilidad sin tocar capas que ya funcionan.
- Evitar considerar `Up`, listener o `200` como checker verde.
- Aplicar cambios mínimos con rollback.
- Comprobar el flujo legítimo después de un parche.

Franco indicó interés probable en un rol más ofensivo por su experiencia previa en hacking web. Los roles del equipo todavía no están formalmente definidos. Incluso en un rol ofensivo, el diagnóstico mínimo de red y HTTP sigue siendo obligatorio para distinguir un exploit roto de un objetivo indisponible.

## Evaluación del gate criterio por criterio

| Criterio | Resultado | Justificación |
|---|---|---|
| Modelo mental | PASS | Explicación propia completa sin terminal, con correcciones menores incorporadas |
| Observación | PASS | Interpretó IP, ruta, listener, publicación y HTTP |
| PCAP | PASS | Identificó 5-tuple, handshake, request, status, headers, segmentación y cierre; DNS live |
| Diagnóstico | PASS CON CORRECCIÓN | Distingue las familias; todavía falta fluidez general para elegir la primera prueba |
| Incidentes | PASS | Dos incidentes recuperados, cronometrados y validados |
| Automatización | PASS | Script reproducible, timeout, errores y salida inequívoca |
| Replay | PASS CON CORRECCIÓN | `803 s`, dentro de 15 min; una consulta puntual de sintaxis |

### Veredicto

**PASS CON CORRECCIONES — nivel 3/4.**

No se repite D0-B completo. Las correcciones se integran mediante flashcards selectivas, una captura breve espaciada y aplicación del patrón diagnóstico en D0-C.

## Estado operativo y artefactos al cierre

- Rama activa: `lab/franco-d0b-network-observation`.
- Base: `0078b5a`.
- Docker Desktop: `4.81.0`.
- Docker Engine: `29.6.1`.
- Servicio `cw26-http-d0a`: `Up`.
- Publicación final: `0.0.0.0:8080 → 80/tcp`.
- Listener final: `*:8080`.
- Observador final: `RESULT OK`, salida `0`, `/` y `/health` correctos.
- Script D0-B: creado y validado.
- PCAP HTTP y DNS: existentes; ignoradas por la regla global `*.pcap`.
- `replay01.pcap`: captura temporal ignorada; no forma parte del entregable.

Durante el cierre Docker Desktop estaba inicialmente apagado, por lo que desaparecieron el comando integrado y el listener. Se inició Docker Desktop, se levantó `web` y se repitió la validación funcional antes de continuar. El estado conocido como bueno quedó restaurado.

## Parking Lot

- Definición formal de roles del equipo y especialización ofensiva.
- Docker networking multi-contenedor.
- Namespaces e internals de contenedores.
- Automatización ofensiva multiobjetivo con deduplicación.
- Healthchecks/checkers multipunto con métricas y retries.
- Persistencia y backups de bases de datos.
- Filtros avanzados de Wireshark y análisis de retransmisiones.

## Pendientes y dependencias

- Incorporar forzadamente las PCAP requeridas sin modificar `.gitignore`.
- Actualizar Tareas, Registro diario y Habilidades en el Excel operativo.
- Commit, push y PR D0-B.
- Philippe y Mati deben completar el núcleo de D0-A.
- Otro integrante debe ejecutar el runbook de forma cruzada.
- D0-C grupal requiere tres roles rotados; un dry-run individual no aprueba el gate grupal.

## Replanificación

**REPLANIFICACIÓN NECESARIA: NO.**

Aunque D0-B consumió unas 12 horas netas frente a las 8–9 planificadas, el desvío ya produjo una corrección pedagógica concreta, el gate no conserva una brecha bloqueante y el PDF vigente cubre adecuadamente Linux enfocado y preparación D0-C.

No se solicita otro PDF. El siguiente tutor continúa con:

`C:\dev\Cyber War 2026\output\pdf\26-07_plan_operativo_rebasado_Cyber_War_2026.pdf`

## Próxima acción exacta

Después de cerrar el PR y el control:

1. Abrir el PDF operativo vigente.
2. Leer esta evidencia y el traspaso D0-B.
3. Confirmar sueño, energía, rama `main` actualizada y working tree limpio.
4. Iniciar el bloque “Linux enfocado”: inventario cronometrado desde cero.
5. Primer objetivo: producir un inventario de host, procesos, servicios, listeners, logs y permisos en `≤10 min`.
6. No repetir la teoría completa de D0-B ni reconstruir sus PCAP.
7. Reutilizar el patrón diagnóstico D0-B dentro del inventario y de la preparación del checker D0-C.
