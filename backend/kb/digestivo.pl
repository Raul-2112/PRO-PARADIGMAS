:- encoding(utf8).
% Sistema: digestivo
:- discontiguous enfermedad/6, sintoma_de/4, contexto/3, examen/2,
   especialista/2, recomendacion/2, fuente/2.

% ---------------------------------------------------------------- Gastroenteritis
enfermedad(gastroenteritis, 'A09', 'Gastroenteritis aguda', digestivo, leve, alta).
sintoma_de(gastroenteritis, diarrea,         0.70, 0.60).
sintoma_de(gastroenteritis, vomito,          0.40, 0.10).
sintoma_de(gastroenteritis, nauseas,         0.35, 0.05).
sintoma_de(gastroenteritis, dolor_abdominal, 0.35, 0.05).
sintoma_de(gastroenteritis, fiebre,          0.15, 0.00).
examen(gastroenteritis, 'Coprológico si dura más de 3 días').
especialista(gastroenteritis, 'Medicina general').
recomendacion(gastroenteritis, 'Suero de rehidratación oral en tomas pequeñas y frecuentes.').
recomendacion(gastroenteritis, 'Consulta si hay sangre en las heces, no puedes tomar líquidos o hay signos de deshidratación.').
fuente(gastroenteritis, 'OMS, Tratamiento de la diarrea').
