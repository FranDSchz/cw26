# Modelo mental de Attack/Defense CTF

## Objetivo de un equipo

En una competencia Attack/Defense, un equipo debe equilibrar simultáneamente tres frentes:

1. Atacar los servicios de los equipos rivales para encontrar vulnerabilidades, explotarlas y capturar flags.
2. Defender sus propios servicios, corrigiendo las vulnerabilidades que podrían permitir el robo de sus flags.
3. Mantener la funcionalidad legítima de los servicios para superar las comprobaciones realizadas por la infraestructura de la competencia.

Un parche defensivo no es correcto si evita el ataque pero rompe la funcionalidad que el servicio debe ofrecer.

## Componentes principales

### Gameserver

El gameserver es la infraestructura central que coordina la competencia.

Según el diseño concreto del evento, puede encargarse de:

- administrar las rondas o ticks;
- ordenar la ejecución de los checkers;
- mantener el estado de la competencia;
- recibir las flags capturadas por los equipos;
- validar si una flag es legítima y continúa vigente;
- calcular o contribuir al cálculo de la puntuación;
- actualizar el scoreboard.

El gameserver pertenece normalmente a la organización, no a cada equipo.

### Checker

Un checker es un componente que conoce la interfaz legítima de un servicio específico y ejecuta operaciones funcionales sobre él.

Por ejemplo, podría:

1. registrar un usuario;
2. iniciar sesión;
3. guardar una flag dentro de un objeto o dato privado;
4. conservar las credenciales o identificadores necesarios;
5. volver posteriormente al servicio;
6. recuperar la flag siguiendo el flujo legítimo;
7. informar al gameserver si la operación funcionó.

El checker no necesita conocer ni explotar una vulnerabilidad. Utiliza el servicio como lo haría un cliente autorizado.

Un checker funcional valida más que la existencia de un proceso o un puerto abierto: comprueba que las operaciones reales produzcan el resultado esperado.

### Vulnbox

La vulnbox es la infraestructura que recibe y debe defender cada equipo.

Puede ser una máquina virtual, un host con contenedores o alguna otra arquitectura definida por los organizadores. Puede contener:

- servicios vulnerables;
- procesos;
- configuraciones;
- datos;
- flags;
- logs;
- bases de datos u otras dependencias.

Los rivales intentan comprometer las interfaces expuestas de la vulnbox para obtener sus flags. El equipo propietario debe corregir las vulnerabilidades sin destruir la funcionalidad legítima.

### Servicio

Un servicio es una capacidad que un sistema ofrece a uno o más clientes mediante una interfaz definida.

Puede tratarse, por ejemplo, de:

- una aplicación web;
- una API;
- un servidor de archivos;
- un servicio con protocolo propio;
- un proceso binario accesible por red;
- una base de datos expuesta como servicio.

Es importante distinguir:

- **Proceso:** instancia de un programa en ejecución que puede implementar el servicio.
- **Puerto:** número utilizado junto con una dirección IP y un protocolo para identificar un endpoint de comunicación.
- **Configuración:** parámetros que determinan cómo se comporta el programa.
- **Datos:** información que el servicio administra.
- **Logs:** registros que permiten observar actividad, errores y cambios.
- **Funcionalidad:** resultado real que el servicio debe ofrecer a sus clientes.

Pueden darse tres estados diferentes:

1. El proceso está ejecutándose.
2. El puerto acepta conexiones.
3. La funcionalidad real produce el resultado correcto.

Solo el tercer estado demuestra que el servicio funciona realmente.

Por ejemplo, un servidor web puede estar activo y aceptar conexiones, pero seguir roto si los usuarios no pueden autenticarse o recuperar sus datos.

### Flag

Una flag es normalmente un valor secreto generado o administrado por la infraestructura de la competencia.

Puede almacenarse dentro de:

- una cuenta de usuario;
- un mensaje privado;
- una base de datos;
- un archivo;
- un objeto creado por el checker;
- una estructura interna del servicio.

El checker recupera la flag legítimamente usando las credenciales o referencias generadas durante el flujo funcional.

Un atacante la obtiene ilegítimamente explotando una vulnerabilidad, por ejemplo:

- un fallo de autorización;
- una inyección SQL;
- una inyección de comandos;
- una lectura arbitraria de archivos;
- una vulnerabilidad de memoria;
- un error lógico de la aplicación.

## SLA y disponibilidad

En muchas competencias, SLA es el nombre utilizado para representar la disponibilidad o el cumplimiento funcional del servicio.

La fórmula exacta depende del reglamento.

Un servicio no está disponible simplemente porque su proceso se encuentre activo o porque su puerto responda. Debe completar correctamente las operaciones funcionales verificadas por el checker.

Por eso no es una defensa válida apagar permanentemente el servicio para impedir ataques. Aunque reduzca temporalmente la superficie ofensiva, probablemente provoque fallos de disponibilidad o penalizaciones.

## Rondas y flags rotativas

Muchas competencias Attack/Defense se organizan en rondas o ticks.

Durante una ronda, el gameserver puede:

