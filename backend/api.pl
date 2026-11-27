:- encoding(utf8).
/*  API JSON de MediLog (contrato en docs/api.md).
    Toda decisión médica la toma el motor; aquí solo se traduce JSON.
*/
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).

:- http_handler(root(api/consulta),  api_consulta,        [prefix]).
:- http_handler(root(api/sintomas),  api_sintomas,        []).
:- http_handler(root(api/historial), api_no_implementado, [prefix]).
:- http_handler(root(api/admin),     api_no_implementado, [prefix]).

api_consulta(Request) :-
    memberchk(method(Metodo), Request),
    (   memberchk(path_info(PI), Request) -> true ; PI = '/' ),
    atomic_list_concat(Partes0, '/', PI),
    exclude(==(''), Partes0, Partes),
    catch(with_mutex(medilog, ruta(Metodo, Partes, Request)),
          E, responder_error(E)).

% POST /api/consulta
ruta(post, [], _) :- !,
    nueva_consulta(Id),
    reply_json_dict(_{id:Id}).
% POST /api/consulta/{id}/paciente
ruta(post, [Id, paciente], Req) :- !,
    exigir_consulta(Id),
    leer_json(Req, D),
    guardar_paciente(Id, D),
    responder_paso(Id).
% POST /api/consulta/{id}/sintomas   {ids:[...], texto:"..."}
ruta(post, [Id, sintomas], Req) :- !,
    exigir_consulta(Id),
    leer_json(Req, D),
    (   get_dict(ids, D, Ids0) -> maplist(a_atomo, Ids0, Ids) ; Ids = [] ),
    (   get_dict(texto, D, T), T \== null -> texto_a_sintomas(T, Ts) ; Ts = [] ),
    append(Ids, Ts, Todos),
    forall(( member(S, Todos), sintoma(S, _, _, _) ),
           registrar_respuesta(Id, S, si, inicial)),
    responder_paso(Id).
% POST /api/consulta/{id}/respuesta  {sintoma, valor}
ruta(post, [Id, respuesta], Req) :- !,
    exigir_consulta(Id),
    leer_respuesta(Req, S, V),
    registrar_respuesta(Id, S, V, pregunta),
    responder_paso(Id).
% PUT /api/consulta/{id}/respuesta   corrige sin reiniciar (RF10)
ruta(put, [Id, respuesta], Req) :- !,
    exigir_consulta(Id),
    leer_respuesta(Req, S, V),
    registrar_respuesta(Id, S, V, correccion),
    responder_paso(Id).
% GET /api/consulta/{id}/porque
ruta(get, [Id, porque], _) :- !,
    exigir_consulta(Id),
    porque(Id, D),
    reply_json_dict(D).
% GET /api/consulta/{id}/explicacion
ruta(get, [Id, explicacion], _) :- !,
    exigir_consulta(Id),
    explicacion_consulta(Id, D),
    reply_json_dict(D).
% GET /api/consulta/{id}   (estado actual)
ruta(get, [Id], _) :- !,
    exigir_consulta(Id),
    responder_paso(Id).
ruta(_, _, _) :-
    reply_json_dict(_{error:"Ruta no encontrada"}, [status(404)]).

api_sintomas(_) :-
    findall(_{id:S, etiqueta:L, zona:Z}, sintoma(S, L, _, Z), Ls),
    reply_json_dict(Ls).

api_no_implementado(_) :-
    reply_json_dict(_{error:"Disponible en la fase 3"}, [status(501)]).

% ------------------------------------------------------------ utilidades

responder_paso(Id) :-
    paso(Id, P),
    reply_json_dict(P).

exigir_consulta(Id) :-
    (   existe_consulta(Id) -> true
    ;   throw(medilog_error(404, "La consulta no existe"))
    ).

leer_json(Req, D) :-
    catch(http_read_json_dict(Req, D), _, D = _{}).

leer_respuesta(Req, S, V) :-
    leer_json(Req, D),
    (   get_dict(sintoma, D, S0), get_dict(valor, D, V0),
        a_atomo(S0, S), a_atomo(V0, V),
        memberchk(V, [si, no, nose]), sintoma(S, _, _, _)
    ->  true
    ;   throw(medilog_error(400, "Se espera {sintoma, valor: si|no|nose} con un síntoma válido"))
    ).

a_atomo(X, A) :- atom(X), !, A = X.
a_atomo(X, A) :- atom_string(A, X).

responder_error(medilog_error(Codigo, Msg)) :- !,
    reply_json_dict(_{error:Msg}, [status(Codigo)]).
responder_error(E) :-
    E = http_reply(_), !, throw(E).
responder_error(E) :-
    print_message(error, E),
    format(string(Msg), "~w", [E]),
    reply_json_dict(_{error:Msg}, [status(500)]).
