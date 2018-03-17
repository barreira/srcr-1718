%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MIEI/3 - EXERCICIO 1

% GRUPO 23
% Ana Paula Carvalho  - A61855
% João Pires Barreira - A73831
% Rafael Braga Costa  - A61799


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
:- dynamic instituicao/3.
:- dynamic consulta/4.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Invariantes

% Nao permitir a insercao de um utente que ja exista (mesmo id)
% Id deve ser inteiro
% Idade deve ser inteira e estar entre os valores [0, 125]

+utente(Id, _, Idade, _) :: (
	integer(Id),
	integer(Idade),
	Idade >= 0,
	Idade =< 125,
    solucoes(Id, utente(Id, _, _, _), S),
    comprimento(S, N),
    N == 1
).


% Nao permitir a remocao de utente enquando existirem cuidados prestados e consultas
% associadas ao mesmo

-utente(IdUt, _, _, _) :: (
	solucoes(IdUt, cuidado(_, IdUt, _, _, _), S1),
	solucoes(IdUt, consulta(IdUt, _, _, _), S2),
	comprimento(S1, N1),
	comprimento(S2, N2),
	N1 == 0, N2 == 0
).


% Nao permitir a insercao de um utente que ja exista (mesmo id) ou cuja instituicao 
% a que pertence nao exista
% Id deve ser inteiro

+prestador(Id, _, _, IdIns) :: (
	integer(Id),
    solucoes(Id, prestador(Id, _, _, _), S1),
	solucoes(IdIns, instituicao(IdIns, _, _), S2),
    comprimento(S1, N1),
	comprimento(S2, N2),
    N1 == 1,
	N2 == 1
).


% Nao permitir a remocao de prestador enquando existirem cuidados prestados 
% e consultas associadas ao mesmo

-prestador(IdPrest, _, _, _) :: (
	solucoes(IdUt, cuidado(_, _, IdPrest, _, _), S1),
	solucoes(IdPrest, consulta(_, IdPrest, _, _), S2),
	comprimento(S1, N1),
	comprimento(S2, N2),
	N1 == 0, N2 == 0
).


% Nao permitir a insercao de um cuidado ja existente ou que esteja associado a um
% utente e a um prestador que nao existam
% O valor do primeiro argumento deve ser uma data
% O custo deve ser do tipo number e ser maior ou igual a zero

+cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
	number(Custo), Custo >= 0, data(Data),
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


% Remocao de um cuidado

-cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S),
    comprimento(S, N),
    N == 0
).


% Nao permitir a insercao de um instituicao que ja exista
% Id deve ser inteiro

+instituicao(Id, _, _) :: (
	integer(Id),
	solucoes(Id, instituicao(Id, _, _), S),
	comprimento(S, N),
	N == 1
).


% Remocao de uma instituicao

-instituicao(Id, _, _) :: (
	solucoes(Id, prestador(_, _, _, Id), S),
	comprimento(S, N),
	N == 0
).


% Nao permitir a insercao de uma consulta que ja exista ou que esteja associada a
% um utente ou a um prestador que nao existam
% O terceiro e o quarto argumentos devem ser horas
% Nao permitir a insercao de uma consulta que colida com o horario de consultas já
% marcadas com um prestador

+consulta(IdU, IdP, HI, HF) :: (
	data_hora(HI), data_hora(HF),
	solucoes(IdU, utente(IdU, _, _, _), S1),
	solucoes(IdP, prestador(IdP, _, _, _), S2),
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), S3),
	solucoes((IdU1, IdP, HI1, HF1), consulta(IdU1, IdP, HI1, HF1), S4),
	comprimento(S1, N1),
	comprimento(S2, N2),
	comprimento(S3, N3),
	N1 == 1, N2 == 1, N3 == 1,
	remove_consulta(S4, (IdU, IdP, HI, HF), L),
	nao_colide(HI, HF, L)
).
	

% Remocao de uma consulta
	
-consulta(IdU, IdP, HI, HF) :: (
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), S),
    comprimento(S, N),
    N == 0
).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado procura_utentes: Id, Nome, Idade, Morada, Lista -> {V, F}
% Procura utentes por criterios de selecao (Id, Nome, Idade ou Morada)

procura_utentes(Id, N, Idade, M, L) :-
	solucoes((Id, N, Idade, M), utente(Id, N, Idade, M), L).
