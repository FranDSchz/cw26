# Apunte esencial — Linux operativo y preparación D0-C

## Para qué sirve en Attack/Defense

En una ronda, “el servicio está caído” no identifica una causa. El fallo puede
estar en el host, los recursos, la red, el proceso, el supervisor, el listener,
la configuración, los permisos, una dependencia o la función que valida el
checker.

El objetivo del inventario Linux no es recitar comandos. Es construir rápido un
mapa que permita:

- al defensor, localizar y recuperar la capa dañada sin romper otra;
- al atacante, saber qué herramientas y binarios puede ejecutar y distinguir un
  exploit fallido de un objetivo indisponible;
- al operador, demostrar funcionalidad con evidencia y no solo con estados
  aparentemente verdes.

## Modelo mental principal

```text
contexto del host
  → identidad y privilegios
  → recursos y filesystem
  → interfaces y rutas
  → procesos y supervisores
  → sockets y listeners
  → configuración, datos y permisos
  → logs
  → validación funcional
```

Cada paso responde dos preguntas:

1. ¿Qué objeto estoy observando?
2. ¿Qué demuestra la salida y qué todavía no demuestra?

No es obligatorio recorrer siempre todo. Primero se obtiene un baseline breve y
luego se profundiza en la zona que discrimina la hipótesis.

## Host, distribución, kernel y arquitectura

### Distribución

Ubuntu, Debian, Alpine y otras distribuciones combinan componentes, herramientas,
repositorios de paquetes, convenciones y configuración. Conocer la distribución
ayuda a localizar archivos, elegir paquetes y anticipar herramientas disponibles.

No demuestra qué servicio está funcionando ni qué vulnerabilidad existe.

### Kernel

El kernel administra procesos, memoria virtual, dispositivos, filesystem, red y
acceso al hardware. En WSL 2 puede aparecer simultáneamente Ubuntu como
distribución y Microsoft/WSL como variante del kernel. No es una contradicción.

Conocer la versión puede ayudar a reconocer compatibilidad o vulnerabilidades,
pero una cadena de versión no demuestra que un exploit sea aplicable.

### Arquitectura

`x86_64` y `aarch64`/`arm64` son arquitecturas de 64 bits con conjuntos de
instrucciones distintos. Un binario compilado para `x86_64` normalmente no puede
ejecutarse directamente en ARM64.

Un script de Python es más portable, pero depende de que exista un intérprete y
de que sus librerías y llamadas sean compatibles.

### Almacenamiento, RAM y memoria virtual

- El programa existe como archivo en almacenamiento.
- Al ejecutarlo, el kernel crea un proceso.
- El proceso dispone de un espacio de memoria virtual.
- Las páginas activas se respaldan normalmente en RAM; otras pueden provenir de
  archivos o swap.

En `free`, `available` es una estimación más útil que `free` para saber cuánta
memoria puede utilizarse sin presión severa. No representa un límite rígido que
un único proceso tenga garantizado.

## Programa, proceso, unidad, listener y servicio

```text
programa almacenado
  → alguien lo ejecuta
  → proceso con PID, usuario, memoria y estado
  → el proceso puede abrir un socket
  → en TCP puede hacer bind y listen
  → clientes establecen conexiones
  → el proceso interpreta el protocolo
  → la capacidad correcta queda demostrada como servicio funcional
```

### Programa

Archivo con instrucciones o código ejecutable. Todavía no está ejecutándose.

### Proceso

Instancia de un programa en ejecución. Tiene PID, proceso padre, identidad,
recursos, argumentos, archivos abiertos y estado.

### Unidad o supervisor

Una unidad de `systemd` describe cómo administrar un recurso, por ejemplo un
servicio. Puede iniciar, detener, supervisar y reiniciar procesos.

Un proceso con PPID 1 no demuestra por sí solo que exista una unidad de servicio
específica. La relación debe verificarse.

### Listener y socket UDP

Un listener TCP es un socket del kernel preparado para aceptar conexiones en un
endpoint local. El socket no interpreta HTTP; el proceso lo utiliza para recibir
datos y generar respuestas.

