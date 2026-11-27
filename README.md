# MediLog: asistente médico con avatar en Prolog

Sistema experto en **SWI-Prolog** con un avatar de voz, la **"Dra. Lia"**. Entrevista al usuario, razona sobre sus síntomas con factores de certeza estilo MYCIN y entrega:

- un diagnóstico diferencial con las 5 enfermedades más probables;
- un nivel de urgencia de 4 niveles;
- una explicación de cada conclusión.

> ⚠️ **MediLog es una orientación y no reemplaza la valoración de un profesional de la salud.** En una emergencia, llama al **123**.

Proyecto final de Paradigmas de Programación. Entrega: **9 de diciembre de 2026**. El alcance completo está en [`Alcance del proyecto final MediLog...md`](./Alcance%20del%20proyecto%20final%20MediLog%2C%20asistente%20m%C3%A9dico%20con%20avatar%20en%20Prolog.md).

---

## Requisitos

| Herramienta | Versión | Uso |
|---|---|---|
| [SWI-Prolog](https://www.swi-prolog.org/download/stable) | 9.x o superior (probado con 11.1.0) | Backend, motor y pruebas |
| Chrome o Edge | reciente | Frontend, voz y micrófono |

Para instalar SWI-Prolog en Windows: `winget install SWI-Prolog.SWI-Prolog`. Si `swipl` no queda en el PATH, usa la ruta completa: `"C:\Program Files\swipl\bin\swipl.exe"`.

## Ejecutar

```sh
swipl backend/server.pl          # http://localhost:8080
swipl backend/server.pl 9000     # en otro puerto
```

El mismo servidor sirve la API y el frontend, así que no hace falta CORS ni un servidor aparte.

## Pruebas

```sh
swipl -g run_tests -t halt backend/tests/test_motor.pl
```

Estado actual: **21/21 pruebas pasan**. Cubren la validación de la base de conocimiento, la fórmula MYCIN, los casos de las 5 enfermedades, el contexto del paciente, la corrección de respuestas, las alarmas, el tamizaje, el límite de 20 preguntas y el texto libre.

---

## Estructura del repositorio

```
MEDILOG/
├── README.md
├── Alcance del proyecto final MediLog....md   # documento de alcance
├── .gitignore  .gitattributes
│
├── backend/                     # SWI-Prolog: toda decisión médica se toma aquí
│   ├── server.pl                # arranque HTTP; sirve frontend/ y la API
│   ├── api.pl                   # handlers JSON (contrato en docs/api.md)
│   ├── medilog.pl               # carga la KB y el motor (sin HTTP); lo usan las pruebas
│   │
│   ├── motor/                   # motor de inferencia
│   │   ├── sesion.pl            # estado de cada consulta en memoria (assert/retract)
│   │   ├── certeza.pl           # MB/MD/CF, prevalencia, contexto del paciente, ranking top 5
│   │   ├── entrevista.pl        # siguiente pregunta, criterio de parada, objeto "paso"
│   │   ├── alarmas.pl           # señales de alarma y preguntas de tamizaje
│   │   ├── triage.pl            # 4 niveles de urgencia
│   │   ├── explicacion.pl       # "¿por qué me preguntas eso?" y "¿cómo llegaste?"
│   │   └── texto.pl             # texto libre o voz -> ids de síntomas
│   │
│   ├── kb/                      # base de conocimiento (un archivo por sistema)
│   │   ├── kb.pl                # declaraciones y plantilla documentada; carga todo
│   │   ├── sintomas.pl          # catálogo de síntomas + sinónimos + zona del cuerpo
│   │   ├── alarmas_kb.pl        # reglas de alarma y de tamizaje
│   │   ├── infecciosas.pl  respiratorio.pl  digestivo.pl  neurologico.pl
│   │   ├── piel.pl  cardiovascular.pl  endocrino.pl  musculoesqueletico.pl
│   │   └── orl_ojos.pl  urinario.pl  mujer.pl  pediatria.pl  salud_mental.pl  alergias_intox.pl
│   │
│   ├── persist/                 # library(persistency); los *.db no se suben
│   │   ├── historial.pl         # historial de consultas con consentimiento (RF12)
│   │   └── kb_custom.pl         # lo que se agrega desde el panel de administración (RF13)
│   │
│   └── tests/
│       └── test_motor.pl        # pruebas plunit
│
├── casos/
│   └── casos_clinicos.pl        # banco de casos de validación (meta: 30)
│
├── frontend/                    # HTML + CSS + JS sin frameworks
│   ├── index.html               # consulta
│   ├── admin.html               # panel de administración
│   ├── css/estilos.css
│   ├── js/
│   │   ├── api.js               # cliente de la API
│   │   ├── app.js               # máquina de estados de la consulta
│   │   ├── voz.js               # speechSynthesis + SpeechRecognition
│   │   ├── avatar2d.js          # avatar SVG (respaldo)
│   │   ├── avatar3d.js          # avatar Three.js
│   │   ├── mapa_cuerpo.js       # selección de síntomas por zona
│   │   ├── reporte.js           # PDF con jsPDF
│   │   └── admin.js             # CRUD de la KB
│   └── vendor/                  # Three.js y jsPDF copiados localmente
│
└── docs/
    ├── api.md                   # contrato de la API JSON (congelado el 26 nov)
    ├── fuentes.md               # fuentes médicas citadas
    ├── informe/                 # informe técnico
    └── manual/                  # manual de usuario
```

---

## Cómo funciona

```
Navegador (avatar, voz, botones)  ──JSON──▶  api.pl  ──▶  motor/  ──▶  kb/
          ▲                                                  │
          └──────────────────  objeto "paso"  ◀──────────────┘
```

1. **Encadenamiento hacia adelante:** los síntomas iniciales activan como hipótesis las enfermedades que los tienen.
2. **Factores de certeza:** cada síntoma presente suma certeza y cada síntoma ausente la resta:
   - `MB ← MB + w·(1 − MB)` para cada síntoma presente;
   - `MD ← MD + w·(1 − MD)` para cada síntoma ausente;
   - `CF = MB − MD`.

   El MB inicial es la prevalencia de la enfermedad: 0.10 si es alta, 0.05 si es media y 0.02 si es baja.
3. **Contexto del paciente:** la edad, el sexo, el embarazo, los viajes y los antecedentes pueden *requerir*, *excluir* o *sumar* a una enfermedad.
4. **Entrevista dinámica:** en cada turno se elige, en este orden de prioridad:
   1. una pregunta de tamizaje de alarma pendiente;
   2. confirmar al líder si supera 0.60 (encadenamiento hacia atrás);
   3. el síntoma que más separa a las 5 hipótesis principales.
5. **Parada:** el líder supera 0.80 y le saca 0.20 al segundo, o se llega a 20 preguntas, o se activa una alarma.
6. **Triage:** se toma el máximo entre la alarma activa y la gravedad de las 3 primeras hipótesis.
7. **Recálculo completo:** el CF se recalcula desde cero en cada turno. Por eso corregir una respuesta no obliga a reiniciar la consulta, y la explicación siempre coincide con el resultado.

### Plantilla para agregar una enfermedad

Va en el archivo del sistema correspondiente dentro de `backend/kb/`:

```prolog
enfermedad(dengue, 'A90', 'Dengue', infecciosas, moderada, alta).  % gravedad, prevalencia
sintoma_de(dengue, fiebre, 0.70, 0.60).        % MB si está presente, MD si está ausente
sintoma_de(dengue, dolor_retroocular, 0.50, 0.10).
contexto(dengue, viaje(zona_endemica), suma(0.20)).   % requiere | excluye | suma(W)
examen(dengue, 'Hemograma con recuento de plaquetas').
especialista(dengue, 'Medicina general').
recomendacion(dengue, 'Hidratación abundante y reposo.').
fuente(dengue, 'MinSalud Colombia, Guía de práctica clínica de dengue').
```

Reglas que verifican las pruebas:
- cada enfermedad tiene al menos 4 síntomas;
- todos sus síntomas existen en `sintomas.pl`;
- los pesos están entre 0 y 1;
- tiene CIE-10, examen y especialista.

---

## Estado y cronograma

| Fase | Fechas | Contenido | Estado |
|---|---|---|---|
| 1. Esqueleto de punta a punta | 26–27 nov | Motor mínimo, API, frontend básico, 5 enfermedades, 3 alarmas, pruebas | ✅ |
| 2. Motor completo + lote 1 | 28 nov – 1 dic | 25 alarmas; infecciosas, respiratorio y digestivo (38 enfermedades); 10 casos | ⏳ |
| 3. Resto de la KB + frontend | 2–4 dic | 115 enfermedades, voz, avatar SVG, mapa del cuerpo, PDF, historial, admin | ⏳ |
| 4. Avatar 3D + validación | 5–7 dic | Three.js, 30 casos, calibración de pesos | ⏳ |
| 5. Entrega | 8–9 dic | Informe, manual, video y sustentación | ⏳ |

Los archivos marcados como *"Pendiente: fase N"* son la base de esa fase.

## Criterios de éxito

- La enfermedad correcta aparece en el top 3 en al menos el 80 % de los 30 casos.
- El 100 % de los casos con señal de alarma terminan en emergencia.
- Un promedio de 12 preguntas o menos por consulta, nunca más de 20.
- 115 enfermedades cargadas, cada una con CIE-10 y al menos 4 síntomas.
- Una consulta completa solo por voz en Chrome.

## Aviso y datos

- No se usan datos de pacientes reales.
- El historial se guarda solo con consentimiento, según la Ley 1581 de 2012.
- Los porcentajes son estimaciones del modelo, no probabilidades clínicas.
