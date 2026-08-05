# Traspaso al próximo tutor técnico — cierre Linux y D0-C individual

## Propósito

Este documento inicializa un chat técnico nuevo. El chat anterior cerró Linux
enfocado y la preparación individual D0-C; no debe utilizarse para ejecutar el
nuevo módulo web porque acumuló demasiado contexto.

El próximo tutor debe leer las fuentes indicadas, verificar el estado final del
repositorio y comenzar desde el gate G1. No debe reconstruir la conversación ni
repetir D0-A, D0-B, Linux o D0-C individual.

## Documento operativo principal

Leer completamente antes de comenzar:

`C:\dev\Cyber War 2026\output\pdf\04-08_plan_operativo_Cyber_War_2026_v2.pdf`

Este PDF fue revisado en sus 16 páginas y aprobado como plan vigente. Reemplaza
para ejecución a:

- `output/pdf/04-08_plan_operativo_Cyber_War_2026.pdf`;
- `output/pdf/26-07_plan_operativo_rebasado_Cyber_War_2026.pdf`.

Las versiones anteriores quedan como historial. No solicitar otro plan salvo que
cambien las reglas, disponibilidad o evidencia de una forma que invalide las
decisiones actuales.

## Hechos confirmados del evento

- Fecha: 2026-08-22.
- Formato: Attack/Defense presencial, todos contra todos.
- Equipo: tres integrantes.
- Duración: 120 minutos.
- Internet e inteligencia artificial: permitidos.
- Restricciones específicas sobre datos, proveedores, herramientas y usos de IA:
  todavía pendientes de reglamento detallado.

Hasta conocer esas restricciones, no enviar a servicios externos:

- flags reales;
- credenciales, cookies, tokens o claves;
- `.env`, VPN o topología privada;
- targets, IP o hostnames de la competencia;
- logs, capturas o source del evento;
- material confidencial de la organización.

El entrenamiento debe conservar un workflow funcional sin IA.

## Estado técnico confirmado

### D0-A

- Nivel: 3/4.
- Cerrado individualmente.
- Servicio Nginx reproducible, healthcheck, recuperación, Git y runbook.
- No repetir el módulo completo.

### D0-B

- Dictamen: PASS CON CORRECCIONES, 3/4.
- Tiempo registrado: 12 horas netas.
- PR #4 fusionado.
- Merge commit: `eebf54c`.
- Refuerzo permitido: aplicación espaciada de red, HTTP y diagnóstico dentro de
  prácticas nuevas.

### Linux enfocado

- Dictamen: PASS CON CORRECCIONES, 3/4.
- Inventario final: 7 minutos con tarjeta de referencia.
- Comprende host, identidad, recursos, interfaces, rutas, procesos, unidades,
  listeners, logs, permisos y validación funcional.
- Requiere refuerzo espaciado en atribución de sockets, selección de logs y
  diagnóstico bajo presión.

### Preparación individual D0-C

- Dictamen: PASS CON CORRECCIONES, alcance individual.
- Checker, flag mock, tres tarjetas de incidentes y scoreboard preparados.
- Incidentes practicados: flag ausente, servicio detenido y puerto incorrecto.
- PR #5 fusionado.
- Commit de implementación: `85d74a5`.
- Merge commit: `b2acee9`.

### D0-C grupal

- Estado: PENDIENTE, NO EVALUADO.
- El dry-run individual no demuestra el gate grupal.
- No asignar `FAIL` individual a Franco por falta de disponibilidad del equipo.
- Requiere condiciones E0-E4, tres roles rotados, checker, incidentes, handoffs,
  métricas, replay y postmortem.

## Estado del equipo

- Philippe y Mati todavía no presentaron evidencia de D0-A al último corte.
- Su disponibilidad desde el 6/8 debe validarse; no planificar sobre promesas
  vagas.
- Su ruta acelerada E0-E5 está definida en el PDF.
- El atraso del equipo no bloquea la ruta individual de Franco.
- Si una ventana grupal falla, se utiliza la contingencia prevista y Franco
  continúa su gate individual.
- Los roles son provisionales hasta observar evidencia y una simulación.

## Repositorios y regla de clones

