# Alcance del proyecto final: MediLog, asistente médico con avatar en Prolog

Nov 25, 2026 · @Raul

## Descripción general

MediLog es un sistema experto en SWI-Prolog con un avatar animado que entrevista por voz al usuario, razona sobre sus síntomas y entrega un diagnóstico diferencial (las enfermedades más probables), con nivel de urgencia y explicación de cada conclusión.

No es un listado de consultas fijas: el avatar decide en cada turno cuál es la siguiente pregunta más útil, como lo haría un médico en la consulta, hasta tener suficiente certeza o detectar una señal de alarma.

**Problema que atiende:** muchas personas no saben si sus síntomas requieren urgencias, una cita o solo cuidados en casa. MediLog orienta esa decisión; no reemplaza la valoración de un profesional de la salud.

## Objetivos

**General:** desarrollar un sistema experto en Prolog, con un avatar de voz, que oriente el diagnóstico de las enfermedades más frecuentes en atención primaria y clasifique la urgencia de cada caso.

**Específicos:**

1. Construir una base de conocimiento modular de al menos 115 enfermedades, organizada por sistemas del cuerpo.
2. Implementar un motor de inferencia con factores de certeza, evidencia a favor y en contra, y datos de contexto del paciente.
3. Diseñar una entrevista dinámica que elija la pregunta que más reduce la incertidumbre.
4. Clasificar cada caso en 4 niveles de urgencia y detectar señales de alarma en cualquier momento.
5. Explicar cada diagnóstico: qué síntomas lo apoyan, cuáles lo debilitan y qué reglas se usaron.
6. Crear un avatar animado que hable y escuche en español, con expresiones según el estado de la conversación.
7. Validar el sistema con al menos 30 casos clínicos de prueba antes del 9 de diciembre de 2026.

## Cobertura médica

"Casi cualquier enfermedad" se define como **al menos 115 enfermedades frecuentes en consulta de atención primaria en Colombia**, repartidas en 14 sistemas, con unos 300 síntomas. La meta extendida es llegar a 130 si el tiempo alcanza. Cada enfermedad lleva su código CIE-10 para que la base sea verificable y ampliable.

| Sistema | Ejemplos | Enfermedades |
| --- | --- | --- |
| Infecciosas y tropicales | Dengue, chikungunya, zika, malaria, leptospirosis, varicela, hepatitis A | 14 |
| Respiratorio | Resfriado, gripe, COVID-19, sinusitis, bronquitis, neumonía, asma, EPOC, tuberculosis | 12 |
| Digestivo | Gastroenteritis, gastritis, reflujo, colon irritable, apendicitis, colecistitis, parasitosis | 12 |
| Piel | Dermatitis, acné, micosis, urticaria, escabiosis, celulitis, herpes zóster | 10 |
| Cardiovascular | Hipertensión, angina, infarto, insuficiencia cardíaca, arritmia, trombosis venosa | 8 |
| Neurológico | Migraña, cefalea tensional, vértigo, epilepsia, ACV, meningitis | 8 |
| Endocrino y metabólico | Diabetes tipo 1 y 2, hipotiroidismo, hipertiroidismo, anemia, dislipidemia | 8 |
| Musculoesquelético | Lumbalgia, artritis, artrosis, gota, tendinitis, esguince | 8 |
| Ojos, oídos, nariz y garganta | Conjuntivitis, otitis, amigdalitis, rinitis alérgica, orzuelo | 7 |
| Urinario y renal | Infección urinaria, cálculos renales, pielonefritis, hiperplasia de próstata | 6 |
| Salud de la mujer | Vaginosis, dismenorrea, ovario poliquístico, alarmas en el embarazo | 6 |
| Pediatría | Bronquiolitis, mano-pie-boca, deshidratación infantil, otitis media | 6 |
| Salud mental (solo tamizaje) | Ansiedad, depresión, insomnio, estrés | 5 |
| Alergias e intoxicaciones | Anafilaxia, alergia alimentaria, intoxicación alimentaria, golpe de calor | 5 |

Las enfermedades graves (infarto, ACV, meningitis, anafilaxia, apendicitis) no se "diagnostican": se detectan como sospecha y el avatar remite de inmediato a urgencias.

## Motor de inferencia

El motor es la parte que eleva el proyecto sobre consultas básicas: razona con incertidumbre, pregunta de forma inteligente y explica sus conclusiones.