UDP no establece una conexión ni utiliza el estado TCP `LISTEN`. Se observa un
socket ligado a una dirección y puerto, normalmente mostrado como `UNCONN`.

### Servicio

Capacidad ofrecida a un consumidor. Puede depender de uno o varios procesos,
listeners, archivos, datos y otros servicios.

```text
proceso activo ≠ servicio funcional
unidad active ≠ servicio funcional
listener presente ≠ servicio funcional
HTTP 200 ≠ contenido funcional correcto
checker PASS = función comprobada según el contrato del checker
```

## Interfaces, direcciones y rutas

### Interfaz

Punto lógico por el que el host intercambia tráfico.

- `lo` se utiliza para comunicación local mediante loopback.
- `eth0` suele representar una interfaz de red externa o virtual en WSL.

Que `lo` aparezca como `UNKNOWN` no permite declararla inactiva. Si tiene sus
direcciones y la ruta local funciona, hay evidencia de operación aunque el campo
no sea `UP`.

### Dirección de bind

- `127.0.0.1:8080`: accesible solamente mediante loopback del mismo entorno.
- `0.0.0.0:8080`: ligado a todas las direcciones IPv4 locales disponibles.
- `172.x.x.x:8080`: ligado a esa dirección concreta.

La dirección que determina el bind es `Local Address`, no `Peer Address`.

### Ruta

La ruta es la decisión del kernel sobre interfaz, gateway y dirección de origen
para intentar alcanzar un destino.

`ip route get DESTINO` consulta esa decisión. No envía una prueba funcional y no
demuestra que el gateway responda, que TCP conecte ni que la aplicación funcione.

## Identidad y permisos

### Identidad

La decisión de acceso depende de UID, grupo principal, grupos adicionales,
propietario, grupo del objeto, bits de modo, ACL y otros controles aplicables.

Pertenecer a un grupo sugiere capacidades, pero no las demuestra completamente:

- `sudo`: puede permitir ejecutar comandos como otra identidad según
  `/etc/sudoers`;
- `docker`: suele otorgar control muy privilegiado sobre Docker y puede implicar
  riesgo equivalente a root;
- `adm`: habitualmente permite leer ciertos logs; no significa “administrar todos
  los permisos”;
- `wireshark`: puede permitir captura según la configuración instalada.

### Bits sobre archivos

- `r`: leer contenido.
- `w`: modificar contenido.
- `x`: solicitar su ejecución; todavía depende del formato, intérprete, montaje y
  otros controles.

### Bits sobre directorios

- `r`: listar nombres.
- `w`: crear, eliminar o renombrar entradas, sujeto a otras reglas.
- `x`: atravesar el directorio y acceder a entradas cuyos nombres se conocen.

Tener `x` sobre un script no demuestra que su sintaxis sea válida ni que termine
con éxito.

## Recursos y filesystem

### Memoria

Señales de posible presión:

- `available` muy bajo;
- swap creciendo o actividad intensa de swap;
- procesos con RSS elevado;
- fallos de asignación u OOM en logs;
- degradación o reinicios.

No se mata el proceso con mayor RSS solamente por ocupar el primer lugar. Hay que
compararlo con la memoria disponible, su función y la evolución del sistema.

### Filesystem

`df` observa capacidad del filesystem montado. `du` permite investigar qué
directorios o archivos consumen espacio.

Un filesystem lleno puede impedir:

- escribir logs;
- guardar flags o estado;
- crear temporales;
- actualizar datos;
- iniciar servicios que necesiten escribir.

Un proceso puede seguir apareciendo activo mientras su función ya falla.

## Procesos, systemd y logs

### Tres vistas diferentes

- `ps`: observa procesos que existen ahora.
- `systemctl`: consulta el estado que `systemd` conoce sobre unidades.
- `journalctl`: consulta eventos almacenados en el journal.

`systemctl --failed` muestra unidades fallidas, no solamente servicios. Obtener
cero unidades fallidas demuestra que `systemd` no marca ninguna como fallida en
ese momento. No demuestra que todos los servicios cumplan su función.

