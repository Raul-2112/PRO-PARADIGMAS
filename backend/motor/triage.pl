:- encoding(utf8).
/*  Triage en 4 niveles:
      emergencia (llamar al 123) > urgente (antes de 24 h)
      > cita_prioritaria > autocuidado.
    El nivel es el máximo entre la alarma activa y la gravedad de las
    3 primeras hipótesis con CF >= 0.30.
*/
nivel_valor(autocuidado,      1).
nivel_valor(cita_prioritaria, 2).
nivel_valor(urgente,          3).
nivel_valor(emergencia,       4).

% Las graves nunca se "diagnostican": como mínimo, urgente.
gravedad_nivel(leve,     autocuidado).
gravedad_nivel(moderada, cita_prioritaria).
gravedad_nivel(alta,     urgente).
gravedad_nivel(critica,  urgente).

umbral_triage(0.30).

triage(Sid, Top, Nivel) :-
    findall(V, ( alarma_activa(Sid, _, _, Nv), nivel_valor(Nv, V) ), Va),
    primeros(3, Top, Top3),
    umbral_triage(U),
    findall(V, ( member(CF-E, Top3), CF >= U,
                 enfermedad(E, _, _, _, G, _),
                 gravedad_nivel(G, Nv), nivel_valor(Nv, V) ), Vb),
    append([[1], Va, Vb], Vs),
    max_list(Vs, Max),
    nivel_valor(Nivel, Max).
