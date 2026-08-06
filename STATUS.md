# STATUS - Estado operativo del equipo

Este archivo es la única fuente de estado durante prácticas, simulaciones y competencia. Debe ser breve, estar visible para los tres integrantes y reflejar únicamente la situación actual.

No registrar flags, contraseñas, tokens, cookies, claves ni otros secretos.

## Contexto de la sesión

- **Fecha:**
- **Ejercicio o competencia:**
- **Inicio:**
- **Fin previsto:**
- **Escenario:** espejado / con variantes / asimétrico / desconocido
- **Rol A - Ofensiva:**
- **Rol B - Defensa y disponibilidad:**
- **Rol C - Integración y automatización:**

## Estado operativo

| Hora | Servicio u objetivo | Estado | Dueño | Evidencia, hallazgo o incidente | Acción actual | Próxima actualización |
|---|---|---|---|---|---|---|
| | | | | | | |

Estados permitidos:

- `DESCONOCIDO`
- `OK`
- `DEGRADADO`
- `CAÍDO`
- `EXPLOTABLE`
- `EXPLOIT AUTOMATIZADO`
- `PARCHE EN PRUEBA`
- `PARCHEADO`

## Cola táctica

| Prioridad | Tarea | Dueño | Criterio de cierre o ETA |
|---:|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

No debe haber más de una tarea primaria y una siguiente tarea preparada por rol.

## Señales globales

- **Último checker:**
- **Disponibilidad observada:**
- **Exploit productivo actual:**
- **Runner activo:**
- **Cuello de botella actual:**
- **Próxima decisión del equipo:**

## Prioridad operativa

1. Servicio o checker caído.
2. Explotación activa conocida contra el equipo.
3. Exploit estable que produce resultados.
4. Adaptación de un vector ya probado.
5. Superficie nueva.

## Handoff

Usar este formato y completarlo en menos de 60 segundos:

```text
SERVICIO | ESTADO | EVIDENCIA | ACCIÓN HECHA | SIGUIENTE ACCIÓN | DUEÑO | ETA
```

## Métricas de cierre

Completar solo al terminar la sesión o simulación:

- **Acceso operativo:**
- **Baseline y checker:**
- **Primera vulnerabilidad verificada:**
- **Primer runner:**
- **Disponibilidad:**
- **MTTR mediano / máximo:**
- **Handoffs tardíos o inválidos:**
- **Trabajo duplicado:**
- **Regresiones por parches:**
- **Mayor pérdida y corrección:**

