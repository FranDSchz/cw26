# Traspaso al próximo tutor técnico — cierre D0-B

## Documento operativo obligatorio

Antes de iniciar, leer completamente:

`C:\dev\Cyber War 2026\output\pdf\26-07_plan_operativo_rebasado_Cyber_War_2026.pdf`

El PDF sigue vigente. No solicitar automáticamente otro plan.

## Estado confirmado

- Repositorio: `~/cyberwar/cw26`
- Rama de trabajo cerrada: `lab/franco-d0b-network-observation`
- Rama de inicio del próximo módulo: `main`, actualizada después de revisar/fusionar el PR D0-B.
- PR D0-B: **PENDIENTE DE COMPLETAR EN ESTE CIERRE**.
- D0-A: nivel 3/4.
- D0-B: **PASS CON CORRECCIONES, nivel 3/4**.
- Replanificación necesaria: **NO**.
- Próxima fila activa: `RB-2707-01`, Linux speed gate y preparación técnica D0-C.

## Evidencia que debe revisar

- `evidence/2026-07-26/franco-d0b.md`
- `evidence/2026-07-26/d0b-study-guide.md`
- `evidence/2026-07-26/d0b-flashcards.md`
- `evidence/2026-07-26/pcap/http-d0b.pcap`
- `evidence/2026-07-26/pcap/dns-d0b-live.pcap`
- `scripts/observe-http-d0b.sh`
- `rules/study-protocol.md`

No reconstruir el historial completo de D0-A o D0-B. Usar sus artefactos como baseline.

## Capacidades demostradas en D0-B

- Explicación propia del recorrido cliente → DNS cuando corresponde → IP/ruta → TCP/puerto → publicación Docker → Nginx → HTTP → validación.
- TCP frente a UDP.
- 5-tuple, handshake y cierre TCP.
- GET, HEAD, headers, body, `200`, `404` y `503`.
- Diferencia entre código HTTP y código de salida de `curl`.
- DNS live, `NXDOMAIN`, `RCODE 0` sin dirección y diferencia entre DNS y `Host`.
- Captura y análisis de HTTP mediante tcpdump, tshark y Wireshark.
- Diagnóstico de resolución, rechazo TCP, timeout, error HTTP y contenido incorrecto.
- Dos incidentes recuperados:
  - publicación Docker incorrecta: 710 s;
  - contenido incorrecto con HTTP 200: 266 s.
- Script corto de observación.
- Replay final: 803 s; una consulta de sintaxis de tcpdump.

## Correcciones no bloqueantes

- Falta mayor fluidez para recorrer:

  `síntoma → hipótesis → prueba → validación → recuperación`.

- La sintaxis exacta de captura todavía requiere referencia.
- No repetir D0-B. Reforzar mediante:
  - una captura breve espaciada;
  - flashcards FLUIDEZ;
  - aplicación del mismo mapa en Linux y D0-C.

## Perfil y posible orientación

Franco tiene más experiencia previa en hacking web y considera probable una orientación ofensiva. Los roles del equipo todavía no están definidos.

No convertir esa preferencia en una asignación definitiva. El diagnóstico mínimo de red, servicio y HTTP sigue siendo necesario para saber si un exploit falló, fue bloqueado o encontró un objetivo indisponible.

## Instrucciones pedagógicas obligatorias

La primera implementación de D0-B fue demasiado guiada. Franco pasó mucho tiempo copiando comandos y produjo salidas correctas sin consolidar todavía el modelo. El primer replay sin apuntes falló en 1001 s.

Lo que mejoró el aprendizaje:

- detener el replay;
- entregar un apunte conceptual;
- pedir explicación oral sin terminal;
- volver a la práctica con apunte abierto;
- retirar ayuda progresivamente;
- explicar siempre la transferencia a Attack/Defense.

El próximo tutor debe:

1. Presentar un modelo mental pequeño.
2. Explicar por qué importa para Attack/Defense.
3. Pedir una predicción o hipótesis antes de mostrar comandos.
4. Tratar el comando como una prueba sobre un objeto concreto.
5. Pedir interpretación y límites de la salida.
6. Repetir conceptos importantes en contextos distintos.
7. Distinguir comprensión de recuerdo de sintaxis.
8. Permitir referencia para elementos clasificados como REFERENCIA.
9. Exigir autonomía en elementos clasificados como FLUIDEZ.
10. No marcar comprensión solamente porque un comando terminó bien.
11. A los 25 minutos sin nueva evidencia, cambiar de enfoque.
12. No entregar la jornada completa en una sola respuesta.

