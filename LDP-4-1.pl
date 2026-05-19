personaje('Elena', 5, 100).
personaje('Kael', 1, 80).
personaje('Rin', 7, 120).
personaje('Legolas', 9, 300).
personaje('Gimli', 7, 80).
personaje('Aragorn', 8, 120).

enemigo('Troll', 20).
enemigo('Bustamante', 2).
enemigo('Minotauro', 500).

mision(m1,'Bosque de Sombras', 2, 50).
mision(m2,'Cueva del Dragon', 5, 120).
mision(m3,'Torre Arcana', 7, 200).

arma(espada_comun, 3).
arma(arco_comun, 20).
arma(varita, 40).
arma(espada_bacan, 60).
arma(arco_bacan, 50).

inventario('Elena', [espada_comun, escudo, pocion]).
inventario('Kael', [arco_comun, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).
inventario('Aragorn', [espada_bacan, escudo]).
inventario('Legolas', [arco_bacan, flechas]).
inventario('Gimli', [espada_comun, cabello_de_galadriel]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, escudo).

%verificacion

puede_matar(Personaje, Enemigo) :-
    is_list(Personaje),
    enemigo(Enemigo, Vida),
    findall(
        Ataque,
        (
            member(P, Personaje),
            inventario(P, Items),
            member(A, Items),
            arma(A, Ataque)
        ),
        Ataques
    ),
    sumlist(Ataques, Total),
    Total >= Vida.

puede_aceptar(Personaje, ID_Mision) :-
    is_list(Personaje),
    forall(
        member(P, Personaje),
        puede_aceptar(P, ID_Mision)).

puede_aceptar(Personaje, ID_Mision) :-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

%2 Calculo

xp_acumulada(0, 0).

xp_acumulada(N, Total) :-
    N > 0,
    N1 is N - 1,
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).

%3 Verficacion 2

tiene_requerido(Personaje, Objeto) :-
    inventario(Personaje, Lista),
    member(Objeto, Lista).

%Regla 1 Detectar

mismo_nivel(P1, P2) :-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

%Regla 2 Vaalidar

es_balanceado(Personaje) :-
    personaje(Personaje, _, Vida),
    Vida =:= 100.

%

% PROCESAMIENTO DE LISTAS Y NLP ---
%1. Fusionar inventarios de dos personajes usando append/3 (2.3)

fusionar_equipo(P1, P2, EquipoFusionado) :-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

% 2. Base de conjugación (Adaptación directa de conjugar_verbo/5 en 2.3)

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
ser(futuro, tercera, singular, "será"). 
ser(presente, primera, singular, "soy"). 
ser(presente, primera, plural, "somos").
ser(presente, tercera, plural, "son").

% 3. Regla de inferencia con estructura condicional (2.3)

conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion) :-
    tiempo(Tiempo),
    persona(Persona),
    numero(Numero),

    ( Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, R), 
        Conjugacion = R
    ; Conjugacion = Verbo ). % Si no es "ser", devuelve el infinitivo

% 4. Generación de reporte narrativo

generar_reporte(Personaje, MisionID, Mensaje) :-
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, _, XP),
    (is_list(Personaje) ->
        conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
        atomic_list_concat(Personaje, ', ', Sujetos),
        Estado = 'capaces';
        conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
        Sujetos = Personaje,
        Estado = 'capaz'),

    atomic_list_concat(
        [Sujetos, ' ', FormaVerbal, ' ', Estado,
         ' de completar ', Nombre, ' por ', XP, ' XP'],
        '',
        Mensaje).

generar_reporte_muerte(Personaje, Enemigo, Mensaje) :-
    ((is_list(Personaje),
  length(Personaje, N),
  N > 1) ->
        (puede_matar(Personaje, Enemigo) ->
            atomic_list_concat(['El grupo se esta bañando con las entrañas de ', Enemigo, ' gracias a el poder de la amistad'],'',Mensaje);
            atomic_list_concat(['El grupo no pudo derrotar a ', Enemigo, ' ni con el poder de la amistad'],'',Mensaje));

        (   is_list(Personaje)
->  Personaje = [P]
;   P = Personaje
),
enemigo(Enemigo, Vida),
inventario(P, Items),

(   member(Arma, Items),
    arma(Arma, Ataque),
    Ataque >= Vida
->  atomic_list_concat([P, ' ha asesinado a ', Enemigo, ' usando ', Arma],'',Mensaje)
;   atomic_list_concat([P, ' no pudo asesinar a ', Enemigo],'',Mensaje)
)).