# Flashcards selectivas D0-B

Prioridad:

- **F**: FLUIDEZ, responder bajo presión.
- **R**: REFERENCIA, reconocer y saber dónde consultar.
- **C**: CONCEPTUAL, comprender sin memorizar sintaxis.

## Modelos mentales

### 1 — F

**Frente:** ¿Cuál es el recorrido mínimo de una petición al servicio D0-A?

**Reverso:** Cliente → resolución si hay nombre → IP y ruta → TCP al host:8080 → publicación Docker 8080:80 → Nginx:80 → request/response HTTP → validación funcional. En A/D permite ubicar dónde falló un checker o exploit.

### 2 — F

**Frente:** ¿Qué secuencia de razonamiento uso ante un fallo?

**Reverso:** Síntoma → última etapa demostrada → hipótesis acotada → prueba que más reduce causas → reparación mínima → validación funcional.

### 3 — F

**Frente:** ¿Por qué `Container Up`, listener abierto o HTTP `200` no bastan?

**Reverso:** Solo demuestran etapas parciales. El servicio se considera operativo cuando completa el flujo y devuelve el contenido o estado esperado por el checker.

### 4 — C

**Frente:** ¿Qué identifica un 5-tuple?

**Reverso:** Protocolo, IP origen, puerto origen, IP destino y puerto destino. Identifica un flujo de transporte.

### 5 — C

**Frente:** ¿Qué demuestra `ESTAB` y qué no demuestra?

**Reverso:** Demuestra que TCP completó el handshake. No demuestra que se haya enviado HTTP ni que la función sea correcta.

### 6 — F

**Frente:** ¿Cuál es el handshake TCP?

**Reverso:** SYN → SYN-ACK → ACK.

### 7 — C

**Frente:** ¿Qué significa `8080:80`?

**Reverso:** Puerto 8080 del host publicado hacia el puerto 80 del contenedor. El cliente usa 8080; Nginx escucha internamente en 80.

## DNS y HTTP

### 8 — F

**Frente:** `Could not resolve host`: ¿qué etapa falló y cuál es la primera prueba?

**Reverso:** Falló la resolución del nombre, antes de contactar el servicio. Probar `getent ahostsv4 NOMBRE`.

### 9 — C

**Frente:** ¿RCODE 0 garantiza que existe una dirección IP?

**Reverso:** No. Indica ausencia de error DNS declarado, pero la respuesta puede no contener un registro A/AAAA utilizable.

### 10 — C

**Frente:** ¿Qué diferencia hay entre DNS y el header `Host`?

**Reverso:** DNS traduce nombres antes de conectar. `Host` viaja dentro de la request HTTP y permite al servidor elegir el sitio virtual.

### 11 — C

**Frente:** ¿`curl --resolve` es evidencia de una consulta DNS?

**Reverso:** No. Asocia manualmente nombre e IP para curl y evita la resolución DNS real de esa asociación.

### 12 — F

**Frente:** ¿Qué separa headers y body HTTP?

**Reverso:** Una línea vacía, es decir `\r\n\r\n`.

### 13 — C

**Frente:** ¿Por qué HEAD anuncia `Content-Length` pero no entrega el body?

**Reverso:** HEAD devuelve los headers equivalentes a GET, incluido el tamaño que tendría la representación, pero omite el cuerpo.

### 14 — F

**Frente:** ¿Qué significa HTTP `404` para el diagnóstico?

**Reverso:** TCP y HTTP funcionaron; el recurso, la URI, el método o el Host pueden ser incorrectos. Revisar request y rutas, no reiniciar red primero.

### 15 — F

**Frente:** ¿Qué significa HTTP `503`?

**Reverso:** El servidor HTTP respondió, pero declaró indisponibilidad de la aplicación o dependencia. Revisar body y logs.

### 16 — F

**Frente:** ¿Por qué curl puede devolver salida 0 ante 404 o 503?

**Reverso:** Sin `--fail`, curl considera exitosa la transferencia HTTP. Con `--fail`, 4xx/5xx producen salida 22.

## Síntomas y decisiones

### 17 — F

**Frente:** `Connection refused`, salida 7: ¿qué demuestra y qué pruebo?

**Reverso:** La ruta llegó, pero TCP no estableció conexión; suele haber RST. Probar listener y estado/publicación Compose con `ss -lnt` y `docker compose ... ps --all`.

### 18 — F

**Frente:** `Connected` seguido de timeout, salida 28: ¿qué demuestra?

**Reverso:** TCP conectó; si se mostró la request, HTTP salió. Falta respuesta a tiempo. Revisar aplicación, logs y dependencias; usar timeout para continuar con otros equipos.

### 19 — F

**Frente:** HTTP `200` con flag o contenido incorrecto: ¿dónde está el problema?

**Reverso:** En la función, lógica, estado o datos, no en el establecimiento básico de HTTP. Ejecutar checker/healthcheck con contenido exacto y revisar cambios.

### 20 — F

**Frente:** ¿Cuál es la regla de rollback?

**Reverso:** Conocer estado bueno, cambio, rollback y validación antes de inyectar. Después de restaurar, ejecutar una validación funcional completa.

### 21 — F

**Frente:** ¿Qué evita `--max-time` en un exploit multiobjetivo?

**Reverso:** Evita que un único objetivo lento o bloqueado congele todo el runner; permite registrar el fallo y continuar.

### 22 — C

**Frente:** ¿Un paquete TCP equivale a una request o response HTTP?

**Reverso:** No. TCP es un flujo de bytes y un mensaje HTTP puede dividirse entre varios segmentos. Se sigue el stream para reconstruirlo.

## Comandos

### 23 — F

**Frente:** ¿Cuál es la primera comprobación integrada del laboratorio?

**Reverso:** `./scripts/observe-http-d0b.sh` y luego comprobar su código de salida.

### 24 — F

**Frente:** ¿Cómo consulto la ruta hacia loopback?

**Reverso:** `ip route get 127.0.0.1`.

### 25 — F

**Frente:** ¿Cómo veo listeners TCP sin depender de recordar un filtro complejo?

**Reverso:** `ss -lnt`. Después se busca el puerto relevante.

### 26 — F

**Frente:** ¿Cómo hago una request visible y limitada a tres segundos?

**Reverso:** `curl --max-time 3 -sv URL`.

### 27 — F

**Frente:** ¿Cómo veo contenedores detenidos y activos del laboratorio?

**Reverso:** `docker compose -f services/http-d0a/compose.yaml ps --all`.

### 28 — R

**Frente:** ¿Qué parte de tcpdump debo recordar y qué parte puedo consultar?

**Reverso:** Recordar la intención: interfaz, resolución numérica, captura completa, archivo y filtro. La sintaxis exacta —por ejemplo `sudo tcpdump -i lo -nn -s0 -w captura.pcap 'tcp port 8080'`— puede consultarse.

## Errores personales a vigilar

### 29 — F

**Frente:** ¿Qué supuesto incorrecto tuve sobre DNS?

**Reverso:** Pensé que DNS correspondía solo a Internet. También puede resolver nombres internos o locales.

### 30 — F

**Frente:** Cuando no recuerdo un comando, ¿qué debo formular antes de buscar sintaxis?

**Reverso:** Qué hipótesis quiero probar, qué objeto necesito observar, qué resultado espero y qué conclusión no podré obtener.
