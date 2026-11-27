:- encoding(utf8).
/*  Estado de cada consulta, en memoria (assert/retract).
      consulta(Id, Inicio).
      paciente(Id, Campo, Valor).
      respuesta(Id, Sintoma, si|no|nose).
      pregunta_hecha(Id, Sintoma).     % cuenta para el límite de 20
      pregunta_actual(Id, Sintoma).    % para "¿por qué me preguntas eso?"
*/
:- use_module(library(uuid)).

:- dynamic consulta/2, paciente/3, respuesta/3, pregunta_hecha/2, pregunta_actual/2.

nueva_consulta(Id) :-
    uuid(Id),
    get_time(T),
    assertz(consulta(Id, T)).

existe_consulta(Id) :- consulta(Id, _), !.

%   guardar_paciente(+Id, +Dict): reemplaza todos los datos del paciente.
guardar_paciente(Id, Dict) :-
    retractall(paciente(Id, _, _)),
    forall(get_dict(K, Dict, V0),
           ( valor_prolog(V0, V), assertz(paciente(Id, K, V)) )).

valor_prolog(S, A) :- string(S), !, atom_string(A, S).
valor_prolog(L, L2) :- is_list(L), !, maplist(valor_prolog, L, L2).
valor_prolog(V, V).

%   registrar_respuesta(+Id, +Sintoma, +Valor, +Origen)
%   Origen: inicial | pregunta | correccion. Recalcular es automático,
%   porque el CF se calcula desde las respuestas en cada turno.
registrar_respuesta(Id, S, V, Origen) :-
    retractall(respuesta(Id, S, _)),
    assertz(respuesta(Id, S, V)),
    (   Origen == pregunta, \+ pregunta_hecha(Id, S)
    ->  assertz(pregunta_hecha(Id, S))
    ;   true
    ).

respondido(Id, S) :- respuesta(Id, S, _).

num_preguntas(Id, N) :- aggregate_all(count, pregunta_hecha(Id, _), N).

fijar_pregunta_actual(Id, S) :-
    retractall(pregunta_actual(Id, _)),
    assertz(pregunta_actual(Id, S)).

borrar_consulta(Id) :-
    retractall(consulta(Id, _)),
    retractall(paciente(Id, _, _)),
    retractall(respuesta(Id, _, _)),
    retractall(pregunta_hecha(Id, _)),
    retractall(pregunta_actual(Id, _)).

primeros(N, L, P) :-
    length(L, Len),
    (   Len =< N -> P = L
    ;   length(P, N), append(P, _, L)
    ).
