:- encoding(utf8).
/*  Catálogo de síntomas.
      sintoma(Id, Etiqueta, Pregunta, ZonaDelCuerpo).
      sinonimo(Id, Texto)   % frases que reconoce el texto libre o la voz
*/
:- discontiguous sintoma/4, sinonimo/2.

% --- Generales ---
sintoma(fiebre, 'Fiebre', '¿Has tenido fiebre o sensación de calor intenso?', general).
sinonimo(fiebre, 'calentura').
sinonimo(fiebre, 'temperatura alta').
sintoma(escalofrios, 'Escalofríos', '¿Has tenido escalofríos?', general).
sintoma(cansancio, 'Cansancio', '¿Te sientes más cansado o débil de lo normal?', general).
sinonimo(cansancio, 'fatiga').
sinonimo(cansancio, 'debilidad').
sintoma(mialgias, 'Dolor muscular', '¿Te duelen los músculos del cuerpo?', general).
sinonimo(mialgias, 'dolor de cuerpo').
sinonimo(mialgias, 'me duele el cuerpo').
sintoma(artralgias, 'Dolor en las articulaciones', '¿Te duelen las articulaciones (rodillas, muñecas, tobillos)?', general).
sinonimo(artralgias, 'dolor de huesos').
sintoma(erupcion, 'Erupción en la piel', '¿Te han salido manchas rojas o brotes en la piel?', piel).
sinonimo(erupcion, 'manchas rojas').
sinonimo(erupcion, 'brote').
sintoma(sangrado, 'Sangrado', '¿Has tenido sangrado de encías, nariz o en la orina o heces?', general).

% --- Cabeza y neurológico ---
sintoma(dolor_cabeza, 'Dolor de cabeza', '¿Te duele la cabeza?', cabeza).
sinonimo(dolor_cabeza, 'duele la cabeza').
sinonimo(dolor_cabeza, 'cefalea').
sintoma(dolor_cabeza_pulsatil, 'Dolor de cabeza pulsátil', '¿El dolor de cabeza es pulsátil, como si latiera?', cabeza).
sinonimo(dolor_cabeza_pulsatil, 'palpita').
sinonimo(dolor_cabeza_pulsatil, 'late').
sintoma(dolor_retroocular, 'Dolor detrás de los ojos', '¿Sientes dolor detrás de los ojos?', cabeza).
sinonimo(dolor_retroocular, 'detras de los ojos').
sintoma(sensibilidad_luz, 'Molestia con la luz', '¿Te molesta la luz más de lo normal?', cabeza).
sintoma(aura_visual, 'Destellos o zigzag en la vista', '¿Antes del dolor ves destellos, luces o líneas en zigzag?', cabeza).
sintoma(rigidez_nuca, 'Rigidez de nuca', '¿Te cuesta o duele mucho bajar la barbilla hasta el pecho (cuello rígido)?', cuello).
sinonimo(rigidez_nuca, 'cuello rigido').
sinonimo(rigidez_nuca, 'nuca rigida').

% --- Respiratorio y garganta ---
sintoma(tos, 'Tos', '¿Tienes tos?', pecho).
sintoma(congestion_nasal, 'Congestión nasal', '¿Tienes la nariz tapada o con moco?', nariz).
sinonimo(congestion_nasal, 'nariz tapada').
sinonimo(congestion_nasal, 'mocos').
sintoma(estornudos, 'Estornudos', '¿Estornudas con frecuencia?', nariz).
sintoma(dolor_garganta, 'Dolor de garganta', '¿Te duele la garganta?', garganta).
sinonimo(dolor_garganta, 'duele la garganta').
sintoma(dificultad_respirar, 'Dificultad para respirar', '¿Te falta el aire o te cuesta respirar?', pecho).
sinonimo(dificultad_respirar, 'falta el aire').
sinonimo(dificultad_respirar, 'ahogo').
sinonimo(dificultad_respirar, 'no puedo respirar').
sintoma(dolor_pecho_opresivo, 'Dolor de pecho opresivo', '¿Sientes un dolor o presión fuerte en el pecho, como si te apretaran?', pecho).
sinonimo(dolor_pecho_opresivo, 'dolor de pecho').
sinonimo(dolor_pecho_opresivo, 'presion en el pecho').

% --- Digestivo ---
sintoma(diarrea, 'Diarrea', '¿Tienes diarrea (heces líquidas varias veces al día)?', abdomen).
sintoma(nauseas, 'Náuseas', '¿Sientes náuseas o ganas de vomitar?', abdomen).
sinonimo(nauseas, 'mareo de estomago').
sintoma(vomito, 'Vómito', '¿Has vomitado?', abdomen).
sinonimo(vomito, 'vomitando').
sintoma(dolor_abdominal, 'Dolor abdominal', '¿Te duele el estómago o el abdomen?', abdomen).
sinonimo(dolor_abdominal, 'dolor de estomago').
sinonimo(dolor_abdominal, 'duele el estomago').
sinonimo(dolor_abdominal, 'dolor de barriga').
