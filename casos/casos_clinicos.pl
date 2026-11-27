:- encoding(utf8).
/*  Banco de casos clínicos de validación (meta: 30, fase 4).

      caso(Id, Paciente, SintomasPresentes, EnfermedadEsperada, NivelEsperado).

    Criterios de éxito:
      - la enfermedad esperada aparece en el top 3 en al menos el 80 % de los casos;
      - el 100 % de los casos con señal de alarma terminan en emergencia;
      - un promedio de 12 preguntas o menos, nunca más de 20.

    En la simulación, el sistema responde "si" a los síntomas de la lista
    y "no" a todo lo demás. EnfermedadEsperada = ninguna cuando solo
    importa el nivel de triage (casos de alarma).
*/
:- discontiguous caso/5.

caso(c01, _{edad:30, sexo:f}, [fiebre, dolor_retroocular, mialgias, artralgias, dolor_cabeza], dengue, cita_prioritaria).
caso(c02, _{edad:30, sexo:m}, [tos, fiebre, mialgias, escalofrios, cansancio], gripe, autocuidado).
caso(c03, _{edad:25, sexo:f}, [congestion_nasal, estornudos, dolor_garganta], resfriado, autocuidado).
caso(c04, _{edad:40, sexo:m}, [diarrea, vomito, nauseas, dolor_abdominal], gastroenteritis, autocuidado).
caso(c05, _{edad:28, sexo:f}, [dolor_cabeza, dolor_cabeza_pulsatil, sensibilidad_luz, nauseas], migrana, autocuidado).
caso(c06, _{edad:20, sexo:m}, [fiebre, dolor_cabeza, rigidez_nuca], ninguna, emergencia).
caso(c07, _{edad:60, sexo:m}, [dolor_pecho_opresivo], ninguna, emergencia).
