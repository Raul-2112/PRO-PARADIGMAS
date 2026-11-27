:- encoding(utf8).
/*  Señales de alarma: interrumpen la entrevista en cualquier momento.
      alarma(Id, SintomasPresentes, Mensaje, Nivel).
    Preguntas de tamizaje: se hacen apenas se cumplen sus disparadores,
    para no dejar pasar una alarma.
      tamizaje(SintomaDeAlarma, Disparadores).
*/
:- discontiguous alarma/4, tamizaje/2.

alarma(dolor_pecho, [dolor_pecho_opresivo],
       'El dolor de pecho opresivo puede indicar un problema del corazón. Llama al 123 o ve a urgencias ahora.',
       emergencia).
alarma(dificultad_respiratoria, [dificultad_respirar],
       'La dificultad para respirar requiere atención inmediata. Llama al 123 o ve a urgencias ahora.',
       emergencia).
alarma(meningitis_sospecha, [fiebre, rigidez_nuca],
       'Fiebre con rigidez de nuca puede ser una meningitis. Llama al 123 o ve a urgencias ahora.',
       emergencia).

tamizaje(rigidez_nuca, [fiebre, dolor_cabeza]).
tamizaje(dificultad_respirar, [tos]).
