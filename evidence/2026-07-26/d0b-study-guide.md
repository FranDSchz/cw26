# Apunte definitivo D0-B — red, TCP, DNS, HTTP y diagnóstico

## Para qué sirve en Attack/Defense

En una competencia, una misma frase —“el exploit no funciona”— puede ocultar fallos muy distintos:

- el nombre no resuelve;
- el host o la ruta no son alcanzables;
- no hay un listener;
- TCP conecta, pero la aplicación no responde;
- HTTP responde con error;
- HTTP responde `200`, pero el dato o la flag son incorrectos.

Si no se separan esas etapas, se pierde tiempo arreglando la capa equivocada. Esto afecta:

- al atacante, porque un runner puede congelarse o descartar objetivos válidos;
- al defensor, porque puede reiniciar o parchear componentes que ya funcionaban;
- al checker, porque puede declarar operativo un servicio que no cumple su función.

## El recorrido completo

```text
1. Cliente
   curl, checker, browser o exploit

2. Resolución de nombre, si corresponde
   nombre → dirección IP

3. Ruta
   el kernel decide por qué interfaz alcanzar la IP

4. Endpoint TCP
   IP destino + puerto destino

5. Handshake
   SYN → SYN-ACK → ACK

6. Protocolo de aplicación
   request HTTP → procesamiento → response HTTP

7. Validación funcional
   status + headers + body + estado o flag esperada
```

Para el laboratorio:

```text
curl
  → 127.0.0.1 mediante lo
  → TCP 127.0.0.1:puerto_efímero → 127.0.0.1:8080
  → publicación Docker 8080:80
  → Nginx:80
  → HTTP
  → validación de / y /health
```

## Cliente, servidor y puertos

El servidor mantiene un listener en un endpoint conocido. En este caso, el cliente conoce `127.0.0.1:8080`.

El cliente utiliza normalmente un puerto efímero para esa conexión. Ese puerto no es “el servicio del cliente” ni necesita quedar escuchando después. Es parte del endpoint temporal que identifica el flujo.

Dos máquinas diferentes pueden utilizar el mismo número de puerto porque sus IP son distintas. La identidad completa no es solamente “puerto 8080”.

## 5-tuple

Una conversación de transporte se identifica mediante:

```text
protocolo
IP origen
puerto origen
IP destino
puerto destino
```

Ejemplo:

```text
TCP, 127.0.0.1, 38496, 127.0.0.1, 8080
```

El mismo servidor puede mantener muchas conexiones simultáneas porque los puertos de origen y, en otros casos, las IP de origen permiten distinguirlas.

## IP y ruta

Una IP identifica una interfaz o endpoint lógico. La ruta indica cómo intentar alcanzarla.

Para loopback:

```bash
ip route get 127.0.0.1
```

Resultado esperado:

```text
local 127.0.0.1 dev lo src 127.0.0.1
```

Esto demuestra que el kernel utilizará `lo`. No demuestra que exista un listener, que TCP conecte ni que HTTP funcione.

## TCP

TCP es orientado a conexión y mantiene estado.

Handshake:

```text
cliente  → SYN     → servidor
cliente  ← SYN-ACK ← servidor
cliente  → ACK     → servidor
```

Después del handshake aparece `ESTAB`. Eso demuestra una conexión TCP establecida. No demuestra que ya se haya enviado una request HTTP.

Cierre normal:

```text
FIN/ACK en una dirección
ACK
FIN/ACK en la otra dirección
ACK
```

La dirección exacta del primer FIN depende de quién cierra primero.

### TCP frente a UDP

TCP:

- conexión y estado;
- entrega ordenada;
- retransmisión;
- handshake;
- útil para HTTP/1.1 en este laboratorio.

UDP:

- envía datagramas sin handshake;
- no mantiene un estado `ESTAB`;
- menor control incorporado;
- se utiliza habitualmente para DNS clásico, aunque DNS también puede usar TCP.

Para D0-B importa comprender la diferencia. No hace falta memorizar todos los campos internos de las cabeceras.

## Docker `8080:80`

```text
8080:80
^^^^ ^^
host contenedor
```

El cliente contacta el puerto `8080` del host. Docker entrega el tráfico al puerto `80` del contenedor. Nginx escucha en el puerto interno.

Consecuencias:

- contenedor `Up` no demuestra que se publicó el puerto correcto;
- listener en `8080` no demuestra que Nginx responda correctamente;
- HTTP `200` no demuestra que el body sea correcto;
- la validación debe llegar hasta la función esperada.

## HTTP

HTTP intercambia mensajes sobre la conexión.