1. **Base de conocimiento modular.** Un archivo `.pl` por sistema del cuerpo. Cada enfermedad tiene código CIE-10, gravedad, prevalencia, síntomas con su peso, exámenes, especialista y recomendaciones generales.
2. **Evidencia a favor y en contra.** Un síntoma presente suma certeza (MB) y uno ausente la resta (MD). Por ejemplo, no tener fiebre debilita el dengue.
3. **Factores de certeza estilo MYCIN.** La certeza final de cada enfermedad se calcula así:

```latex
CF = MB - MD, \quad MB_{nuevo} = MB_1 + MB_2 (1 - MB_1)
```

4. **Contexto del paciente.** Edad, sexo, embarazo, duración de los síntomas, intensidad, antecedentes, viajes y temporada. Ejemplos: la malaria solo sube si hubo viaje a zona endémica; la bronquiolitis solo aplica en menores de 2 años.
5. **Entrevista dinámica.** En cada turno el motor elige el síntoma no preguntado que más separa a las 5 hipótesis principales. Se detiene cuando la primera supera 80 % y aventaja a la segunda por 20 puntos, o tras 20 preguntas.
6. **Encadenamiento hacia adelante y hacia atrás.** Hacia adelante genera hipótesis desde los síntomas; hacia atrás intenta confirmar la hipótesis líder preguntando por sus síntomas clave.
7. **Señales de alarma.** Unas 25 reglas (dolor de pecho opresivo, dificultad para respirar, rigidez de nuca, debilidad de un lado del cuerpo, sangrado) interrumpen la entrevista en cualquier momento.
8. **Triage en 4 niveles.** Emergencia (llamar al 123), urgente (antes de 24 h), cita prioritaria y autocuidado en casa.
9. **Diagnóstico diferencial.** Las 5 enfermedades más probables con su porcentaje, exámenes sugeridos y especialista.
10. **Explicación.** El usuario puede preguntar "¿por qué me preguntas eso?" y "¿cómo llegaste a ese resultado?"; el motor muestra la traza de reglas y síntomas usados.

## Avatar y sonido

El avatar, la "Dra. Lia", es un personaje 3D animado con Three.js. Habla con voz sintetizada, escucha por micrófono y cambia de expresión según el momento de la consulta. Si el modelo 3D se atrasa, una versión 2D en SVG queda como respaldo para la entrega.

| Estado | Animación | Sonido |
| --- | --- | --- |
| Saludo | Sonríe y saluda con la mano | Voz de bienvenida y tono suave |
| Escuchando | Inclina la cabeza, indicador de micrófono | Tono corto al abrir el micrófono |
| Pensando | Mira hacia arriba, puntos animados | Sonido leve de proceso |
| Hablando | Boca sincronizada con la voz | Voz sintetizada en español |
| Preocupada | Cejas fruncidas, fondo ámbar | Tono de aviso |
| Emergencia | Fondo rojo, gesto serio | Alarma corta y mensaje de llamar al 123 |
| Despedida | Sonríe y asiente | Voz de cierre |

- **Voz:** `speechSynthesis` del navegador con voz en español; velocidad y tono configurables.
- **Escucha:** `SpeechRecognition` (funciona en Chrome y Edge). Siempre hay respuesta por botones y texto como alternativa.
- **Sincronización de labios:** la boca se abre y cierra con los eventos de palabra de la voz.
- **Accesibilidad:** subtítulos de todo lo que dice el avatar y botón para silenciar.

## Arquitectura y tecnologías

&#91;embedded content: arquitectura · 3 capas\]

El navegador solo muestra y escucha; toda decisión médica la toma Prolog, que guarda el estado de cada consulta en memoria con `assert` y `retract`.

- **Backend:** SWI-Prolog 9 con `library(http)` para la API JSON y `plunit` para pruebas.
- **Frontend:** HTML, CSS y JavaScript sin frameworks; avatar 3D con Three.js; Web Speech API para voz.
- **Reporte:** PDF generado en el navegador (jsPDF).
- **Historial:** `library(persistency)` de SWI-Prolog.

## Requisitos

**Funcionales**

