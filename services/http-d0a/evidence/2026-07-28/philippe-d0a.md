# D0-A — Philippe — 2026-07-28

## Ronda 1: inventario

Tiempo: 20 minutos aprox

- Proceso: nombre del contenedor = cw26-http-d0a, nombre del servicio = web, nginx:alpine
- Puerto (interno → host): 0.0.0.0:8080->80/tcp
- Config (ruta, montada o no):
  comando: grep -A5 volumes compose.yaml
  volumes: - ./site:/usr/share/nginx/html:ro - ./config:/etc/nginx/conf.d:ro
  restart: unless-stopped
  interpretacion:
  Config: /etc/nginx/conf.d/default.conf — montada desde ./config, read-only
  Contenido: /usr/share/nginx/html/index.html (195 B) — montado desde ./site, read-only
- Logs (dónde, qué muestra un request):
  comando: docker compose logs -f
  directorio del comando: /services/http-d0a/
  request hecha: cw26-http-d0a | 172.23.0.1 - - [28/Jul/2026:04:33:39 +0000] "GET / HTTP/1.1" 200 195 "-" "curl/8.21.0"

Cadena: si borro index.html, el curl a / me devuelve 403 forbidden, y lo veo en curl con flag -i. Sin embargo, el curl a /health sigue devolviendo 200, esto me dice que el servicio esta sano y el problema es el contenido.
