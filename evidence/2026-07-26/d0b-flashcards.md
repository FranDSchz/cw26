# Flashcards selectivas D0-B

Esta colección contiene únicamente fundamentos con transferencia al laboratorio y a una competencia Attack/Defense. No debe ampliarse con datos incidentales o sintaxis que pueda consultarse.

Prioridad de activación:

- **P0**: activar ahora. Núcleo necesario para diagnosticar, recuperar y automatizar bajo presión.
- **P1**: activar después de consolidar P0. Refuerzo útil, pero no debe competir todavía con el núcleo.

Tipo de dominio:

- **F**: FLUIDEZ, responder bajo presión.
- **R**: REFERENCIA, reconocer y saber dónde consultar.
- **C**: CONCEPTUAL, comprender sin memorizar sintaxis.

Etiquetas comunes para Anki: `cw26`, `d0b`, `attack-defense`. Cada tarjeta añade una prioridad (`P0` o `P1`) y un tipo (`fluidez`, `referencia` o `conceptual`).

## Modelos mentales

### 1 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Cuál es el recorrido mínimo de una petición al servicio D0-A?

**Reverso:** Cliente → resolución si hay nombre → IP y ruta → TCP al host:8080 → publicación Docker 8080:80 → Nginx:80 → request/response HTTP → validación funcional. En A/D permite ubicar dónde falló un checker o exploit.

### 2 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Qué secuencia de razonamiento uso ante un fallo?

**Reverso:** Síntoma → última etapa demostrada → hipótesis acotada → prueba que más reduce causas → reparación mínima → validación funcional.

### 3 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Por qué `Container Up`, listener abierto o HTTP `200` no bastan?

**Reverso:** Solo demuestran etapas parciales. El servicio se considera operativo cuando completa el flujo y devuelve el contenido o estado esperado por el checker.

### 4 — P0 · C

**Tags:** `cw26` `d0b` `attack-defense` `P0` `conceptual`

**Frente:** ¿Qué identifica un 5-tuple?

**Reverso:** Protocolo, IP origen, puerto origen, IP destino y puerto destino. Identifica un flujo de transporte.

### 5 — P1 · C

**Tags:** `cw26` `d0b` `attack-defense` `P1` `conceptual`

**Frente:** ¿Qué demuestra `ESTAB` y qué no demuestra?

**Reverso:** Demuestra que TCP completó el handshake. No demuestra que se haya enviado HTTP ni que la función sea correcta.

### 6 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Cuál es el handshake TCP?

**Reverso:** SYN → SYN-ACK → ACK.

### 7 — P0 · C

**Tags:** `cw26` `d0b` `attack-defense` `P0` `conceptual`

**Frente:** ¿Qué significa `8080:80`?

**Reverso:** Puerto 8080 del host publicado hacia el puerto 80 del contenedor. El cliente usa 8080; Nginx escucha internamente en 80.

## DNS y HTTP

### 8 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** `Could not resolve host`: ¿qué etapa falló y cuál es la primera prueba?

**Reverso:** Falló la resolución del nombre, antes de contactar el servicio. Probar `getent ahostsv4 NOMBRE`.

### 9 — P1 · C

**Tags:** `cw26` `d0b` `attack-defense` `P1` `conceptual`

**Frente:** ¿RCODE 0 garantiza que existe una dirección IP?

**Reverso:** No. Indica ausencia de error DNS declarado, pero la respuesta puede no contener un registro A/AAAA utilizable.

### 10 — P0 · C

**Tags:** `cw26` `d0b` `attack-defense` `P0` `conceptual`

**Frente:** ¿Qué diferencia hay entre DNS y el header `Host`?

**Reverso:** DNS traduce nombres antes de conectar. `Host` viaja dentro de la request HTTP y permite al servidor elegir el sitio virtual.

### 11 — P1 · C

**Tags:** `cw26` `d0b` `attack-defense` `P1` `conceptual`

**Frente:** ¿`curl --resolve` es evidencia de una consulta DNS?

**Reverso:** No. Asocia manualmente nombre e IP para curl y evita la resolución DNS real de esa asociación.

### 12 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Qué separa headers y body HTTP?

**Reverso:** Una línea vacía, es decir `\r\n\r\n`.

### 13 — P1 · C

**Tags:** `cw26` `d0b` `attack-defense` `P1` `conceptual`

**Frente:** ¿Por qué HEAD anuncia `Content-Length` pero no entrega el body?

**Reverso:** HEAD devuelve los headers equivalentes a GET, incluido el tamaño que tendría la representación, pero omite el cuerpo.

### 14 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Qué significa HTTP `404` para el diagnóstico?

