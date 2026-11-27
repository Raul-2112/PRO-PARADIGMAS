:- encoding(utf8).
%   Una alarma está activa si todos sus síntomas fueron respondidos "si".
alarma_activa(Sid, Id, Mensaje, Nivel) :-
    alarma(Id, Sintomas, Mensaje, Nivel),
    forall(member(S, Sintomas), respuesta(Sid, S, si)),
    !.

%   Pregunta de tamizaje pendiente: sus disparadores están presentes y el
%   síntoma de alarma aún no se ha preguntado.
pregunta_tamizaje(Sid, S) :-
    tamizaje(S, Disparadores),
    \+ respondido(Sid, S),
    forall(member(D, Disparadores), respuesta(Sid, D, si)),
    !.

es_tamizaje(S) :- tamizaje(S, _), !.
