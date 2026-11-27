:- encoding(utf8).
/*  Entrevista dinámica.

    Orden de prioridad de la siguiente pregunta:
      1. Tamizaje de alarma pendiente.
      2. Encadenamiento hacia atrás: si el líder supera 0.60, confirmar
         su síntoma de mayor peso aún no preguntado.
      3. Síntoma que más separa a las 5 hipótesis principales:
           score(S) = Σ CF_d·|w(d,S) − w̄(S)| + 0.1·Σ CF_d·w(d,S)

    Parada: líder > 0.80 y le saca 0.20 al segundo, o 20 preguntas, o
    no quedan síntomas por preguntar, o se activa una alarma.
*/

max_preguntas(20).
umbral_lider(0.80).
ventaja_lider(0.20).
umbral_hacia_atras(0.60).

siguiente_pregunta(Sid, Top, S) :-
    (   pregunta_tamizaje(Sid, S)
    ->  true
    ;   Top = [CF1-Lider|_], umbral_hacia_atras(U), CF1 > U,
        mejor_sintoma_lider(Sid, Lider, S)
    ->  true
    ;   mejor_discriminante(Sid, Top, S)
    ).

mejor_sintoma_lider(Sid, Enf, S) :-
    findall(W-S0, ( sintoma_de(Enf, S0, W, _), \+ respondido(Sid, S0) ), L),
    L \== [],
    max_member(_-S, L).

mejor_discriminante(Sid, Top, S) :-
    findall(S0, ( member(_-E, Top), sintoma_de(E, S0, _, _), \+ respondido(Sid, S0) ), Cs0),
    sort(Cs0, Cs),
    Cs \== [],
    findall(Sc-S0, ( member(S0, Cs), score(Top, S0, Sc) ), Ps),
    max_member(_-S, Ps).

score(Top, S, Score) :-
    findall(CF-W, ( member(CF-E, Top), peso_si(E, S, W) ), Pares),
    pairs_values(Pares, Ws),
    sum_list(Ws, Suma),
    length(Ws, N),
    Media is Suma / N,
    foldl(aporte(Media), Pares, 0, Score).

peso_si(E, S, W) :- ( sintoma_de(E, S, W0, _) -> W = W0 ; W = 0 ).

aporte(Media, CF-W, A0, A) :- A is A0 + CF * abs(W - Media) + 0.1 * CF * W.

parar(Sid, _) :-
    num_preguntas(Sid, N), max_preguntas(Max), N >= Max, !.
parar(_, [C1-_|Resto]) :-
    umbral_lider(U), C1 > U,
    ( Resto = [C2-_|_] -> true ; C2 = 0 ),
    ventaja_lider(V), C1 - C2 >= V.

/*  paso(+Sid, -Paso): el único objeto que devuelve la API.
      tipo: inicio | pregunta | resultado | emergencia
*/
paso(Sid, Paso) :-
    num_preguntas(Sid, N),
    ranking(Sid, Top),
    triage(Sid, Top, Triage),
    hipotesis_json(Top, HJ),
    (   alarma_activa(Sid, AId, Msg, _)
    ->  Tipo = emergencia, Preg = null,
        Alarma = _{id:AId, mensaje:Msg}, Avatar = emergencia
    ;   Top == [], \+ pregunta_tamizaje(Sid, _)
    ->  Tipo = inicio, Preg = null, Alarma = null, Avatar = saludo
    ;   (   pregunta_tamizaje(Sid, S) -> true   % seguridad antes que parada
        ;   \+ parar(Sid, Top), siguiente_pregunta(Sid, Top, S)
        )
    ->  Tipo = pregunta, Alarma = null, Avatar = hablando,
        fijar_pregunta_actual(Sid, S),
        sintoma(S, Etiqueta, Texto, _),
        Preg = _{sintoma:S, etiqueta:Etiqueta, texto:Texto}
    ;   Tipo = resultado, Preg = null, Alarma = null,
        ( nivel_valor(Triage, V), V >= 3 -> Avatar = preocupada ; Avatar = despedida )
    ),
    Paso = _{ tipo:Tipo, pregunta:Preg, hipotesis:HJ, triage:Triage,
              alarma:Alarma, estado_avatar:Avatar, num_pregunta:N }.

hipotesis_json(Top, HJ) :- maplist(hipotesis_dict, Top, HJ).

hipotesis_dict(CF-E, _{ id:E, nombre:Nombre, cie10:Cie, cf:CFr, gravedad:G,
                        sospecha:Sospecha, examenes:Ex, especialista:Esp,
                        recomendaciones:Rec }) :-
    enfermedad(E, Cie, Nombre, _, G, _),
    CFr is round(CF * 1000) / 1000.0,
    ( G == critica -> Sospecha = true ; Sospecha = false ),
    findall(X, examen(E, X), Ex),
    ( especialista(E, Esp) -> true ; Esp = 'Medicina general' ),
    findall(R, recomendacion(E, R), Rec).
