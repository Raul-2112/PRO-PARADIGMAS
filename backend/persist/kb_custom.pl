:- encoding(utf8).
/*  Enfermedades y síntomas agregados desde el panel de administración
    (RF13), sin tocar el código. Pendiente: fase 3.

    Se guarda con library(persistency) en kb_custom.db (ignorado por git).
    Al arrancar, cada hecho persistido se agrega con assertz/1 a los
    predicados dinámicos de kb/kb.pl (enfermedad/6, sintoma_de/4, ...).
*/
