:- encoding(utf8).
/*  Servidor de MediLog.
      swipl backend/server.pl          -> http://localhost:8080
      swipl backend/server.pl 9000     -> otro puerto
    Sirve el frontend y la API desde el mismo origen (sin CORS).
*/
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_server_files)).   % define js(.) y css(.)

:- ensure_loaded(medilog).
:- ensure_loaded(api).

:- prolog_load_context(directory, Dir),
   absolute_file_name('../frontend', F, [relative_to(Dir), file_type(directory)]),
   asserta(user:file_search_path(frontend, F)).

:- http_handler(root(.), http_reply_from_files(frontend(.), [indexes(['index.html'])]), [prefix]).
% SWI-Prolog ya registra /js y /css para sus propios archivos
% (library(http/http_server_files)) en las rutas js(.) = '/js/' y
% css(.) = '/css/'; en la misma ruta, gana la prioridad más alta.
:- http_handler(js(.),  http_reply_from_files(frontend(js),  []), [prefix, priority(10)]).
:- http_handler(css(.), http_reply_from_files(frontend(css), []), [prefix, priority(10)]).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    (   Argv = [P0|_], atom_number(P0, Puerto) -> true ; Puerto = 8080 ),
    http_server(http_dispatch, [port(Puerto)]),
    format("MediLog escuchando en http://localhost:~w~n", [Puerto]),
    thread_get_message(_).
