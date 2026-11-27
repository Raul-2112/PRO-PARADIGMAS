:- encoding(utf8).
% Sistema: respiratorio
:- discontiguous enfermedad/6, sintoma_de/4, contexto/3, examen/2,
   especialista/2, recomendacion/2, fuente/2.

% ---------------------------------------------------------------- Gripe
enfermedad(gripe, 'J11', 'Gripe (influenza)', respiratorio, leve, alta).
sintoma_de(gripe, fiebre,         0.50, 0.40).
sintoma_de(gripe, mialgias,       0.40, 0.10).
sintoma_de(gripe, tos,            0.40, 0.20).
sintoma_de(gripe, escalofrios,    0.35, 0.05).
sintoma_de(gripe, cansancio,      0.30, 0.05).
sintoma_de(gripe, dolor_cabeza,   0.25, 0.05).
sintoma_de(gripe, dolor_garganta, 0.20, 0.05).
examen(gripe, 'Generalmente no requiere exámenes').
especialista(gripe, 'Medicina general').
recomendacion(gripe, 'Reposo, líquidos y control de la fiebre.').
recomendacion(gripe, 'Consulta si la fiebre dura más de 3 días o aparece dificultad para respirar.').
fuente(gripe, 'OMS, Nota descriptiva Gripe estacional').

% ---------------------------------------------------------------- Resfriado
enfermedad(resfriado, 'J00', 'Resfriado común', respiratorio, leve, alta).
sintoma_de(resfriado, congestion_nasal, 0.60, 0.40).
sintoma_de(resfriado, estornudos,       0.50, 0.20).
sintoma_de(resfriado, dolor_garganta,   0.35, 0.05).
sintoma_de(resfriado, tos,              0.25, 0.05).
sintoma_de(resfriado, fiebre,           0.05, 0.00).
examen(resfriado, 'No requiere exámenes').
especialista(resfriado, 'Medicina general').
recomendacion(resfriado, 'Líquidos, lavados nasales con suero fisiológico y reposo.').
fuente(resfriado, 'MinSalud Colombia, Infección respiratoria aguda').
