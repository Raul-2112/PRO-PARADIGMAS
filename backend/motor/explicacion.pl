:- encoding(utf8).
%   Explicaciones: "¿por qué me preguntas eso?" y "¿cómo llegaste?".

porque(Sid, _{sintoma:S, texto:Texto, hipotesis_que_separa:Nombres}) :-
    pregunta_actual(Sid, S), !,
    ranking(Sid, Top),
    findall(Nombre, ( member(_-E, Top), sintoma_de(E, S, _, _),
                      enfermedad(E, _, Nombre, _, _, _) ), Nombres),
    sintoma(S, Etiqueta, _, _),
    (   es_tamizaje(S)
    ->  format(string(Texto),
               "Es una pregunta de seguridad: \"~w\" puede ser una señal de alarma y necesito descartarla.",
               [Etiqueta])
    ;   Nombres == []
    ->  format(string(Texto), "Te pregunto por \"~w\" para ampliar las posibilidades.", [Etiqueta])
    ;   atomic_list_concat(Nombres, ', ', Lista),
        format(string(Texto),
               "Te pregunto por \"~w\" porque ayuda a distinguir entre: ~w.",
               [Etiqueta, Lista])
    ).
porque(_, _{sintoma:null, texto:"Aún no te he hecho ninguna pregunta.", hipotesis_que_separa:[]}).

explicacion(Sid, CF-E, _{ id:E, nombre:Nombre, cf:CFr, mb:MBr, md:MDr,
                          a_favor:AF, en_contra:EC, contexto:Ctx }) :-
    enfermedad(E, _, Nombre, _, _, _),
    cf_detalle(Sid, E, _, MB, MD),
    CFr is round(CF * 1000) / 1000.0,
    MBr is round(MB * 1000) / 1000.0,
    MDr is round(MD * 1000) / 1000.0,
    findall(_{sintoma:S, etiqueta:L, peso:W},
            ( sintoma_de(E, S, W, _), respuesta(Sid, S, si), sintoma(S, L, _, _) ), AF),
    findall(_{sintoma:S, etiqueta:L, peso:W},
            ( sintoma_de(E, S, _, W), W > 0, respuesta(Sid, S, no), sintoma(S, L, _, _) ), EC),
    findall(_{condicion:CTxt, peso:W},
            ( contexto(E, C, suma(W)), cumple(Sid, C), format(string(CTxt), "~w", [C]) ), Ctx).

explicacion_consulta(Sid, _{enfermedades:Es, respuestas:Rs}) :-
    ranking(Sid, Top),
    maplist(explicacion(Sid), Top, Es),
    findall(_{sintoma:S, etiqueta:L, valor:V},
            ( respuesta(Sid, S, V), sintoma(S, L, _, _) ), Rs).