`journalctl` puede contener eventos del kernel, systemd, unidades y procesos que
escriben al journal. El filtro `-u UNIDAD` limita la consulta a una unidad. Los
logs de Docker Compose pertenecen al flujo de salida de los contenedores y no son
automáticamente “los mismos logs”, aunque el sistema pueda integrarlos según su
configuración.

Un evento demuestra que el journal registró ese evento atribuido a una fuente.
No demuestra por sí solo que la función asociada esté disponible.

## Checker, healthcheck y función

### Healthcheck

Comprueba una condición limitada, por ejemplo que `/` y `/health` respondan con
el contenido esperado. Su contrato define el alcance de la evidencia.

### Checker D0-C

El checker reutiliza el healthcheck y luego recupera una flag mock:

| Exit | Significado |
|---:|---|
| 0 | Función base y flag mock correctas |
| 2 | Falta la flag esperada |
| 3 | Falló el healthcheck base |
| 4 | No pudo recuperarse la flag |
| 5 | La flag recuperada no coincide |

El operador interpreta el código y reúne evidencia adicional. El checker detecta
síntomas según su contrato; no explica automáticamente la causa raíz.

### Última etapa demostrada

```text
¿resuelve el nombre?
  → ¿existe una ruta elegible?
  → ¿hay listener en el endpoint esperado?
  → ¿TCP conecta?
  → ¿el protocolo de aplicación responde?
  → ¿el status es aceptable?
  → ¿el contenido o la flag son correctos?
```

Se investiga primero después de la última etapa demostrada. Esto evita reiniciar
la red cuando ya se recibió un HTTP 404 o modificar Nginx cuando el nombre ni
siquiera resuelve.

## Síntomas y decisiones

| Síntoma | Lo demostrado | Primera zona a investigar |
|---|---|---|
| No resuelve el nombre | No se obtuvo una IP utilizable | Nombre, resolver y configuración DNS |
| Existe ruta configurada | El kernel eligió un camino | Alcance real, gateway y siguiente protocolo |
| Conexión rechazada | Se alcanzó un endpoint que rechazó TCP | Listener, proceso, puerto y publicación |
| Timeout después de conectar | TCP avanzó, pero la respuesta no terminó a tiempo | Aplicación, dependencia, bloqueo o recursos |
| HTTP 404 | TCP y HTTP respondieron; el recurso no apareció | URI, método, Host, rutas y archivos |
| HTTP 200 con body incorrecto | Transporte y HTTP funcionaron | Lógica, configuración o datos |
| Healthcheck PASS y checker exit 4 | Función base viva; flag inaccesible | Endpoint, archivo, permisos o datos |
| Checker exit 5 | La flag se recuperó, pero no coincide | Estado de ronda, origen y actualización del dato |

## Recuperación operativa

Antes de inyectar o corregir un incidente:

1. identificar el último estado bueno;
2. formular una hipótesis;
3. seleccionar una prueba que discrimine;
4. definir la modificación mínima;
5. conservar rollback;
6. validar con el checker completo.

```text
archivo restaurado ≠ recuperación demostrada
contenedor Up ≠ recuperación demostrada
listener presente ≠ recuperación demostrada
healthcheck parcial verde ≠ recuperación completa
checker funcional PASS = recuperación demostrada por ese contrato
```

En ataque también importa el timeout: un runner no debe quedar bloqueado por un
equipo caído. Debe clasificar el fallo, registrar evidencia y continuar con otros
objetivos autorizados.

## Tarjeta de inventario de 10 minutos

La secuencia mental es de FLUIDEZ. Las opciones extensas pueden consultarse.