Request:

```http
GET / HTTP/1.1
Host: 127.0.0.1:8080
User-Agent: curl/...
Accept: */*

```

Response:

```http
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 195

...body...
```

La línea vacía separa headers y body. Los marcadores `<` y `>` que muestra `curl -v` indican la dirección de los datos y no pertenecen al protocolo.

### Métodos practicados

- `GET`: solicita representación y normalmente recibe body.
- `HEAD`: solicita los headers que corresponderían a GET, pero no recibe el body.

### Códigos practicados

- `200`: la request fue procesada con éxito HTTP. Todavía hay que validar el contenido.
- `404`: el servidor respondió, pero no encontró la ruta o recurso pedido.
- `503`: el servidor respondió que el servicio no estaba disponible.

Un `4xx` describe normalmente un problema con la request o el recurso solicitado. Un `5xx` describe que el servidor no pudo completar correctamente la operación. Ambos demuestran que TCP y HTTP llegaron suficientemente lejos como para recibir una respuesta.

### Código HTTP frente a código de salida de curl

Sin `--fail`, `curl` puede terminar con salida `0` aunque HTTP devuelva `404` o `503`. La transferencia funcionó.

Con `--fail` o `--fail-with-body`, esos errores HTTP producen salida `22`.

Otros códigos observados:

- `7`: no se pudo conectar;
- `22`: HTTP considerado error por `--fail`;
- `28`: timeout.

Un checker debe controlar:

1. si pudo resolver y conectar;
2. si completó dentro del timeout;
3. qué status recibió;
4. si el contenido y el estado funcional son correctos.

## DNS

DNS traduce nombres a información registrada, frecuentemente direcciones.

Puntos importantes:

- DNS no corresponde solamente a Internet;
- puede haber DNS local o interno;
- antes de resolver el nombre todavía no se conoce la IP de destino;
- `RCODE 0` significa que la respuesta no declaró un error DNS, no que necesariamente exista un registro `A`;
- `NXDOMAIN`, `RCODE 3`, indica que el nombre consultado no existe;
- `Host` es un header HTTP y no una prueba de DNS;
- `curl --resolve` evita la resolución real para esa asociación;
- una PCAP filtrada por `tcp port 8080` no permite concluir qué pasó con DNS.

Prueba de resolución:

```bash
getent ahostsv4 NOMBRE
```

Prueba de tráfico DNS:

```bash
sudo tcpdump -i any -nn -s0 -w dns.pcap 'port 53'
```

La sintaxis exacta de captura es de REFERENCIA. Lo que debe quedar claro es qué tráfico se quiere observar y qué conclusión permite.

## Un paquete TCP no es un mensaje HTTP

TCP entrega un flujo de bytes. Una request o response puede:

- caber en un segmento;
- dividirse entre varios segmentos;
- compartir una conexión con otros mensajes.

Por eso se “sigue el stream” para reconstruir la conversación. En la captura D0-B, una respuesta GET se dividió en:

```text
237 bytes de headers
+ 195 bytes de body
= 432 bytes TCP
```

HEAD tuvo los headers y anunció `Content-Length: 195`, pero no transportó esos 195 bytes de body.

## Diagnóstico por etapas

No empieces por una lista infinita de causas. Buscá la última etapa demostrada.

```text
¿Resuelve el nombre?
  ↓
¿Existe una ruta?
  ↓
¿TCP conecta?
  ↓
¿La aplicación responde?
  ↓
¿HTTP produce el status esperado?
  ↓
¿El contenido o la flag son correctos?
```

Después seguí:

```text
síntoma
  → hipótesis
  → prueba que discrimina
  → confirmación
  → reparación mínima
  → validación funcional
```

### `Could not resolve host`

Sabemos:

- el cliente no obtuvo una IP utilizable para ese nombre;
- todavía no corresponde investigar Nginx ni el puerto.

Primera prueba:

```bash
getent ahostsv4 NOMBRE
```

Acción:

- verificar el nombre;
- verificar configuración o resolución;
- utilizar una IP solo si el flujo autorizado lo permite.

### `Connection refused`

Sabemos:

- la IP/ruta llegó a un endpoint que respondió con rechazo;
- el handshake no terminó;
- suele aparecer `SYN → RST,ACK`.

Pruebas:

```bash
ss -lnt
docker compose -f services/http-d0a/compose.yaml ps --all
docker compose -f services/http-d0a/compose.yaml port web 80
```

Hipótesis frecuentes:

- servicio detenido;
- listener ausente;
- puerto incorrecto;
- publicación incorrecta;
- rechazo explícito de firewall.

