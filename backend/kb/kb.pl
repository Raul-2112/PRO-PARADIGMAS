:- encoding(utf8).
/*  Base de conocimiento de MediLog.

    Todos los predicados son dynamic (el panel de administración agrega
    hechos en tiempo de ejecución) y multifile (cada sistema del cuerpo
    vive en su propio archivo).

    Plantilla por enfermedad:
      enfermedad(Id, CIE10, Nombre, Sistema, Gravedad, Prevalencia).
          Gravedad    : leve | moderada | alta | critica
          Prevalencia : alta | media | baja
      sintoma_de(Enf, Sintoma, MB_si_presente, MD_si_ausente).
      contexto(Enf, Condicion, Efecto).
          Condicion : edad_max(N) | edad_min(N) | sexo(f|m) | embarazo
                      | viaje(Zona) | antecedente(A)
          Efecto    : requiere | excluye | suma(W)
      examen(Enf, Texto).  especialista(Enf, Texto).
      recomendacion(Enf, Texto).  fuente(Enf, Texto).
*/

:- dynamic
    enfermedad/6, sintoma_de/4, contexto/3, examen/2, especialista/2,
    recomendacion/2, fuente/2,
    sintoma/4, sinonimo/2,
    alarma/4, tamizaje/2.

:- multifile
    enfermedad/6, sintoma_de/4, contexto/3, examen/2, especialista/2,
    recomendacion/2, fuente/2,
    sintoma/4, sinonimo/2,
    alarma/4, tamizaje/2.

:- ensure_loaded(sintomas).
:- ensure_loaded(alarmas_kb).

% Un archivo por sistema del cuerpo (14). Se llenan por lotes:
%   fase 2: infecciosas, respiratorio, digestivo (38 enfermedades)
%   fase 3: el resto, hasta 115
:- ensure_loaded(infecciosas).
:- ensure_loaded(respiratorio).
:- ensure_loaded(digestivo).
:- ensure_loaded(piel).
:- ensure_loaded(cardiovascular).
:- ensure_loaded(neurologico).
:- ensure_loaded(endocrino).
:- ensure_loaded(musculoesqueletico).
:- ensure_loaded(orl_ojos).
:- ensure_loaded(urinario).
:- ensure_loaded(mujer).
:- ensure_loaded(pediatria).
:- ensure_loaded(salud_mental).
:- ensure_loaded(alergias_intox).
