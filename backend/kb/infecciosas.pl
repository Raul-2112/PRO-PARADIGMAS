:- encoding(utf8).
% Sistema: infecciosas y tropicales
:- discontiguous enfermedad/6, sintoma_de/4, contexto/3, examen/2,
   especialista/2, recomendacion/2, fuente/2.

% ---------------------------------------------------------------- Dengue
enfermedad(dengue, 'A90', 'Dengue', infecciosas, moderada, alta).
sintoma_de(dengue, fiebre,            0.70, 0.60).
sintoma_de(dengue, dolor_retroocular, 0.50, 0.10).
sintoma_de(dengue, mialgias,          0.40, 0.10).
sintoma_de(dengue, artralgias,        0.30, 0.05).
sintoma_de(dengue, erupcion,          0.30, 0.05).
sintoma_de(dengue, dolor_cabeza,      0.25, 0.05).
contexto(dengue, viaje(zona_endemica), suma(0.20)).
examen(dengue, 'Hemograma con recuento de plaquetas').
examen(dengue, 'Prueba NS1 o IgM para dengue').
especialista(dengue, 'Medicina general').
recomendacion(dengue, 'Hidratación abundante y reposo.').
recomendacion(dengue, 'Evita el ibuprofeno y la aspirina; consulta si hay sangrado o dolor abdominal intenso.').
fuente(dengue, 'MinSalud Colombia, Guía de práctica clínica de dengue').