Existen dos clones independientes:

### Clon Windows

`C:\dev\Cyber War 2026\repositorio\cw26`

Preferido para documentación, evidencia y archivos editados directamente por
Codex.

### Clon WSL

`/home/franco/cyberwar/cw26`

Preferido para Docker, Linux, red, tráfico, procesos, servicios y permisos.

Antes de cualquier modificación se debe declarar el clon activo. No mezclar
cambios entre clones. Después de fusionar un PR, sincronizar el otro clon mediante
`pull --ff-only` y comprobar que ambos quedan limpios.

### Estado de transición de este cierre

Al redactar este handoff:

- rama Windows: `docs/franco-linux-d0c-closeout`;
- baseline anterior: `b2acee9`;
- tres documentos del 04/08 preparados para integrar;
- el cierre todavía debe pasar revisión, commit, PR, merge y sincronización.

No iniciar el nuevo chat técnico hasta que el chat de cierre confirme:

- commit y PR del paquete documental;
- merge en `main`;
- `main` sincronizada en Windows y WSL;
- working trees limpios;
- commit final de merge.

El mensaje de inicialización debe añadir ese commit final cuando esté disponible.

## Fuentes que debe revisar el próximo tutor

Leer, sin reconstruir los módulos completos:

- `evidence/2026-08-04/franco-linux-d0c-closeout.md`;
- `evidence/2026-08-04/linux-d0c-study-guide.md`;
- `evidence/2026-08-02/franco-d0c-prep.md`;
- `evidence/2026-07-26/d0b-handoff.md`;
- `rules/study-protocol.md`.

Consultar solo cuando sea necesario:

- `evidence/2026-07-26/d0b-study-guide.md`;
- `evidence/2026-07-26/franco-d0b.md`;
- `scripts/checker-d0c.sh`;
- `scripts/healthcheck-http-d0a.sh`;
- `scripts/observe-http-d0b.sh`;
- `services/http-d0a/compose.yaml`.

## Control operativo

Google Sheet nativo:

`https://docs.google.com/spreadsheets/d/1S_UvGmK8VCQdYlKfhad--cOV1mrGyykzLK_tFV_ySwQ/edit?gid=1506812104#gid=1506812104`

La conversión nativa ya fue validada: conserva pestañas, fórmulas, validaciones y
valores relevantes. No leer toda la carpeta de Drive ni todo el tablero.

Al iniciar un módulo, consultar únicamente las filas activas relacionadas con el
gate y la habilidad de Franco correspondiente. Al cierre actualizar:

- Tareas;
- Registro diario;
- Habilidades.

No duplicar las 5 horas ya registradas para el tramo del 2/8 ni volver a marcar
D0-C grupal como aprobado.

## Perfil de aprendizaje de Franco

Franco aprende mejor con una explicación didáctica breve seguida de recuperación
activa y práctica incremental. Necesita conocer la finalidad pedagógica de cada
actividad y si se espera conocimiento previo, diagnóstico o desarrollo nuevo.

La secuencia obligatoria es:

1. presentar objetivo y transferencia a Attack/Defense;
2. construir un modelo mental pequeño;
3. explicar los conceptos necesarios antes de evaluarlos;
4. pedir una hipótesis o predicción;
5. explicar sobre qué objeto actúa cada prueba;
6. mostrar un único bloque práctico;
7. pedir interpretación y límites de la salida;
8. corregir la idea central;
9. resolver una variante con menos ayuda;
10. repetir la parte crítica en frío;
11. cerrar con síntesis propia, evidencia, tiempo, ayudas y errores.

No entregar la jornada completa en un solo mensaje. Esperar resultados reales
entre bloques.

## Errores pedagógicos que no deben repetirse

- explicar muchos conceptos nuevos antes del primer checkpoint;
- preguntar por términos que todavía no fueron enseñados;
- entregar cadenas largas de comandos para copiar;
- hacer de la sintaxis el objetivo principal;
- asumir comprensión porque una salida terminó bien;
- usar el replay final como primera práctica sin ayuda;
- repetir una jornada completa que ya tiene evidencia válida;
- introducir recursos sin sección, tiempo, objetivo y evidencia concretos;
- separar teoría y práctica o perder la relación con Attack/Defense.

