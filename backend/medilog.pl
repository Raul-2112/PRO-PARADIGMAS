:- encoding(utf8).
%   Carga la base de conocimiento y el motor (sin servidor HTTP).
%   Lo usan server.pl y las pruebas.

:- ensure_loaded('kb/kb').
:- ensure_loaded('motor/sesion').
:- ensure_loaded('motor/certeza').
:- ensure_loaded('motor/alarmas').
:- ensure_loaded('motor/triage').
:- ensure_loaded('motor/entrevista').
:- ensure_loaded('motor/explicacion').
:- ensure_loaded('motor/texto').
