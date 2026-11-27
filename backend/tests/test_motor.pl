:- encoding(utf8).
/*  Pruebas del motor.
      swipl -g run_tests -t halt backend/tests/test_motor.pl
*/
:- use_module(library(plunit)).
:- ensure_loaded('../medilog').

caso(Respuestas, Sid) :-
    caso(Respuestas, _{edad:30, sexo:f, embarazo:false, viajes:[], antecedentes:[]}, Sid).
caso(Respuestas, Paciente, Sid) :-
    nueva_consulta(Sid),
    guardar_paciente(Sid, Paciente),
    forall(member(S=V, Respuestas), registrar_respuesta(Sid, S, V, pregunta)).

lider(Sid, E) :- ranking(Sid, [_-E|_]).

tipo_paso(Sid, Tipo) :- paso(Sid, P), get_dict(tipo, P, Tipo).

% ------------------------------------------------------------------ KB
:- begin_tests(kb).

test(cada_enfermedad_tiene_4_sintomas) :-
    forall(enfermedad(E, _, _, _, _, _),
           ( aggregate_all(count, sintoma_de(E, _, _, _), N),
             assertion(N >= 4) )).

test(sintomas_existen_en_catalogo) :-
    forall(sintoma_de(_, S, _, _), assertion(sintoma(S, _, _, _))).

test(pesos_en_rango) :-
    forall(sintoma_de(_, _, MB, MD),
           assertion((MB >= 0, MB =< 1, MD >= 0, MD =< 1))).

test(examen_y_especialista) :-
    forall(enfermedad(E, Cie, _, _, _, _),
           ( assertion(atom(Cie)),
             assertion(examen(E, _)),
             assertion(especialista(E, _)) )).

test(alarmas_usan_sintomas_validos) :-
    forall(( alarma(_, Ss, _, _), member(S, Ss) ), assertion(sintoma(S, _, _, _))),
    forall(tamizaje(S, _), assertion(sintoma(S, _, _, _))).

:- end_tests(kb).

% ------------------------------------------------------------- Certeza
:- begin_tests(certeza).

test(formula_mycin) :-
    combinar(0.5, 0.5, R),
    assertion(abs(R - 0.75) < 1.0e-9).

test(sin_sintomas_no_hay_hipotesis) :-
    caso([], Sid),
    ranking(Sid, Top),
    assertion(Top == []).

test(dengue) :-
    caso([fiebre=si, dolor_retroocular=si, mialgias=si, artralgias=si], Sid),
    assertion(lider(Sid, dengue)).

test(resfriado) :-
    caso([congestion_nasal=si, estornudos=si, dolor_garganta=si, fiebre=no], Sid),
    assertion(lider(Sid, resfriado)).

test(gastroenteritis) :-
    caso([diarrea=si, vomito=si, dolor_abdominal=si], Sid),
    assertion(lider(Sid, gastroenteritis)).

test(migrana) :-
    caso([dolor_cabeza=si, dolor_cabeza_pulsatil=si, sensibilidad_luz=si, fiebre=no], Sid),
    assertion(lider(Sid, migrana)).

test(evidencia_en_contra_baja_cf) :-
    caso([dolor_retroocular=si, mialgias=si], S1),
    caso([dolor_retroocular=si, mialgias=si, fiebre=no], S2),
    cf(S1, dengue, CF1), cf(S2, dengue, CF2),
    assertion(CF2 < CF1).

test(contexto_viaje_sube_dengue) :-
    caso([fiebre=si], S1),
    caso([fiebre=si], _{edad:30, sexo:m, viajes:["zona_endemica"]}, S2),
    cf(S1, dengue, CF1), cf(S2, dengue, CF2),
    assertion(CF2 > CF1).

test(correccion_recalcula) :-
    caso([diarrea=si, vomito=si], Sid),
    cf(Sid, gastroenteritis, Antes),
    registrar_respuesta(Sid, diarrea, no, correccion),
    cf(Sid, gastroenteritis, Despues),
    assertion(Despues < Antes),
    num_preguntas(Sid, N),
    assertion(N =:= 2).

:- end_tests(certeza).

% ------------------------------------------------------------- Alarmas
:- begin_tests(alarmas).

test(dolor_pecho_emergencia) :-
    caso([dolor_pecho_opresivo=si], Sid),
    tipo_paso(Sid, T), assertion(T == emergencia),
    paso(Sid, P), get_dict(triage, P, Tr), assertion(Tr == emergencia).

test(meningitis_emergencia) :-
    caso([fiebre=si, dolor_cabeza=si, rigidez_nuca=si], Sid),
    tipo_paso(Sid, T), assertion(T == emergencia).

test(tamizaje_rigidez_nuca) :-
    caso([fiebre=si, dolor_cabeza=si], Sid),
    paso(Sid, P),
    get_dict(pregunta, P, Q), get_dict(sintoma, Q, S),
    assertion(S == rigidez_nuca).

:- end_tests(alarmas).

% ---------------------------------------------------------- Entrevista
:- begin_tests(entrevista).

test(primera_pregunta_es_valida) :-
    caso([fiebre=si], Sid),
    paso(Sid, P),
    get_dict(tipo, P, T), assertion(T == pregunta),
    get_dict(pregunta, P, Q), get_dict(sintoma, Q, S),
    assertion(\+ respondido(Sid, S)).

%   Simula una consulta respondiendo "no" a todo: debe terminar y nunca
%   pasar de 20 preguntas.
test(termina_y_respeta_limite) :-
    caso([fiebre=si], Sid),
    simular_no(Sid, 0, N),
    assertion(N =< 20).

simular_no(Sid, K, N) :-
    paso(Sid, P), get_dict(tipo, P, T),
    (   T == pregunta, K < 50
    ->  get_dict(pregunta, P, Q), get_dict(sintoma, Q, S),
        registrar_respuesta(Sid, S, no, pregunta),
        K1 is K + 1,
        simular_no(Sid, K1, N)
    ;   N = K
    ).

test(porque_explica) :-
    caso([fiebre=si], Sid),
    paso(Sid, _),
    porque(Sid, D),
    get_dict(texto, D, Txt),
    assertion(string(Txt)).

test(texto_libre) :-
    texto_a_sintomas("Tengo calentura y me duele la cabeza, con diarrea", Ss),
    assertion(memberchk(fiebre, Ss)),
    assertion(memberchk(dolor_cabeza, Ss)),
    assertion(memberchk(diarrea, Ss)).

:- end_tests(entrevista).