### Conecta y luego hace timeout

Sabemos:

- TCP conectó;
- si `curl -v` mostró la request, también salió HTTP;
- no llegó una respuesta completa dentro del límite.

Prueba:

```bash
curl --max-time 3 -sv URL
```

Después:

- logs de aplicación;
- dependencias;
- bloqueos;
- recursos.

En ataque, se registra el fallo y se continúa con el siguiente equipo. No se deja colgado el runner.

### HTTP `404`

Sabemos:

- DNS, ruta, TCP y servidor HTTP funcionaron lo suficiente para responder.

Revisar:

- método;
- URI;
- header `Host`;
- configuración de rutas;
- logs.

No corresponde reiniciar la red como primera acción.

### HTTP `503`

Sabemos:

- HTTP respondió;
- el servicio o una dependencia se declaró indisponible.

Revisar:

- body y headers;
- logs;
- upstreams/dependencias;
- estado funcional.

### HTTP `200` con contenido incorrecto

Sabemos:

- la capa básica HTTP respondió;
- la función o los datos están mal.

Prueba:

```bash
bash scripts/healthcheck-http-d0a.sh
git diff
```

Acción:

- restaurar el dato/configuración correcta;
- rollback si el cambio fue propio;
- ejecutar el checker completo.

## Comandos de fluidez

No hay que memorizar todas las opciones. Sí conviene poder recurrir rápidamente a estas pruebas:

```bash
# Diagnóstico integrado del laboratorio
./scripts/observe-http-d0b.sh
echo "observe_exit=$?"

# Ruta a un destino
ip route get 127.0.0.1

# Listeners TCP
ss -lnt

# Request visible, limitada en tiempo
curl --max-time 3 -sv http://127.0.0.1:8080/
echo "curl_exit=$?"

# Estado real de Compose
docker compose -f services/http-d0a/compose.yaml ps --all

# Publicación del puerto interno 80
docker compose -f services/http-d0a/compose.yaml port web 80

# Validación funcional D0-A
bash scripts/healthcheck-http-d0a.sh
echo "healthcheck_exit=$?"
```

Lo importante es poder responder antes de ejecutarlos:

- ¿qué objeto observa?
- ¿qué hipótesis confirma o descarta?
- ¿qué resultado espero?
- ¿qué no demuestra?

## Comandos de referencia

### Captura HTTP

```bash
sudo tcpdump -i lo -nn -s0 -w captura.pcap 'tcp port 8080'
```

En otra terminal:

```bash
curl --max-time 3 -sv http://127.0.0.1:8080/ -o /dev/null
```

Detener con `Ctrl+C`.

### Lectura rápida

```bash
tcpdump -nn -r captura.pcap
```

### Solicitudes HTTP con tshark

```bash
tshark -r captura.pcap -Y 'http.request'
```

### Respuestas HTTP

```bash
tshark -r captura.pcap -Y 'http.response'
```

### DNS

```bash
tshark -r captura.pcap -Y 'dns'
```

Las extracciones tabulares extensas se consultan. No forman parte de la memoria mínima.

## Rollback y cierre de incidente

Antes de inyectar un fallo:

1. identificar el estado bueno;
2. describir exactamente qué cambiará;
3. definir rollback;
4. definir validación final.

Después:

```text
archivo restaurado ≠ servicio recuperado
contenedor Up ≠ servicio recuperado
puerto abierto ≠ servicio recuperado
HTTP 200 ≠ servicio recuperado

checker/healthcheck funcional verde = recuperación demostrada
```

## Hoja de decisión rápida

| Lo que veo | Pienso primero | Miro después |
|---|---|---|
| No resuelve nombre | DNS/nombre | `getent` |
| RST / refused / salida 7 | Listener/puerto/publicación | `ss`, Compose |
| Connected + salida 28 | Aplicación o dependencia | curl visible, logs |
| 404 | Método, URI o Host | request y rutas |
| 503 | Servicio/dependencia | body y logs |
| 200 incorrecto | Lógica/datos | checker, contenido, diff |

## Qué debe quedar automático y qué puede consultarse

### Automático

- pensar por etapas;
- aplicar timeout;
- reconocer las familias de síntomas;
- no confundir proceso, puerto y función;
- validar después del rollback;
- continuar con otros objetivos si un exploit falla de manera controlada.

### Consultable

- opciones exactas de captura;
- filtros complejos;
- campos de tshark;
- detalles de frames;
- sintaxis poco frecuente.

La competencia premia una buena decisión rápida más que recitar opciones de memoria.
