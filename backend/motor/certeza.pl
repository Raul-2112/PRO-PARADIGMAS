:- encoding(utf8).
/*  Factores de certeza estilo MYCIN.

      MB_nuevo = MB + W * (1 - MB)    (síntoma presente)
      MD_nuevo = MD + W * (1 - MD)    (síntoma ausente)
      CF       = max(0, MB - MD)

    El MB inicial es la prevalencia de la enfermedad (prior).
*/

prior(alta,  0.10).
prior(media, 0.05).
prior(baja,  0.02).

combinar(Acc, W, R) :- R is Acc + W * (1 - Acc).
comb_(W, Acc, R) :- combinar(Acc, W, R).

%   cf_detalle(+Sid, +Enf, -CF, -MB, -MD)
cf_detalle(Sid, Enf, CF, MB, MD) :-
    enfermedad(Enf, _, _, _, _, Prev),
    prior(Prev, MB0),
    findall(W, (sintoma_de(Enf, S, W, _), respuesta(Sid, S, si)), Wsi),
    findall(W, (contexto(Enf, C, suma(W)), cumple(Sid, C)), Wctx),
    append(Wsi, Wctx, Wfavor),
    foldl(comb_, Wfavor, MB0, MB),
    findall(W, (sintoma_de(Enf, S, _, W), W > 0, respuesta(Sid, S, no)), Wno),
    foldl(comb_, Wno, 0, MD),
    CF is max(0, MB - MD).

cf(Sid, Enf, CF) :- cf_detalle(Sid, Enf, CF, _, _).

%   Encadenamiento hacia adelante: una enfermedad es hipótesis si al
%   menos uno de sus síntomas está presente.
hipotesis(Sid, Enf) :-
    enfermedad(Enf, _, _, _, _, _),
    once(( sintoma_de(Enf, S, _, _), respuesta(Sid, S, si) )).

%   Contexto del paciente que descarta una enfermedad.
descartada(Sid, Enf, Razon) :-
    contexto(Enf, C, requiere), \+ cumple(Sid, C), !,
    Razon = no_cumple(C).
descartada(Sid, Enf, Razon) :-
    contexto(Enf, C, excluye), cumple(Sid, C), !,
    Razon = excluida_por(C).

cumple(Sid, edad_max(N))     :- paciente(Sid, edad, E), number(E), E =< N.
cumple(Sid, edad_min(N))     :- paciente(Sid, edad, E), number(E), E >= N.
cumple(Sid, sexo(S))         :- paciente(Sid, sexo, S).
cumple(Sid, embarazo)        :- paciente(Sid, embarazo, true).
cumple(Sid, viaje(Z))        :- paciente(Sid, viajes, L), is_list(L), memberchk(Z, L).
cumple(Sid, antecedente(A))  :- paciente(Sid, antecedentes, L), is_list(L), memberchk(A, L).

%   ranking(+Sid, -Top5): lista CF-Enf ordenada de mayor a menor.
ranking(Sid, Top) :-
    findall(CF-Enf,
            ( hipotesis(Sid, Enf), \+ descartada(Sid, Enf, _), cf(Sid, Enf, CF) ),
            L),
    sort(1, @>=, L, Ordenada),
    primeros(5, Ordenada, Top).
