# Cierre técnico de Linux enfocado y preparación individual D0-C — Franco

Fecha de cierre: 2026-08-04
Trabajo consolidado: hasta 2026-08-03
Entorno: laboratorio aislado WSL 2 y Docker
Alcance: Linux enfocado y preparación técnica individual D0-C

## Dictamen

### Linux enfocado

**PASS CON CORRECCIONES — nivel 3/4.**

Franco produjo un inventario Linux desde cero en 7 minutos, dentro del gate de
10 minutos. Identificó y relacionó contexto del host, identidad, recursos,
interfaces, rutas, procesos, unidades, listeners, logs y permisos.

La sintaxis extensa se consultó en una tarjeta de referencia. Esto es compatible
con el gate: el objetivo no era memorizar todas las opciones, sino seleccionar
pruebas útiles, interpretar sus resultados y reconocer sus límites.

Correcciones no bloqueantes:

- todavía necesita referencia para algunas opciones de `systemctl`,
  `journalctl`, `ss` y listados extensos de procesos;
- debe ganar velocidad para atribuir sockets sin proceso visible y decidir la
  siguiente prueba;
- debe seguir practicando la diferencia entre observación de estado y
  validación funcional;
- algunos grupos privilegiados se interpretaron inicialmente de forma demasiado
  general y luego fueron corregidos según su configuración real.

### Preparación técnica individual D0-C

**PASS CON CORRECCIONES — alcance exclusivamente individual.**

Se completaron los cuatro entregables individuales definidos por el plan:

- inventario Linux cronometrado;
- checker que valida la funcionalidad base y una flag mock;
- tres tarjetas de incidente;
- scoreboard del dry-run individual.

El checker distingue ausencia de la flag esperada, fallo de la funcionalidad
base, imposibilidad de recuperar la flag, contenido incorrecto y éxito. Utiliza
timeout, timestamps y no imprime las flags en sus mensajes.

Correcciones no bloqueantes:

- algunas métricas de los incidentes no tienen marca inicial y no permiten
  calcular MTTD;
- el código 3 del checker agrupa distintas causas y exige diagnóstico posterior;
- la flag esperada se pasa como argumento del proceso;
- la flag mock es un recurso público y estático diseñado para el laboratorio;
- el ejercicio no representa una operación autenticada de almacenamiento y
  recuperación de una flag real.

### Microsimulación grupal D0-C

**PENDIENTE — NO EVALUADA.**

El dry-run individual no demuestra el gate grupal. No se asigna `FAIL` a Franco
porque la actividad no se ejecutó debido a la disponibilidad del equipo.

Siguen pendientes:

- tres roles rotados;
- ejecución del checker durante rondas grupales;
- handoffs con estado, dueño, acción y próxima actualización;
- incidentes coordinados y recuperados por distintos integrantes;
- scoreboard grupal completo;
- replay y postmortem grupales.

### Ruta individual del plan rebasado

**CERRADA.**

Franco puede volver al plan general sin esperar a que Philippe y Mati completen
su ruta. La microsimulación grupal permanece en el backlog del equipo y no debe
bloquear el avance individual.

## Evidencia y artefactos

### Linux y D0-C

- Evidencia principal: `evidence/2026-08-02/franco-d0c-prep.md`.
- Checker: `scripts/checker-d0c.sh`.
- Healthcheck reutilizado: `scripts/healthcheck-http-d0a.sh`.
- Flag de laboratorio: `services/http-d0a/site/mock-flag.txt`.
- Servicio: `services/http-d0a/compose.yaml`.
- Tarjetas 1–3 y scoreboard: incluidos en la evidencia principal.

### Control de versiones

- Commit de implementación: `85d74a5`.
- PR: `#5`, fusionado.
- Commit de merge: `b2acee9`.
- Estado confirmado al iniciar este cierre: rama `main` limpia y sincronizada
  con `origin/main` en el clon Windows.