El formato que mejor funcionó fue un concepto por vez, analogía cuando aporta,
active recall, explicación Feynman, práctica corta, interpretación, variante y
retirada progresiva de ayuda.

## Clasificación pedagógica

### FLUIDEZ

Franco debe ejecutar o decidir con poca ayuda:

- modelo identidad → sesión → rol → objeto → acción → efecto;
- anatomía básica request/response;
- hipótesis y prueba diferencial;
- reproducción manual antes de automatizar;
- última etapa demostrada;
- timeout y clasificación de errores;
- checker, rollback y validación final;
- request mínima y explicación causal;
- manejo seguro de flags y secretos;
- síntoma → hipótesis → prueba → cambio mínimo → revalidación.

### COMPRENDER Y SUPERVISAR

- autorización server-side;
- sesiones, cookies, JWT y OAuth cuando aparezcan;
- código generado por IA;
- impacto de un parche;
- SQL/NoSQL según stack;
- SSRF, SSTI y concurrencia por trigger;
- scoring y decisiones operativas cuando se publiquen.

### REFERENCIA

- sintaxis extensa;
- APIs específicas de librerías;
- payload encoding inusual;
- filtros tcpdump/tshark;
- rutas particulares de frameworks;
- opciones menos frecuentes de Docker, curl, systemd y herramientas web.

### AUTOMATIZAR

- loop de targets;
- timeout y errores;
- extracción y validación de flag;
- deduplicación;
- salida estructurada;
- healthchecks/checkers;
- resumen de ronda y backups permitidos.

## Próximo objetivo técnico

Comenzar G1: baseline ofensivo web, priorizando autorización.

El gate G1 exige antes de cerrarse:

- tres familias con evidencia: acceso/IDOR, SQLi y una de
  traversal/command injection;
- un replay sin IA;
- un script v0;
- una propuesta de parche, prueba negativa y regresión;
- tiempos, ayudas y explicación causal.

No abrir varios clusters simultáneamente. El primer bloque es únicamente el modelo
de autorización y el primer laboratorio de BAC o IDOR.

## Primera acción exacta del nuevo chat

Antes de enseñar contenido, pedir:

- horas dormidas;
- energía de 1 a 5;
- hora de inicio;
- tiempo neto disponible;
- confirmación de que el cierre documental fue fusionado.

Después:

1. leer completamente el PDF vigente y las fuentes obligatorias;
2. verificar `main`, commit final y working tree limpio en el clon que se vaya a
   utilizar;
3. mostrar brevemente objetivo, entregable, gate, conocimiento reutilizado,
   riesgos y dependencias;
4. presentar el modelo mínimo:

```text
request
  → identidad
  → sesión
  → rol
  → objeto
  → acción
  → efecto
```

5. pedir a Franco que prediga qué controles debe aplicar el servidor cuando dos
   usuarios intentan leer o modificar tres objetos;
6. corregir el modelo antes de abrir Burp, curl, código o el laboratorio;
7. ejecutar solo el primer bloque práctico de BAC/IDOR y esperar resultados
   reales.

## Dependencias y límites

- Trabajar únicamente en laboratorios propios, locales o expresamente
  autorizados.
- Automatizar después de reproducir manualmente.
- No enviar secretos a IA o servicios externos hasta conocer restricciones.
- No iniciar D0-C grupal sin cumplir su condición de entrada.
- No convertir el atraso del calendario en noches sin sueño.
- Si un recurso Software Seguro no está accesible, elegir un único laboratorio
  equivalente alineado al mismo gate; no abrir una lista de plataformas.
- A los 25 minutos sin nueva evidencia, cambiar de enfoque o pedir una pista.

## Criterio de continuidad

El próximo tutor tiene libertad para cambiar el orden interno, recurso o práctica
cuando exista una razón pedagógica. Debe conservar el cluster, gate, tiempo,
evidencia, relación con Attack/Defense, seguridad y sueño definidos por el PDF.

No debe solicitar automáticamente otra replanificación. Solo corresponde si una
regla, disponibilidad o evidencia nueva invalida materialmente el plan vigente.
