# Contrato de la API JSON de MediLog

Congelado el 26 de noviembre de 2026. El servidor (`backend/server.pl`) sirve la API y el frontend desde el mismo origen, `http://localhost:8080`.

| Método | Ruta | Cuerpo | Respuesta |
|---|---|---|---|
| POST | `/api/consulta` | `{}` | `{id}` |
| GET | `/api/consulta/{id}` | — | `paso` |
| POST | `/api/consulta/{id}/paciente` | `{edad, sexo:"f"\|"m", embarazo, antecedentes[], viajes[]}` | `paso` |
| POST | `/api/consulta/{id}/sintomas` | `{ids?:[...], texto?:"..."}` | `paso` |
| POST | `/api/consulta/{id}/respuesta` | `{sintoma, valor:"si"\|"no"\|"nose"}` | `paso` |
| PUT | `/api/consulta/{id}/respuesta` | igual (corrige sin reiniciar, RF10) | `paso` |
| GET | `/api/consulta/{id}/porque` | — | `{sintoma, texto, hipotesis_que_separa[]}` |
| GET | `/api/consulta/{id}/explicacion` | — | `{enfermedades:[{id, nombre, cf, mb, md, a_favor[], en_contra[], contexto[]}], respuestas[]}` |
| GET | `/api/sintomas` | — | `[{id, etiqueta, zona}]` |
| GET/POST | `/api/historial` | — | *501 hasta la fase 3* |
| GET/POST/DELETE | `/api/admin/...` | — | *501 hasta la fase 3* |

## Objeto `paso`

```json
{
  "tipo": "inicio | pregunta | resultado | emergencia",
  "pregunta": {"sintoma": "fiebre", "etiqueta": "Fiebre", "texto": "¿Has tenido fiebre...?"},
  "hipotesis": [{
    "id": "dengue", "nombre": "Dengue", "cie10": "A90", "cf": 0.62,
    "gravedad": "moderada", "sospecha": false,
    "examenes": ["..."], "especialista": "...", "recomendaciones": ["..."]
  }],
  "triage": "emergencia | urgente | cita_prioritaria | autocuidado",
  "alarma": {"id": "dolor_pecho", "mensaje": "..."},
  "estado_avatar": "saludo | hablando | preocupada | emergencia | despedida",
  "num_pregunta": 7
}
```

- `inicio`: todavía no hay síntomas reconocidos.
- `pregunta` y `alarma` son `null` cuando no aplican.
- `hipotesis` lista hasta 5 elementos, ordenados por CF de mayor a menor.

Errores: `{error: "mensaje"}` con estado 400, 404 o 500.