- ordenar la colocación de nuevas flags;
- verificar flags introducidas anteriormente;
- comprobar la funcionalidad de los servicios;
- recibir flags capturadas;
- actualizar la puntuación.

Cuando aparecen flags nuevas, una vulnerabilidad abierta puede transformarse en una fuente recurrente de puntos para el atacante.

Un mismo exploit podría utilizarse repetidamente:

```text
Ronda 1 → flag A → exploit → envío → puntos
Ronda 2 → flag B → mismo exploit adaptado → envío → nuevos puntos
Ronda 3 → flag C → mismo exploit adaptado → envío → nuevos puntos

```

El código central del exploit puede mantenerse, pero podrían cambiar:

* la flag;
* el usuario u objeto que la contiene;
* identificadores;
* sesiones o tokens;
* datos necesarios para localizarla.

Por eso un exploit competitivo debe localizar el objetivo actual, manejar errores, aplicar timeouts, extraer la flag y producir un resultado inequívoco.

Las flags ya enviadas deben deduplicarse porque repetir la misma normalmente no otorga nuevos puntos y desperdicia tiempo y tráfico.

## Flujo ofensivo

1. Identificar la dirección y las interfaces expuestas del servicio rival.
2. Comprobar su funcionamiento normal.
3. Buscar una vulnerabilidad.
4. Reproducirla de forma controlada.
5. Crear un exploit estable.
6. Ejecutarlo contra un objetivo autorizado.
7. Localizar y extraer la flag vigente.
8. Validar que el valor obtenido tenga el formato esperado.
9. Enviar la flag al mecanismo de puntuación.
10. Deduplicar las flags procesadas.
11. Automatizar la ejecución contra las rondas y objetivos permitidos.
12. Observar errores y adaptar el exploit si el rival aplica un parche.

## Flujo defensivo

1. Inventariar procesos, puertos, configuraciones, datos y logs.
2. Comprobar la funcionalidad legítima y guardar un estado conocido como bueno.
3. Crear backups de los elementos críticos.
4. Identificar vulnerabilidades propias o ataques observados.
5. Reproducir el fallo dentro del entorno autorizado.
6. Diseñar el cambio mínimo que cierre la vulnerabilidad.
7. Aplicar el parche.
8. Reiniciar el proceso o contenedor cuando sea necesario.
9. Ejecutar una prueba funcional equivalente al checker.
10. Verificar que los datos y las flags legítimas continúen accesibles.
11. Hacer rollback inmediatamente si el cambio rompe el servicio.
12. Documentar el procedimiento para que otro integrante pueda repetirlo.

## Relación entre ataque, defensa y disponibilidad

```text
                    GAMESERVER  
                         |  
              ordena y recibe resultados  
                         |  
                      CHECKER  
                         |  
             utiliza el flujo legítimo  
                         |  
                  SERVICIO PROPIO  
                 /               \  
                /                 \  
     camino legítimo          camino ofensivo  
      del checker              de los rivales  
            |                       |  
   verifica función          explota vulnerabilidad  
   y conservación                    |  
       de datos                       |  
            |                  obtiene una flag  
            |                       |  
      disponibilidad          envío al gameserver  

```

Mientras el checker comprueba el servicio, el equipo defensor intenta mantenerlo operativo y corregir vulnerabilidades. Al mismo tiempo, los equipos rivales buscan caminos no autorizados para extraer las flags.

## Principios operativos

* No asumir que proceso activo significa servicio funcional.
* No asumir que puerto abierto significa checker exitoso.
* No apagar permanentemente un servicio para defenderlo.
* Hacer backup antes de modificar elementos críticos.
* Aplicar cambios pequeños y reversibles.
* Verificar la funcionalidad después de cada parche.
* Mantener un rollback preparado.
* Automatizar los ataques repetibles.
* Implementar timeouts y manejo de errores.
* Deduplicar las flags antes de enviarlas.
* Monitorear logs, tráfico y cambios.
* Documentar procedimientos reproducibles por otro integrante.
* No trasladar reglas de otras competencias a Cyber War sin confirmación oficial.

## Información todavía no confirmada de Cyber War

Hasta recibir el reglamento oficial, no se debe asumir:

* la duración de cada ronda;
* que las flags roten en todas las rondas;
* la vigencia de cada flag;
* la fórmula de puntuación;
* el peso relativo de ataque y disponibilidad;
* la arquitectura exacta de la infraestructura;
* el sistema operativo utilizado;
* el uso de máquinas virtuales o contenedores;
* la cantidad y los tipos de servicios;
* que todos los equipos reciban servicios idénticos;
* el acceso administrativo disponible;
* el mecanismo de envío de flags;
* las restricciones sobre reinicios, parches y resets;
* las acciones ofensivas prohibidas.

## Fuentes conceptuales consultadas

* Documentación general de ENOWARS.
* Documentación de checkers de ENOWARS.
* Maple Bacon — Attack/Defense Primer.

Estas fuentes describen modelos y competencias externas. Se utilizan para aprender el formato, no como reglamento de Cyber War.
