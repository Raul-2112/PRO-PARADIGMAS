:- encoding(utf8).
%   Texto libre o voz -> lista de ids de síntomas.
%   Normaliza (minúsculas, sin tildes) y busca etiquetas y sinónimos.

%   Se compara por palabras completas: " tos " no coincide en "gustos".

texto_a_sintomas(Texto, Sintomas) :-
    normalizar(Texto, N),
    findall(S,
            (   ( sintoma(S, Frase, _, _) ; sinonimo(S, Frase) ),
                normalizar(Frase, NF),
                sub_string(N, _, _, _, NF)
            ),
            S0),
    sort(S0, Sintomas).

%   minúsculas, sin tildes, signos -> espacio, rodeado de espacios.
normalizar(Texto, Normal) :-
    string_lower(Texto, Min),
    string_chars(Min, Cs),
    maplist(limpiar, Cs, Cs2),
    string_chars(N0, Cs2),
    split_string(N0, " ", " ", Ps0),
    exclude(==(""), Ps0, Ps),
    atomic_list_concat(Ps, ' ', Unido),
    format(string(Normal), " ~w ", [Unido]).

limpiar('á', a) :- !.
limpiar('é', e) :- !.
limpiar('í', i) :- !.
limpiar('ó', o) :- !.
limpiar('ú', u) :- !.
limpiar('ü', u) :- !.
limpiar('ñ', 'ñ') :- !.
limpiar(C, C) :- char_type(C, alnum), !.
limpiar(_, ' ').