procura_utentes(IdPres, Esp, Ins, L) :-
    solucoes((IdU, Nome, Idade, Morada), 
             (prestador(IdPres, _, Esp, Ins),
              cuidado(_, IdU, IdPres, _, _), 
              utente(IdU, Nome, Idade, Morada)),
             S),
	sem_repetidos(S, L).

	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado intituicoes: Lista -> {V, F}

instituicoes(L) :-
    solucoes((Id, Nome, Cidade), instituicao(Id, Nome, Cidade), L).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado procura_cuidados_por_dic: Data, Ints, Cidade, Lista -> {V, F}
% Procura cuidados por data, instituicao ou cidade onde foram realizados

procura_cuidados_por_dic(Data, Inst, Cidade, L) :-
    solucoes((Data, IdU, IdPres, Desc, Custo), 
             (prestador(IdPres, _, _, IdInst),
			  instituicao(IdInst, Inst, Cidade),
              cuidado(Data, IdU, IdPres, Desc, Custo)), 
             L).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado procura_cuidados_por_upi: Utente, Pres, Ints, Lista -> {V, F}
% Procura cuidados efetuados a um utente, efetuados por um prestador ou 
% instituicao onde foram realizados	

procura_cuidados_por_upi(IdU, IdPres, Inst, L) :-
    solucoes((Data, IdU, IdPres, Desc, Custo), 
             (prestador(IdPres, _, _, IdInst),
			  instituicao(IdInst, Inst, _),
              cuidado(Data, IdU, IdPres, Desc, Custo)), 
             L).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado prestadores_de_utente: Utente, Lista -> {V, F}	 
% Procura por todos os prestadores que tenham realizado cuidados a um utente

prestadores_de_utente(IdU, L) :-
    solucoes((IdPres, Nome, Esp, Inst), 
             (prestador(IdPres, Nome, Esp, Inst),
              cuidado(_, IdU, IdPres, _, _)), 
             S),
	sem_repetidos(S, L).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado instituicoes_de_utente: Utente, Lista -> {V, F}	
% Procura por todas as instituicoes onde um utente recorreu a cuidados medicos
 		
instituicoes_de_utente(IdU, L) :-
    solucoes((Inst, Nome, Cidade),
             (prestador(IdPres, _, _, Inst),
              cuidado(_, IdU, IdPres, _, _),
			  instituicao(Inst, Nome, Cidade)), 
             R),
    sem_repetidos(R, L).



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado custo_total: Utente, Prest, Esp, Data, Custo -> {V, F}	
% Devolve o custo total pago pelos seguintes criterios (utente, prestador, 
% especialidade ou data)

custo_total(IdU, IdP, Esp, Data, C) :-
    solucoes(Custo,
             (prestador(IdP, _, Esp, _),
              cuidado(Data, IdU, IdP, _, Custo)), 
             R),
    sum(R, C).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado procura_consultas: IdU, IdP, HI, HF, Lista -> {V, F}
% Procura consultas por criterios de selecao
	
procura_consultas(IdU, IdP, HI, HF, L) :-
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado nao: Termo -> {V, F}	

