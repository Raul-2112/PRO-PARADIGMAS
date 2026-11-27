:- encoding(utf8).
/*  Historial de consultas (RF12). Pendiente: fase 3.

    Se guarda con library(persistency) en historial.db (ignorado por git),
    solo con consentimiento explícito del usuario (Ley 1581 de 2012).

    Esquema previsto:
      :- persistent consulta_guardada(id:atom, fecha:float,
                                      paciente:any, respuestas:list,
                                      resultado:any, triage:atom).
*/