- El clon WSL fue confirmado previamente limpio y sincronizado en el mismo
  commit; debe comprobarse otra vez antes de una nueva práctica operativa.

### Seguridad y alcance

- No se versionó una flag real ni otro secreto conocido.
- `MOCK_FLAG_D0C_ROUND_01` está identificada como dato de laboratorio.
- El endpoint de la flag es deliberadamente inseguro y no debe reutilizarse como
  diseño de producción o competencia.

## Métricas conservadas

### Gate Linux

- Tiempo de inventario final: 7 minutos.
- Ayuda: tarjeta de referencia para comandos y opciones extensas.
- Resultado: PASS CON CORRECCIONES, 3/4.

### Dry-run individual D0-C

- Tramo de cierre registrado el 2026-08-02: 5 horas netas.
- Sueño informado: 9 horas.
- Energía: 5/5 al inicio y 3/5 al cierre.
- Flag ausente: detección aproximada en 1 min 58 s; detección a PASS en 23 s.
- Servicio detenido: detección a PASS en 2 min 28 s; MTTD no calculable.
- Puerto incorrecto: causa identificada y recuperación validada; tiempos
  incompletos.

No se inventan métricas ausentes. El detalle y las marcas temporales están en la
evidencia principal.

## Autonomía observada

### FLUIDEZ

Franco debe poder realizar sin ayuda sustantiva:

- distinguir programa, proceso, unidad, listener y servicio;
- pensar por capas y localizar la última etapa demostrada;
- diferenciar estado activo, listener presente y función validada;
- interpretar resolución de nombres, ruta, conexión TCP, respuesta HTTP y
  contenido esperado como pruebas diferentes;
- reconocer que un healthcheck verde no demuestra recuperación de una flag;
- cerrar una recuperación únicamente después de un checker funcional verde;
- comparar destino del checker, publicación de puertos y listener real;
- explicar qué demuestra una salida y qué todavía no permite concluir.

### REFERENCIA

Puede consultar sintaxis exacta para:

- listados extensos de procesos;
- filtros y opciones de `ss`;
- consultas de `systemctl` y `journalctl`;
- opciones menos frecuentes de `curl`;
- invocaciones largas de Docker Compose;
- captura y filtrado de tráfico.

La consulta de sintaxis no reemplaza la obligación de explicar el objeto
observado, la hipótesis y los límites del resultado.

### Requiere refuerzo espaciado

- atribución de listeners cuando `ss` no muestra el proceso;
- selección de logs relevantes frente a ruido del sistema o de WSL;
- interpretación precisa de grupos privilegiados según configuración;
- recorrido completo de diagnóstico bajo presión y con menos guía;
- medición rigurosa de inicio, detección y recuperación de incidentes.

## Errores y correcciones relevantes

- Se confundió inicialmente almacenamiento con “memoria física”; se corrigió la
  distinción entre almacenamiento, RAM y memoria virtual.
- Se asumió inicialmente que `x86_64` era una arquitectura de 32 bits; se
  corrigió la relación entre ISA, binarios y portabilidad de scripts.
- Se interpretó `UNKNOWN` en loopback como posible inactividad; se corrigió que
  ese estado no basta para declararla inactiva.
- Se atribuyeron todos los procesos con PPID 1 directamente a una unidad de
  servicio; se corrigió que la relación debe demostrarse.
- Se confundió inicialmente `Peer Address 0.0.0.0:*` con un bind a todas las
  direcciones; se corrigió que el bind se interpreta en `Local Address`.
- Se ejecutó dos veces la detención del servicio durante una práctica; no causó
  daño y quedó registrada.
- Se comprobó que un mismo exit 3 puede provenir de un servicio detenido o de un
  destino incorrecto del checker.

## Retrospectiva pedagógica