Franco necesita más explicación y redundancia cuando el contenido es abstracto. Para herramientas y sintaxis, necesita primero entender qué hipótesis está comprobando.

## Clasificación a conservar

### FLUIDEZ

- recorrido cliente-servidor;
- familias de síntomas;
- timeout en curl/checkers/exploits;
- ruta, listener, Compose y validación funcional;
- rollback seguido de checker;
- elección de una prueba discriminante.

### REFERENCIA

- sintaxis completa de tcpdump;
- filtros complejos de tshark/Wireshark;
- extracciones tabulares extensas;
- opciones menos frecuentes de curl.

### CONCEPTUAL

- TCP/UDP;
- 5-tuple;
- puerto efímero;
- DNS frente a Host;
- segmentación TCP frente a mensajes HTTP;
- observador interno frente a checker.

### DIFERIDO

- internals avanzados de TCP;
- namespaces;
- networking Docker avanzado;
- filtros avanzados;
- healthchecks multipunto;
- datos persistentes y backups consistentes.

## Dependencias

- Philippe y Mati deben demostrar D0-A.
- Otro integrante debe ejecutar el runbook de forma cruzada.
- D0-C grupal no se aprueba con un dry-run individual.
- La microsimulación requiere tres roles rotados, checker, flag mock, scoreboard y métricas.

## Próximo objetivo

Completar Linux enfocado y dejar preparada la parte técnica individual de D0-C:

- inventario desde cero en ≤10 min;
- procesos;
- servicios;
- listeners;
- logs;
- permisos;
- checker de ronda;
- tarjetas de incidentes.

El gate inmediato es el inventario Linux individual. No comenzar todavía la microsimulación grupal.

## Primera acción segura de la próxima sesión

Registrar:

- horas dormidas;
- energía de 1 a 5;
- hora de inicio.

Luego:

```bash
cd ~/cyberwar/cw26
git switch main
git pull --ff-only
git status --short --branch
./scripts/observe-http-d0b.sh
echo "baseline_exit=$?"
```

Antes de ejecutarlos, pedir a Franco que explique:

- qué modifica cada comando Git;
- qué comprueba el observador;
- por qué un baseline verde permite comenzar el inventario.

Si el PR todavía no está fusionado, revisar primero su estado y no reconstruir manualmente los archivos.

## Primer bloque

### Modelo mental

Un inventario Linux responde:

```text
qué host tengo
→ qué recursos e interfaces existen
→ qué procesos se ejecutan
→ qué servicios/listeners exponen
→ dónde están configuración y logs
→ con qué usuario y permisos operan
```

### Pregunta inicial

“Si recibieras una vulnbox desconocida y tuvieras diez minutos antes de la primera ronda, ¿qué información necesitarías obtener para poder atacar, defender y recuperar?”

No mostrar todavía una lista completa de comandos. Construir primero las categorías con Franco y recién después seleccionar una prueba por categoría.

## Métricas que debe conservar el próximo tutor

- D0-B: 12 h netas totales.
- Primer tramo: 9 h, sueño 9 h, energía inicial 5/5.
- Segundo tramo: 3 h, sueño 9 h, energía 5/5.
- Primer replay: FAIL, 1001 s, sin ayudas.
- Replay abierto: 1181 s, apunte para sintaxis.
- Replay final: 803 s, una consulta de tcpdump.
- Wireshark User Guide 7.2: leído.
- PCAP HTTP: 42 paquetes, SHA-256 `fda987a9ea341b7d2d39c594e5987dffc22eccdc95bdab48fa0be3871d330c92`.
- PCAP DNS: 4 paquetes, SHA-256 `130da7264b5708022bb57e8c23a98d73cbc4cfe11686634f1452f2d653634c80`.

## Parking Lot

- Definición formal de roles y especialización ofensiva.
- Networking Docker multi-contenedor.
- Namespaces.
- Runner ofensivo multiobjetivo y deduplicación.
- Healthchecks/checkers multipunto.
- Persistencia y backups de bases de datos.
- Wireshark avanzado y retransmisiones.

## Regla de continuidad

El PDF vigente sigue cubriendo el siguiente paso. No pedir otro PDF salvo que aparezca una brecha importante, cambie la disponibilidad, surja una dependencia nueva o Linux/D0-C necesite redefinición.
