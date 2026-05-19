% - -- HECHOS (Base de Conocimiento) ---
personaje( 'Elara', 5, 100). 
personaje('Kael', 3, 80). 
personaje('Rin', 7, 120).
% -- AGREGAR 3 NUEVOS JUGADORES
personaje('Rocky', 8, 110).
personaje('Murdoc', 4, 90).
personaje('Loona', 3, 90).

mision(m1, 'Bosque de Sombras', 2, 50). 
mision(m2, 'Cueva del Dragón', 5, 120). 
mision(m3, 'Torre Arcana', 7, 200).
inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).
inventario('Rocky', [hacha, grimorio, pocion, amuleto]).
inventario('Murdoc', [ballesta, grimorio, pocion, amuleto]).
inventario('Loona', [escudo, grimorio, pocion, amuleto]).
requiere(m2, escudo).
requiere(m2, pocion) .
requiere(m3, grimorio).
requiere(m3, pocion).

% -- FUERZA DE ATAQUE DE ARMAS
fuerza_arma(espada, 10).
fuerza_arma(arco, 13).
fuerza_arma(varita, 8).
fuerza_arma(hacha, 16).
fuerza_arma(ballesta, 12).
fuerza_arma(escudo, 6).
fuerza_arma(pistola, 100).

% --ENEMIGOS
% enemigo(nombre, vida)
enemigo('goblin', 30).
enemigo('ogro', 70).
enemigo('dragon', 100).

% Agregar fuerza de ataque a personajes (para ser + especificos sus armas!)

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
% 2 NUEVAS REGLAS
% ================================

pueden_derrotar(Personaje, Enemigo):-
    ejecutar_ataque(Personaje, Enemigo, victoria).

equipo_derrota([], _).
equipo_derrota([P|Resto], Enemigo):-
    pueden_derrotar(P, Enemigo),
    equipo_derrota(Resto, Enemigo).
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

% ===================
% Funciones de ataque
% ===================
% Revisar si el jugador tiene un arma:
arma_jugador([Item|_], Item):-
    fuerza_arma(Item,_).
arma_jugador([_|Resto], Arma):-
    arma_jugador(Resto, Arma).

% Ejecutar ataque (1 jugador)
ejecutar_ataque(Personaje, Enemigo, Resultado):-
    personaje(Personaje, Nivel, _),
    inventario(Personaje, Inventario),
    enemigo(Enemigo, VidaE),
    arma_jugador(Inventario, Arma),
    fuerza_arma(Arma, Fuerza),
    Ataque is Nivel * Fuerza,
    (Ataque >= VidaE ->
        Resultado = victoria
    ;
        Resultado = derrota
    ).

% Ejecutar ataque (>1 jugadores)
ejecutar_ataque_equipos([], _, []).
ejecutar_ataque_equipos([P|Resto], Enemigo, [P-Resultado|Resultados]):-
    ejecutar_ataque(P, Enemigo, Resultado),
    ejecutar_ataque_equipos(Resto, Enemigo, Resultados).


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

% Generar reporte narrativo de combate (1 jugador)
generar_reporte_combate(Personaje, Enemigo, Mensaje):-
    ejecutar_ataque(Personaje, Enemigo, Resultado),
    (Resultado = victoria ->
        atomic_list_concat([Personaje, ' derroto al ', Enemigo, ' con exito!! Felicidades!'], Mensaje)
    ;
        atomic_list_concat([Personaje, ' no pudo derrotar al ', Enemigo, '.'], Mensaje)
        
        ).

% Generar reporte de combate (equipos).
generar_reporte_combate_equipos([],_,[]).
generar_reporte_combate_equipos([P|Resto], Enemigo, [Mensaje|MensajesResto]):-
    generar_reporte_combate(P, Enemigo, Mensaje),
    generar_reporte_combate_equipos(Resto, Enemigo, MensajesResto).

verificar_personajes([], _).

verificar_personajes([P|Resto], ID_Mision):-
    puede_aceptar(P, ID_Mision),
    verificar_personajes(Resto, ID_Mision).

% a probar.
% ?- generar_reporte('Elara', m1, Mensaje).

% Hacer que la funcion del reporte pueda mostrar varios personajes!!