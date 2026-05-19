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

fusionar_equipo(P1, P2, EquipoFusionado):-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

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
generar_reporte(Personaje, ID_Mision, Mensaje):-
    puede_aceptar(Personaje, ID_Mision),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat([Personaje, FormaVerbal, " capaz de completar ", Nombre, " por ", XP, " xp."], Mensaje).

% a probar.
% ?- generar_reporte('Elara', m1, Mensaje).

% Hacer que la funcion del reporte pueda mostrar varios personajes!!