**Reverso:** TCP y HTTP funcionaron; el recurso, la URI, el método o el Host pueden ser incorrectos. Revisar request y rutas, no reiniciar red primero.

### 15 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Qué significa HTTP `503`?

**Reverso:** El servidor HTTP respondió, pero declaró indisponibilidad de la aplicación o dependencia. Revisar body y logs.

### 16 — P1 · F

**Tags:** `cw26` `d0b` `attack-defense` `P1` `fluidez`

**Frente:** ¿Por qué curl puede devolver salida 0 ante 404 o 503?

**Reverso:** Sin `--fail`, curl considera exitosa la transferencia HTTP. Con `--fail`, 4xx/5xx producen salida 22.

## Síntomas y decisiones

### 17 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** `Connection refused`, salida 7: ¿qué demuestra y qué pruebo?

**Reverso:** La ruta llegó, pero TCP no estableció conexión; suele haber RST. Probar listener y estado/publicación Compose con `ss -lnt` y `docker compose ... ps --all`.

### 18 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** `Connected` seguido de timeout, salida 28: ¿qué demuestra?

**Reverso:** TCP conectó; si se mostró la request, HTTP salió. Falta respuesta a tiempo. Revisar aplicación, logs y dependencias; usar timeout para continuar con otros equipos.

### 19 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** HTTP `200` con flag o contenido incorrecto: ¿dónde está el problema?

**Reverso:** En la función, lógica, estado o datos, no en el establecimiento básico de HTTP. Ejecutar checker/healthcheck con contenido exacto y revisar cambios.

### 20 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Cuál es la regla de rollback?

**Reverso:** Conocer estado bueno, cambio, rollback y validación antes de inyectar. Después de restaurar, ejecutar una validación funcional completa.

### 21 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Qué evita `--max-time` en un exploit multiobjetivo?

**Reverso:** Evita que un único objetivo lento o bloqueado congele todo el runner; permite registrar el fallo y continuar.

### 22 — P0 · C

**Tags:** `cw26` `d0b` `attack-defense` `P0` `conceptual`

**Frente:** ¿Un paquete TCP equivale a una request o response HTTP?

**Reverso:** No. TCP es un flujo de bytes y un mensaje HTTP puede dividirse entre varios segmentos. Se sigue el stream para reconstruirlo.

## Comandos

### 23 — P1 · F

**Tags:** `cw26` `d0b` `attack-defense` `P1` `fluidez`

**Frente:** ¿Cuál es la primera comprobación integrada del laboratorio?

**Reverso:** `./scripts/observe-http-d0b.sh` y luego comprobar su código de salida.

### 24 — P1 · F

**Tags:** `cw26` `d0b` `attack-defense` `P1` `fluidez`

**Frente:** ¿Cómo consulto la ruta hacia loopback?

**Reverso:** `ip route get 127.0.0.1`.

### 25 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Cómo veo listeners TCP sin depender de recordar un filtro complejo?

**Reverso:** `ss -lnt`. Después se busca el puerto relevante.

### 26 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** ¿Cómo hago una request visible y limitada a tres segundos?

**Reverso:** `curl --max-time 3 -sv URL`.

### 27 — P1 · F

**Tags:** `cw26` `d0b` `attack-defense` `P1` `fluidez`

**Frente:** ¿Cómo veo contenedores detenidos y activos del laboratorio?

**Reverso:** `docker compose -f services/http-d0a/compose.yaml ps --all`.

### 28 — P1 · R

**Tags:** `cw26` `d0b` `attack-defense` `P1` `referencia`

**Frente:** ¿Qué parte de tcpdump debo recordar y qué parte puedo consultar?

**Reverso:** Recordar la intención: interfaz, resolución numérica, captura completa, archivo y filtro. La sintaxis exacta —por ejemplo `sudo tcpdump -i lo -nn -s0 -w captura.pcap 'tcp port 8080'`— puede consultarse.

## Errores personales a vigilar

### 29 — P1 · F

**Tags:** `cw26` `d0b` `attack-defense` `P1` `fluidez`

**Frente:** ¿Qué supuesto incorrecto tuve sobre DNS?

**Reverso:** Pensé que DNS correspondía solo a Internet. También puede resolver nombres internos o locales.

### 30 — P0 · F

**Tags:** `cw26` `d0b` `attack-defense` `P0` `fluidez`

**Frente:** Cuando no recuerdo un comando, ¿qué debo formular antes de buscar sintaxis?

**Reverso:** Qué hipótesis quiero probar, qué objeto necesito observar, qué resultado espero y qué conclusión no podré obtener.
