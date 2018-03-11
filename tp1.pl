%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MIEI - GRUPO 23 - EXERCICIO 1


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag(discontiguous_warnings, off).
:- set_prolog_flag(single_var_warnings, off).
:- set_prolog_flag(unknown, fail).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op(900, xfy, '::').
:- dynamic utente/4.
:- dynamic prestador/4.
:- dynamic cuidado/5.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Invariantes

+utente(Id, _, Idade, _) :: (
	integer(Id),
	integer(Idade),
	Idade >= 0,
	Idade =< 125,
    solucoes(Id, utente(Id, _, _, _), S),
    comprimento(S, N),
    N == 1
).


-utente(IdUt, _, _, _) :: (
	solucoes(IdUt, cuidado(_, IdUt, _, _, _), S),
	comprimento(S, N),
	N == 0
).


+prestador(Id, _, _, _) :: (
	integer(Id),
    solucoes(Id, prestador(Id, _, _, _), S),
    comprimento(S, N),
    N == 1    
).


-prestador(IdPrest, _, _, _) :: (
	solucoes(IdUt, cuidado(_, _, IdPrest, _, _), S),
	comprimento(S, N),
	N == 0
).


+cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
	number(Custo), Custo >= 0,
    solucoes(IdUt, utente(IdUt, _, _, _), S1),
    solucoes(IdPrest, prestador(IdPrest, _, _, _), S2),
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S3),
    comprimento(S1, N1),
    comprimento(S2, N2),
    comprimento(S3, N3),
    N1 == 1, N2 == 1, N3 == 1
).


-cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S),
    comprimento(S, N),
    N == 0
).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicados de consulta

procura_utentes(Id, N, Idade, M, L) :-
	solucoes((Id, N, Idade, M), utente(Id, N, Idade, M), L).

	
instituicoes(L) :-
	solucoes((Id, N, A, Ins), prestador(Id, N, A, Ins), S),
	lista_instituicoes(S, [], L).
	
	
lista_instituicoes([], R, R).
lista_instituicoes([(_, _, _, I) | T], R, L) :-
	pertence(I, R),
	lista_instituicoes(T, R, L).
lista_instituicoes([(_, _, _, I) | T], R, L) :-
	nao(pertence(I, R)),
	lista_instituicoes(T, [I | R], L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicados auxiliares

nao(T) :- T, !, fail.
nao(T).


evolucao(Termo) :- solucoes(Inv, +Termo::Inv, S),
                   insere(Termo),
                   teste(S).

				   
involucao(Termo) :- solucoes(Inv, -Termo::Inv, S),
                    remove(Termo),
                    teste(S).

					
insere(Termo) :- assert(Termo).
insere(Termo) :- retract(Termo), !, fail.


remove(Termo) :- retract(Termo).
remove(Termo) :- assert(Termo), !, fail.


teste([]).
teste([H | T]) :- H, teste(T).


solucoes(F,Q,S) :- findall(F,Q,S).


comprimento(S,N) :- length(S,N).


pertence(X, [X | T]).
pertence(X, [H | T]) :- X \= H, pertence(X, T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Factos

utente( 0, 'Jose',      45, 'Rua do Queijo').
utente( 1, 'Maria',     41, 'Rua de Cima').
utente( 2, 'Gertrudes', 26, 'Rua Carlos Antonio').
utente( 3, 'Paula',     73, 'Rua da Mina').
utente( 4, 'Sebastiao', 83, 'Rua da Poeira').
utente( 5, 'Zeca',      9,  'Rua do Poeira').
utente( 6, 'Jorge',     44, 'Rua da Poeira').
utente( 7, 'Rafaela',   23, 'Rua da Poeira').
utente( 8, 'Anabela',   42, 'Rua de Baixo').
utente( 9, 'Antonio',   57, 'Rua do Forno').
utente(10, 'Zueiro',    33, 'Rua do Mar').

prestador( 0, 'Manuel',   'Cardiologia',  'Hospital de Braga').
prestador( 1, 'Carlos',   'Neurologia',   'Hospital de Guimaraes').
prestador( 2, 'Aventino', 'Urologia',     'Hospital de Guimaraes').
prestador( 3, 'Paulo',    'Ortopedia',    'Hospital de Braga').
prestador( 4, 'Bicas',    'Psiquiatria',  'Hospital de Guimaraes').
prestador( 5, 'Ines',     'Pediatria',    'Hospital de Guimaraes').
prestador( 6, 'Manuela',  'Ginecologia',  'Hospital de Braga').
prestador( 7, 'Sara',     'Oftalmologia', 'Hospital de Guimaraes').
prestador( 8, 'Sandra',   'Radiografia',  'Hospital de Braga').
prestador( 9, 'Ruben',    'Fisioterapia', 'Hospital de Guimaraes').
prestador(10, 'Luisa',    'Dermatologia', 'Hospital de Braga').

cuidado('13-12-2017', 0, 2, 'Consulta Urologia', 19.99).
cuidado('13-11-2017', 0, 1, 'Consulta Neurologia', 39.99).
cuidado('10-11-2017', 1, 6, 'Consulta Ginecologia', 19.99).
cuidado('10-11-2017', 1, 6, 'Consulta Ginecologia', 59.99).
cuidado('11-12-2017', 1, 0, 'Consulta Cardiologia', 59.99).
cuidado('11-12-2017', 2, 0, 'Consulta Cardiologia', 59.99).
cuidado('12-12-2017', 2, 7, 'Consulta Oftalmologia', 59.99).
cuidado('12-11-2017', 2, 8, 'Radiografia ao Torax', 49.99).
cuidado('12-12-2017', 2, 9, 'Sessao de Fisioterapia', 69.99).
cuidado('12-12-2017', 3, 1, 'Consulta Neurologia', 19.99).
cuidado('13-11-2017', 3, 0, 'Consulta Cardiologia', 9.99).
cuidado('14-12-2017', 4, 5, 'Consulta de Exames', 0).
cuidado('15-12-2017', 4, 4, 'Consulta Psiquiatria', 15.99).
cuidado('15-11-2017', 4, 4, 'Consulta Psiquiatria', 14.99).
cuidado('15-12-2017', 4, 2, 'Consulta Urologia', 19.99).
cuidado('15-12-2017', 4, 2, 'Consulta Urologia', 49.99).
cuidado('15-11-2017', 4, 3, 'Consulta Ortopedia', 74.99).
cuidado('13-11-2017', 5, 5, 'Consulta Pediatria', 79.99).
cuidado('7-11-2017', 5, 0, 'Consulta Cardiologia', 19.99).
cuidado('7-11-2017', 6, 0, 'Consulta Cardiologia', 19.99).
cuidado('7-12-2017', 7, 1, 'Consulta Neurologia', 89.99).
cuidado('7-12-2017', 8, 10, 'Consulta Dermatologia', 89.99).
cuidado('20-11-2017', 8, 10, 'Consulta Dermatologia', 99.99).
cuidado('20-11-2017', 8, 10, 'Consulta Dermatologia', 109.99).
cuidado('30-12-2017', 8, 10, 'Consulta Dermatologia', 19.99).
cuidado('20-12-2017', 9, 3, 'Consulta Ortopedia', 97.99).
cuidado('4-11-2017', 9, 3, 'Consulta Ortopedia', 39.99).
cuidado('3-12-2017', 10, 0, 'Consulta de Exames', 9.99).
cuidado('23-11-2017', 10, 1, 'Consulta de Exames', 5.99).