La primera explicación de Linux abarcó demasiados conceptos y preguntas en un
solo mensaje. Esto produjo sobrecarga y dificultó distinguir qué estaba
comprendido. El formato que mejor funcionó fue:

1. un modelo mental pequeño;
2. relación explícita con Attack/Defense;
3. una predicción o hipótesis;
4. explicación del objeto sobre el que actúa la prueba;
5. un único bloque práctico;
6. interpretación de la salida y de sus límites;
7. corrección inmediata de una idea central;
8. variante con menos ayuda;
9. recuperación activa y repetición selectiva.

El próximo tutor no debe:

- preguntar por términos que todavía no explicó;
- introducir muchos conceptos nuevos antes del primer checkpoint;
- basar la sesión en copiar cadenas largas de comandos;
- confundir una salida exitosa con comprensión;
- usar el replay final como primera práctica sin ayuda;
- exigir memoria de sintaxis clasificada como REFERENCIA;
- repetir módulos completos que ya tienen evidencia válida.

Debe conservar bloques pequeños, preguntas diagnósticas con finalidad explícita,
active recall, método Feynman, práctica incremental y relación constante con
Attack/Defense.

## Parking Lot

| Tema | Motivo | Momento recomendado |
|---|---|---|
| Eventos repetidos de cambio de reloj en WSL | No bloquearon el laboratorio, pero pueden afectar correlación de logs | Antes de una práctica que dependa de timestamps precisos |
| Atribución avanzada de sockets | Algunos sockets no mostraron proceso responsable | Al automatizar inventario o investigar un listener desconocido |
| Healthchecks/checkers multipunto | El checker actual es deliberadamente pequeño | Módulo de automatización |
| Persistencia y backups consistentes | No era parte del gate individual actual | Módulo de datos y recuperación |
| Networking Docker avanzado y namespaces | Diferido por el plan anterior | Plan general rebasado |
| Integración estratégica de IA | Depende del reglamento oficial | Cuando se publiquen reglas o al definir workflow autorizado |
| Especialización ofensiva web | Preferencia probable, no rol definitivo | Nuevo plan por capacidad y riesgo |

## Backlog y dependencias

| Pendiente | Dueño | Prioridad | ¿Bloquea a Franco? |
|---|---|---:|---|
| D0-A de Philippe | Philippe | Alta | No |
| D0-A de Mati | Mati | Alta | No |
| Ejecución cruzada del runbook | Equipo | Alta | No para avance individual; sí para gate de equipo |
| Microsimulación grupal D0-C | Equipo | Alta | No para avance individual |
| Reglamento oficial y reglas sobre IA | Organización | Alta | No para fundamentos; sí para el workflow definitivo de IA |
| Nuevo plan desde el estado real | Chat planificador | Alta | Sí para elegir el próximo módulo principal |

## Estado operativo conocido

Último estado bueno demostrado:

- contenedor `cw26-http-d0a` iniciado;
- publicación `8080:80`;
- healthcheck base en PASS;
- checker D0-C en PASS con la flag mock correcta;
- cambios fusionados en `main`.

Este estado no se considera vigente indefinidamente. Antes de una nueva práctica
debe verificarse nuevamente en el clon WSL.

## Datos de control

El Google Sheet nativo ya fue actualizado con:

- cierre de la tarea individual de Linux y preparación D0-C;
- 5 horas del tramo del 2026-08-02;
- habilidad Linux/terminal en nivel 3;
- microsimulación grupal pendiente.

En el cierre definitivo del chat debe comprobarse que el brief de
replanificación y la próxima acción también queden reflejados sin duplicar horas.

## Próxima acción exacta

Crear `evidence/2026-08-04/linux-d0c-study-guide.md` como apunte conceptual
compacto. Debe reutilizar la evidencia existente, clasificar FLUIDEZ y REFERENCIA
y evitar convertirse en una transcripción del chat.

Después se preparará el brief para solicitar un nuevo plan desde el estado real
del 2026-08-04.
