% - -- HECHOS (Base de Conocimiento) ---
personaje( 'Elara', 5, 100). 
personaje('Kael', 3, 80). 
personaje('Rin', 7, 120).
mision(m1, 'Bosque de Sombras', 2, 50). 
mision(m2, 'Cueva del Dragón', 5, 120). 
mision(m3, 'Torre Arcana', 7, 200).
inventario( 'Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).
requiere(m2, escudo).
requiere(m2, pocion) .
requiere(m3, grimorio).
requiere(m3, pocion).

% verificacion de nivel
puede_aceptar(Personaje, ID_Mision):-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

% calculo recursivo de xp 
xp_acumulada(0, 0).
xp_acumulada(N, Total):-
    N > 0,
    N1 is N -1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

%  VERIFICACION DE INVENTARIO
tiene_requerido(Personaje, Objeto):-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

% ======================================
% operadores relacionales
% ======================================

% detectar mismo nivel
mismo_nivel(P1, P2):-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

% validar balance estricto
es_balanceado(Personaje):-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

% Controlaador de errores


% ================================
% Procesamiento de dos listas
% ================================


%1. Fusionar inventarios de dos personajes

%fusionar_equipo([],[]).
fusionar_equipo(P1, P2, EquipoFusionado):-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

%fusionar_equipo(P|Resto, EquipoFusionado):-
%   inventario(P, InventarioNuevo),
%   fusionar_equipo(Resto, EquipoDado),
%   append(InventarioNuevo, EquipoDado, EquipoFusionado).

% base de conjugacion
tiempo(presente).
tiempo(pasado).
tiempo(futuro).
persona(primera).
persona(segunda).
persona(tercera).
numero(singular).
numero(plural).

ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fue").
ser(futuro, tercera, singular, "sera").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").

% regla de inferencia con condicionales.
conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion):-
    tiempo(Tiempo), persona(Persona), numero(Numero),
    (Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R),
    Conjugacion = R ;
Conjugacion = Verbo).

% Generar reporte narrativo de misión
generar_reporte(Personajes, ID_Mision, Mensaje):-
    verificar_personajes(Personajes, ID_Mision),
    mision(ID_Mision, Nombre, _, XP),

    atomic_list_concat(Personajes, ", ", ListaPersonajes),

    atomic_list_concat(
        [ListaPersonajes,
         " son capaces de completar ",
         Nombre,
         " por ",
         XP,
         " xp."],
        Mensaje
    ).

verificar_personajes([], _).

verificar_personajes([P|Resto], ID_Mision):-
    puede_aceptar(P, ID_Mision),
    verificar_personajes(Resto, ID_Mision).

% a probar.
% ?- generar_reporte('Elara', m1, Mensaje).

% Hacer que la funcion del reporte pueda mostrar varios personajes!!