nao(T) :- T, !, fail.
nao(T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao: Termo -> {V, F}	

evolucao(Termo) :- solucoes(Inv, +Termo::Inv, S),
                   insere(Termo),
                   teste(S).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado involucao: Termo -> {V, F}		
			   
involucao(Termo) :- Termo,
					solucoes(Inv, -Termo::Inv, S),
                    remove(Termo),
                    teste(S).

				
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado insere: Termo -> {V, F}		
			
insere(Termo) :- assert(Termo).
insere(Termo) :- retract(Termo), !, fail.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado remove: Termo -> {V, F}	

remove(Termo) :- retract(Termo).
remove(Termo) :- assert(Termo), !, fail.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado teste: Lista -> {V, F}	

teste([]).
teste([H | T]) :- H, teste(T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado solucoes: F, Q, S -> {V, F}	

solucoes(F, Q, S) :- findall(F, Q, S).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado comprimento: S, N -> {V, F}	

comprimento(S, N) :- length(S, N).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado pertence: X, Lista -> {V, F}	

pertence(X, [X | T]).
pertence(X, [H | T]) :- X \= H, pertence(X, T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado sem_repetidos: Lista, Res -> {V, F}	
% Retira elementos repetidos de uma lista

sem_repetidos([],[]).
sem_repetidos([H|T], R) :-
	pertence(H,T),
	sem_repetidos(T,R).
sem_repetidos([H|T], [H|R]) :-
	nao(pertence(H,T)),
	sem_repetidos(T,R).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado sum: Lista, R -> {V, F}		
% Somatorio de uma lista

sum([], 0).
sum([H|T], R) :- sum(T, L), R is H + L.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado data: D, M, A -> {V, F}	

data(D, M, A) :-
	A >= 0,
    pertence(M, [1,3,5,7,8,10,12]),
	D >= 1,
	D =< 31.
data(D, M, A) :-
	A >= 0,
    pertence(M, [4,6,9,11]),
	D >= 1,
	D =< 30.
data(D, 2, A) :-
	A >= 0,
    A mod 4 =\= 0, 
	D >= 1,
	D =< 28.
data(D, 2, A) :-
    A >= 0,
	A mod 4 =:= 0,
	D >= 1,
	D =< 29.
data(data(D, M, A)) :- data(D, M, A).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado data_hora: D, M, A, H, Min -> {V, F}	

data_hora(D, M, A, H, Min) :-
	data(D, M, A),
	H >= 0,
	H =< 23,
	Min >= 0,
	Min =< 59.
data_hora(data_hora(D, M, A, H, Min)) :- data_hora(D, M, A, H, Min).
		

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado depois: D1, D2 -> {V, F}
% Testa se a primeira hora e posterior a segunda
	
depois(data_hora(_, _, A1, _, _), data_hora(_, _, A2, _, _)) :- 
	A1 > A2.
depois(data_hora(_, M1, A1, _, _), data_hora(_, M2, A2, _, _)) :- 
	A1 >= A2,
	M1 > M2.
depois(data_hora(D1, M1, A1, _, _), data_hora(D2, M2, A2, _, _)) :- 
	A1 >= A2,
	M1 >= M2,
	D1 > D2.
depois(data_hora(D1, M1, A1, H1, _), data_hora(D2, M2, A2, H2, _)) :- 
	A1 >= A2,
	M1 >= M2,
	D1 >= D2,
	H1 > H2.
depois(data_hora(D1, M1, A1, H1, Min1), data_hora(D2, M2, A2, H2, Min2)) :- 
	A1 >= A2,
	M1 >= M2,
	D1 >= D2,
	H1 >= H2,
	Min1 > Min2.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado nao_colide: D1, D2, Lista -> {V, F}	
% Determina se duas horas colidem com algum horario presente na lista

nao_colide(D1, D2, []) :- depois(D2, D1).
nao_colide(D1, D2, [(D3, D4)|T]) :-
	depois(D2, D1),
	depois(D4, D3),
	depois(D1, D4),
	nao_colide(D1, D2, T).
nao_colide(D1, D2, [(D3, D4)|T]) :-
	depois(D2, D1),
	depois(D4, D3),
	depois(D3, D2),
	nao_colide(D1, D2, T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado remove_consulta: Lista, Consulta, Resultado -> {V, F}	
% Retira de uma lista de consultas aquela que faca match com o segundo argumento
% O resultado apenas guarda as datas de inicio e de fim das consultas
	
remove_consulta([], _, []).
remove_consulta([(U, P, I, F)|T], (U, P, I, F), L) :-
	remove_consulta(T, (U, P, I, F), L).
remove_consulta([(U1, P1, I1, F1)|T], (U2, P2, I2, F2), [(I1, F1)|L]) :- 
	remove_consulta(T, (U2, P2, I2, F2), L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado utente: Id, Nome, Idade, Morada -> {V, F}	

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


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado prestador: Id, Nome, Especialidade, Instituicao -> {V, F}	

prestador( 0, 'Manuel',   'Cardiologia',  1).
prestador( 1, 'Carlos',   'Neurologia',   2).
prestador( 2, 'Aventino', 'Urologia',     3).
prestador( 3, 'Paulo',    'Ortopedia',    4).
prestador( 4, 'Bicas',    'Psiquiatria',  2).
prestador( 5, 'Ines',     'Pediatria',    3).
prestador( 6, 'Manuela',  'Ginecologia',  4).
prestador( 7, 'Sara',     'Oftalmologia', 4).
prestador( 8, 'Sandra',   'Radiografia',  3).
prestador( 9, 'Ruben',    'Fisioterapia', 2).
prestador(10, 'Luisa',    'Dermatologia', 1).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado cuidado: Data, Utente, Prestador, Desc, Custo -> {V, F}	

cuidado(data(13, 12, 2017), 0, 2, 'Consulta Urologia', 19.99).
cuidado(data(13, 11, 2017), 0, 1, 'Consulta Neurologia', 39.99).
cuidado(data(10, 11, 2017), 1, 6, 'Consulta Ginecologia', 19.99).
cuidado(data(10, 11, 2017), 1, 6, 'Consulta Ginecologia', 59.99).
cuidado(data(11, 12, 2017), 1, 0, 'Consulta Cardiologia', 59.99).
cuidado(data(11, 12, 2017), 2, 0, 'Consulta Cardiologia', 59.99).
cuidado(data(12, 12, 2017), 2, 7, 'Consulta Oftalmologia', 59.99).
cuidado(data(12, 11, 2017), 2, 8, 'Radiografia ao Torax', 49.99).
cuidado(data(12, 12, 2017), 2, 9, 'Sessao de Fisioterapia', 69.99).
cuidado(data(12, 12, 2017), 3, 1, 'Consulta Neurologia', 19.99).
cuidado(data(13, 11, 2017), 3, 0, 'Consulta Cardiologia', 9.99).
cuidado(data(14, 12, 2017), 4, 5, 'Consulta de Exames', 0).
cuidado(data(15, 12, 2017), 4, 4, 'Consulta Psiquiatria', 15.99).
cuidado(data(15, 11, 2017), 4, 4, 'Consulta Psiquiatria', 14.99).
cuidado(data(15, 12, 2017), 4, 2, 'Consulta Urologia', 19.99).
cuidado(data(15, 12, 2017), 4, 2, 'Consulta Urologia', 49.99).
cuidado(data(15, 11, 2017), 4, 3, 'Consulta Ortopedia', 74.99).
cuidado(data(13, 11, 2017), 5, 5, 'Consulta Pediatria', 79.99).
cuidado(data(7, 11, 2017), 5, 0, 'Consulta Cardiologia', 19.99).
cuidado(data(7, 11, 2017), 6, 0, 'Consulta Cardiologia', 19.99).
cuidado(data(7, 12, 2017), 7, 1, 'Consulta Neurologia', 89.99).
cuidado(data(7, 12, 2017), 8, 10, 'Consulta Dermatologia', 89.99).
cuidado(data(20, 11, 2017), 8, 10, 'Consulta Dermatologia', 99.99).
cuidado(data(20, 11, 2017), 8, 10, 'Consulta Dermatologia', 109.99).
cuidado(data(30, 12, 2017), 8, 10, 'Consulta Dermatologia', 19.99).
cuidado(data(20, 12, 2017), 9, 3, 'Consulta Ortopedia', 97.99).
cuidado(data(4, 11, 2017), 9, 3, 'Consulta Ortopedia', 39.99).
cuidado(data(3, 12, 2017), 10, 0, 'Consulta de Exames', 9.99).
cuidado(data(23, 11, 2017), 10, 1, 'Consulta de Exames', 5.99).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado instituicao: Id, Nome, Cidade -> {V, F}	

instituicao(1, 'Hospital de Braga', 'Braga').
instituicao(2, 'Hospital de Guimaraes', 'Guimaraes').
instituicao(3, 'Hospital do Porto', 'Porto').
instituicao(4, 'Hospital de Lisboa', 'Lisboa').


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado consulta: Utente, Prestador, HInicio, HFim -> {V, F}	

consulta(0, 0, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 0, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 0, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 0, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 0, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 1, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 1, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 1, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 1, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 1, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 2, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 2, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 2, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 2, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 2, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 3, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 3, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 3, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 3, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 3, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 4, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 4, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 4, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 4, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 4, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 5, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 5, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 5, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 5, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 5, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).

consulta(0, 6, data_hora(25, 1, 2018, 14, 20), data_hora(25, 1, 2018, 14, 50)).
consulta(1, 6, data_hora(25, 1, 2018, 15, 0), data_hora(25, 1, 2018, 15, 30)).
consulta(2, 6, data_hora(25, 1, 2018, 15, 40), data_hora(25, 1, 2018, 16, 10)).
consulta(3, 6, data_hora(25, 1, 2018, 16, 20), data_hora(25, 1, 2018, 16, 50)).
consulta(4, 6, data_hora(25, 1, 2018, 17, 20), data_hora(25, 1, 2018, 18, 0)).