| Categoría | Prueba típica | Objeto observado | Límite principal |
|---|---|---|---|
| Host | `hostname`, `/etc/os-release`, `uname` | Entorno, kernel y arquitectura | No demuestra función |
| Tiempo | `date`, `uptime`, `timedatectl` | Reloj, zona y arranque | No demuestra inicio de un servicio |
| Identidad | `id` | UID y grupos | No prueba cada permiso efectivo |
| Memoria | `free -h` | RAM y swap | Es una foto del momento |
| Filesystem | `df -hT /` | Capacidad del montaje | No localiza el consumidor |
| Interfaces | `ip -br addr` | Interfaces y direcciones | No demuestra conectividad |
| Rutas | `ip route` | Tabla de rutas | No envía tráfico de prueba |
| Listeners | `ss` con filtros de escucha | Sockets ligados | No demuestra función |
| Procesos | `ps` ordenado según la hipótesis | Procesos y relaciones | No representa una unidad completa |
| Unidades | `systemctl` | Estado conocido por systemd | Active no equivale a función |
| Logs | `journalctl` con filtro concreto | Eventos registrados | Ausencia no demuestra ausencia de fallo |
| Permisos | `ls -l`, `ls -ld` | Metadatos del objeto | No incluye todos los controles |
| Función | checker específico | Contrato de servicio | Solo prueba lo implementado |

## Qué debe ser FLUIDEZ

- recordar las categorías del inventario;
- distinguir los objetos Linux principales;
- pensar por capas;
- formular hipótesis antes de ejecutar;
- interpretar un resultado y su límite;
- reconocer familias de síntomas;
- aplicar timeout;
- comparar destino esperado con estado real;
- realizar una corrección mínima y validar funcionalmente;
- no exponer flags o secretos en logs.

## Qué puede ser REFERENCIA

- columnas completas y ordenamiento de `ps`;
- opciones exactas de `ss`;
- filtros de `journalctl`;
- rutas menos frecuentes de configuración;
- sintaxis larga de Docker Compose;
- opciones avanzadas de `curl`;
- tcpdump, tshark y filtros de Wireshark;
- comandos para investigar consumo profundo de disco.

Consultar referencia es válido. Ejecutar sin entender el objeto, el riesgo y el
resultado esperado no lo es.

## Errores frecuentes que hay que evitar

- llamar memoria física al almacenamiento;
- suponer que toda arquitectura de 64 bits es ARM64;
- creer que un socket es un archivo de configuración;
- afirmar que un servicio funciona porque su proceso existe;
- interpretar `Peer Address 0.0.0.0:*` como bind global;
- tratar `lo UNKNOWN` como interfaz necesariamente inactiva;
- asumir que PPID 1 identifica automáticamente una unidad;
- pensar que `adm` concede administración general;
- matar el proceso con mayor RSS sin demostrar presión;
- interpretar ausencia de logs como ausencia de errores;
- cerrar un incidente sin repetir el checker funcional.

## Active recall

Responder sin terminal. Consultar sintaxis únicamente después de explicar el
modelo.

1. ¿Qué diferencia existe entre proceso, unidad, listener y servicio?
2. ¿Por qué `active (running)` no demuestra función de extremo a extremo?
3. ¿Qué demuestra `ip route get` y qué no demuestra?
4. ¿Por qué `available` suele ser más útil que `free` al mirar memoria?
5. ¿Qué cambia el significado de `x` entre un archivo y un directorio?
6. ¿Por qué `systemctl --failed` sin resultados no garantiza disponibilidad?
7. ¿Cómo distinguís un bind local de uno ligado a todas las direcciones?
8. Si el healthcheck pasa pero falta la flag, ¿qué quedó demostrado?
9. Si un checker devuelve exit 3, ¿qué observaciones discriminan servicio
   detenido, puerto incorrecto y aplicación degradada?
10. ¿Cuál es la última etapa demostrada cuando recibís HTTP 404?
11. ¿Qué pasos cierran correctamente una recuperación?
12. ¿Qué partes del inventario deben salir con fluidez y cuáles pueden
    consultarse?

## Síntesis Feynman

Una vulnbox no se entiende mirando un único estado. Primero se construye un mapa
del host y después se sigue la cadena que produce la capacidad: identidad,
recursos, red, proceso, supervisor, socket, configuración, datos y permisos. Los
logs aportan eventos; el checker aporta evidencia funcional según un contrato.
Durante una ronda se busca la última etapa demostrada, se formula una hipótesis,
se hace una prueba que discrimine, se aplica una corrección mínima y se declara
recuperación solamente cuando la función vuelve a pasar.
