:- encoding(utf8).
% Sistema: neurológico
:- discontiguous enfermedad/6, sintoma_de/4, contexto/3, examen/2,
   especialista/2, recomendacion/2, fuente/2.

% ---------------------------------------------------------------- Migraña
enfermedad(migrana, 'G43', 'Migraña', neurologico, leve, media).
sintoma_de(migrana, dolor_cabeza,          0.50, 0.70).
sintoma_de(migrana, dolor_cabeza_pulsatil, 0.60, 0.10).
sintoma_de(migrana, sensibilidad_luz,      0.45, 0.05).
sintoma_de(migrana, aura_visual,           0.50, 0.00).
sintoma_de(migrana, nauseas,               0.25, 0.00).
examen(migrana, 'Diagnóstico clínico; imágenes solo si hay signos de alarma').
especialista(migrana, 'Medicina general; Neurología si es frecuente').
recomendacion(migrana, 'Descansa en un lugar oscuro y silencioso; lleva un diario de los dolores.').
fuente(migrana, 'OMS, Cefaleas: nota descriptiva').