| ID | Requisito | Prioridad |
| --- | --- | --- |
| RF01 | Registrar datos del paciente: edad, sexo, embarazo, antecedentes, viajes recientes | Alta |
| RF02 | Recibir síntomas iniciales por voz, texto o selección en un mapa del cuerpo | Alta |
| RF03 | Hacer preguntas dinámicas hasta llegar a un diagnóstico o al límite de 20 | Alta |
| RF04 | Detectar señales de alarma y activar el modo emergencia | Alta |
| RF05 | Mostrar las 5 enfermedades más probables con su porcentaje | Alta |
| RF06 | Clasificar el caso en 4 niveles de urgencia | Alta |
| RF07 | Explicar por qué hace cada pregunta y cómo llegó al resultado | Alta |
| RF08 | Sugerir exámenes, especialista y cuidados generales | Media |
| RF09 | Hablar y escuchar en español con el avatar animado | Alta |
| RF10 | Corregir una respuesta anterior sin reiniciar la consulta | Media |
| RF11 | Generar un reporte PDF de la consulta | Media |
| RF12 | Guardar el historial de consultas del usuario | Media |
| RF13 | Panel de administración para agregar enfermedades y síntomas sin tocar código | Media |

**No funcionales**

- Respuesta del motor en menos de 1 segundo por pregunta.
- Funciona en Chrome y Edge de escritorio y en móvil (con texto si no hay micrófono).
- Aviso visible en todas las pantallas: es una orientación y no reemplaza al médico.
- Sin datos de pacientes reales; si se guarda historial, con consentimiento, según la Ley 1581 de 2012 de protección de datos.
- Código Prolog documentado y con pruebas unitarias (`plunit`).

## Fuera del alcance

MediLog orienta; no diagnostica con validez médica. Queda fuera del proyecto:

- Formular medicamentos o indicar dosis.
- Enfermedades raras, cánceres y enfermedades que solo se confirman con laboratorio o imagen (se mencionan como "requiere estudio").
- Leer exámenes de laboratorio, radiografías o fotos de lesiones.
- Diagnóstico psiquiátrico: salud mental solo tiene tamizaje y remisión.
- Uso con pacientes reales o conexión con historias clínicas de EPS o IPS.
- Aprendizaje automático: los pesos los define el equipo a partir de fuentes médicas, no se entrenan con datos.

Todo lo demás, incluidos el historial de consultas, el panel de administración y el avatar 3D, se entrega terminado el 9 de diciembre de 2026, sin dejar partes para una versión futura.

**Limitación principal:** los porcentajes son estimaciones del modelo, no probabilidades clínicas. La calidad depende de las fuentes usadas para la base de conocimiento (guías del Ministerio de Salud, OMS y textos de medicina general), que deben citarse en el informe.

## Entregables, cronograma y criterios de éxito

&#91;embedded content: cronograma · 14 días, 5 fases\]

El cronograma va del 25 de noviembre al 9 de diciembre de 2026, 14 días. La prioridad es que el motor funcione completo antes de pulir el avatar.

**Entregables**

1. Código fuente en un repositorio: backend Prolog, base de conocimiento y frontend con avatar.
2. Informe técnico: arquitectura, reglas, fórmulas de certeza y fuentes médicas consultadas.
3. Banco de 30 casos clínicos de prueba con el resultado esperado y el obtenido.
4. Manual de usuario y video de demostración de 3 a 5 minutos.
5. Sustentación con demo en vivo.

**Criterios de éxito**

- La enfermedad correcta aparece entre las 3 primeras en al menos 80 % de los 30 casos.
- El 100 % de los casos con señal de alarma terminan en nivel de emergencia.
- Promedio de 12 preguntas o menos por consulta, nunca más de 20.
- 115 enfermedades cargadas (meta extendida: 130), cada una con código CIE-10 y al menos 4 síntomas.
- El avatar completa una consulta entera solo por voz en Chrome.

## Riesgos

| Riesgo | Efecto | Mitigación |
| --- | --- | --- |
| Cargar 115 enfermedades en 2 semanas toma más tiempo del previsto | La base queda incompleta | Plantilla única por enfermedad; cargar por lotes de sistemas, empezando por infecciosas, respiratorio y digestivo (38 enfermedades), que ya permiten una demo completa |
| Pesos de los síntomas mal calibrados | Diagnósticos poco precisos | Ajustarlos con los 30 casos de prueba y, si es posible, revisión de un profesional de salud |
| El reconocimiento de voz falla o no hay micrófono | El usuario no puede responder | Botones Sí / No / No sé y campo de texto siempre visibles |
| Voces en español distintas según el navegador | El avatar suena diferente | Elegir la voz disponible y probar en Chrome y Edge |
| El usuario toma el resultado como diagnóstico real | Decisiones de salud equivocadas | Aviso permanente, lenguaje de "posible" y remisión al médico en todos los resultados |
| Integración entre Prolog y el frontend | Retrasos al final | API JSON definida el 26 de noviembre y probada desde el inicio |
