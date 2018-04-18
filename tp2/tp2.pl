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
:- dynamic '-'/1.
:- dynamic utente/4.
:- dynamic prestador/4.
:- dynamic cuidado/5.
:- dynamic instituicao/3.
:- dynamic consulta/4.
:- dynamic excecao/1.
:- dynamic impreciso/1.
:- dynamic imprecisoIntervalo/1.
:- dynamic incerto/1.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% PREDICADOS AUXILIARES

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado demo: Questao, Flag -> {V, F, D}

demo(Questao, verdadeiro) :- Questao.
demo(Questao, falso) :- -Questao.
demo(Questao, desconhecido) :- nao(Questao), nao(-Questao).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado demo: Questao1, Tipo, Questao2, Flag -> {V, F, D}
% em que Tipo pode ser:
%	eq - equivalencia
% 	impl - implicacao
%   ou - disjuncao
%   e - conjuncao

demo(Q1, eq, Q2, F) :- demo(Q1, F1), 
	                   demo(Q2, F2), 
	                   equivalencia(F1, F2, F).
demo(Q1, impl, Q2, F) :- demo(Q1, F1), 
	                     demo(Q2, F2), 
	                     implicacao(F1, F2, F).
demo(Q1, ou, Q2, F) :- demo(Q1, F1), 
	                   demo(Q2, F2), 
	                   disjuncao(F1, F2, F).
demo(Q1, e, Q2, F) :- demo(Q1, F1), 
	                  demo(Q2, F2), 
	                  conjuncao(F1, F2, F).					   
				

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado equivalencia: Tipo, Tipo, Tipo -> {V, F, D}
% Tipo pode ser verdadeiro, falso ou desconhecido

equivalencia(X, X, verdadeiro).
equivalencia(desconhecido, Y, desconhecido).
equivalencia(X, desconhecido, desconhecido).
equivalencia(X, Y, falso) :- X \= Y.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado implicacao: Tipo, Tipo, Tipo -> {V, F, D}
% Tipo pode ser verdadeiro, falso ou desconhecido

implicacao(falso, X, verdadeiro).
implicacao(X, verdadeiro, verdadeiro).
implicacao(verdadeiro, desconhecido, desconhecido). 
implicacao(desconhecido, X, desconhecido) :- X \= verdadeiro.
implicacao(verdadeiro, falso, falso).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado disjuncao: Tipo, Tipo, Tipo -> {V, F, D}
% Tipo pode ser verdadeiro, falso ou desconhecido

disjuncao(verdadeiro, X, verdadeiro).
disjuncao(X, verdadeiro, verdadeiro).
disjuncao(desconhecido, Y, desconhecido) :- Y \= verdadeiro.
disjuncao(Y, desconhecido, desconhecido) :- Y \= verdadeiro.
disjuncao(falso, falso, falso).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado conjuncao: Tipo, Tipo, Tipo -> {V, F, D}
% Tipo pode ser verdadeiro, falso ou desconhecido

conjuncao(verdadeiro, verdadeiro, verdadeiro).
conjuncao(falso, _, falso).
conjuncao(_, falso, falso).
conjuncao(desconhecido, verdadeiro, desconhecido).
conjuncao(verdadeiro, desconhecido, desconhecido).
				
				
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado demoList: Lista de Questoes, Lista de Respostas -> {V, F, D}
% Determina o tipo de um conjunto de questoes
% O resultado é uma lista de tipos (verdadeiro, falso ou desconhecido)
				
demoList([], []).
demoList([X|L], [R|S]) :- demo(X, R),
                          demoList(L, S). 

						  
						  

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado nao: Termo -> {V, F}	

nao(T) :- T, !, fail.
nao(T).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao: -Termo -> {V, F}
% -Termo representa a negacao forte de um Termo	

evolucao(-Termo) :- nao(impreciso(Termo)),
					solucoes(Inv, +(-Termo)::Inv, S),
					teste(S),
                    assert(-Termo).
					

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao: -Termo -> {V, F}	
					
evolucao(-Termo) :- impreciso(Termo),
					removeImpreciso(Termo, L),
					comprimento(L, N),
					N > 1,
					solucoes(Inv, +(-Termo)::Inv, S),
					teste(S),
                    assert(-Termo).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao: -Termo -> {V, F}	

evolucao(-Termo) :- impreciso(Termo),
					removeImpreciso(Termo, [T|[]]),
					removeImperfeito(Termo),
                    assert(T).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado evolucao: Termo -> {V, F}	

evolucao(Termo) :- imperfeito(Termo),
				   testeImperfeito(Termo),
	               removeIncerto(Termo),
	               solucoes(Inv, +Termo::Inv, S),
	               teste(S),
	               assert(Termo),
				   removeImperfeito(Termo).


evolucao(Termo) :- nao(imperfeito(Termo)),
				   solucoes(Inv, +Termo::Inv, S),
                   teste(S),
				   assert(Termo).
					

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado involucao: Termo -> {V, F}		
			   
involucao(Termo) :- Termo,
					solucoes(Inv, -Termo::Inv, S),
					teste(S),
                    retract(Termo).
					
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado involucao: -Termo -> {V, F}
% -Termo representa a negacao forte de um termo		

involucao(-Termo) :- -Termo,
					solucoes(Inv, -(-Termo::Inv), S),
					teste(S),
                    retract(-Termo).
		
					
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado testeImperfeito: Termo -> {V, F}
% Verifica se um termo e imperfeito (valor desconhecido)		

testeImperfeito(Termo) :- demo(Termo, desconhecido).
					
					
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imperfeito: Utente -> {V, F}
% Verifica se o conhecimento relativo a um utente e imperfeito

imperfeito(utente(Id, _, _, _)) :- incerto(utente(Id)).
imperfeito(utente(Id, _, _, _)) :- impreciso(utente(Id)).
imperfeito(utente(Id, _, _, _)) :- imprecisoIntervalo(utente(Id)).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imperfeito: Prestador -> {V, F}
% Verifica se o conhecimento relativo a um prestador e imperfeito
	
imperfeito(prestador(Id, _, _, _)) :- incerto(prestador(Id)).
imperfeito(prestador(Id, _, _, _)) :- impreciso(prestador(Id)).
imperfeito(prestador(Id, _, _, _)) :- imprecisoIntervalo(prestador(Id)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imperfeito: Instituicao -> {V, F}
% Verifica se o conhecimento relativo a uma instituicao e imperfeito

imperfeito(instituicao(Id, _, _)) :- incerto(instituicao(Id)).
imperfeito(instituicao(Id, _, _)) :- impreciso(instituicao(Id)).
imperfeito(instituicao(Id, _, _)) :- imprecisoIntervalo(instituicao(Id)).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imperfeito: Cuidado -> {V, F}
% Verifica se o conhecimento relativo a um cuidado e imperfeito

imperfeito(cuidado(D, U, P, _, _)) :- incerto(cuidado(D, U, P)).
imperfeito(cuidado(D, U, P, _, _)) :- impreciso(cuidado(D, U, P)).
imperfeito(cuidado(D, U, P, _, _)) :- imprecisoIntervalo(cuidado(D, U, P)).
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imperfeito: Consulta -> {V, F}

% Verifica se o conhecimento relativo a uma consulta e imperfeito
imperfeito(consulta(U, P, HI, _)) :- incerto(consulta(U, P, HI)).
imperfeito(consulta(U, P, HI, _)) :- impreciso(consulta(U, P, HI)).
imperfeito(consulta(U, P, HI, _)) :- imprecisoIntervalo(consulta(U, P, HI)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado impreciso: Termo -> {V, F}
% Verifica se o conhecimento relativo a um termo e impreciso

impreciso(utente(Id, _, _, _)) :- impreciso(utente(Id)).
impreciso(prestador(Id, _, _, _)) :- impreciso(prestador(Id)).
impreciso(instituicao(Id, _, _)) :- impreciso(instituicao(Id)).
impreciso(cuidado(D, U, P, _, _)) :- impreciso(cuidado(D, U, P)).
impreciso(consulta(U, P, HI, _)) :- impreciso(consulta(U, P, HI)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImpreciso: Utente -> {V, F}
% Remove conhecimento impreciso relativamente a um utente

removeImpreciso(utente(Id, Nome, Idade, Morada), L) :-
	retract(excecao(utente(Id, Nome, Idade, Morada))),
	solucoes((utente(Id, N, I, M)), excecao(utente(Id, N, I, M)), L).
removeImpreciso(utente(Id, Nome, Idade, Morada), L) :-
	solucoes((utente(Id, N, I, M)), excecao(utente(Id, N, I, M)), L).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImpreciso: Prestador -> {V, F}
% Remove conhecimento impreciso relativamente a um prestador
removeImpreciso(prestador(Id, Nome, Esp, Ins), L) :-
	retract(excecao(prestador(Id, Nome, Esp, Ins))),
	solucoes((prestador(Id, N, E, I)), excecao(prestador(Id, N, E, I)), L).
removeImpreciso(prestador(Id, Nome, Esp, Ins), L) :-
	solucoes((prestador(Id, N, E, I)), excecao(prestador(Id, N, E, I)), L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImpreciso: Instituicao -> {V, F}
% Remove conhecimento impreciso relativamente a uma instituicao
removeImpreciso(instituicao(Id, Nome, Loc), L) :-
	retract(excecao(instituicao(Id, Nome, Loc))),
	solucoes((instituicao(Id, N, Lo)), excecao(instituicao(Id, N, Lo)), L).
removeImpreciso(instituicao(Id, Nome, Loc), L) :-
	solucoes((instituicao(Id, N, Lo)), excecao(instituicao(Id, N, Lo)), L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImpreciso: Cuidado -> {V, F}
% Remove conhecimento impreciso relativamente a um cuidado
removeImpreciso(cuidado(D, U, P, Desc, C), L) :-
	retract(excecao(cuidado(D, U, P, Desc, C))),
	solucoes((cuidado(D, U, P, Desc2, C2)), excecao(cuidado(D, U, P, Desc2, C2)), L).
removeImpreciso(cuidado(D, U, P, Desc, C), L) :-
	solucoes((cuidado(D, U, P, Desc2, C2)), excecao(cuidado(D, U, P, Desc2, C2)), L).
	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImpreciso: Consulta -> {V, F}
% Remove conhecimento impreciso relativamente a uma consulta
removeImpreciso(consulta(U, P, HI, HF), L) :-
	retract(excecao(consulta(U, P, HI, HF))),
	solucoes((consulta(U, P, HI, HF2)), excecao(consulta(U, P, HI, HF2)), L).
removeImpreciso(consulta(U, P, HI, HF), L) :-
	solucoes((consulta(U, P, HI, HF2)), excecao(consulta(U, P, HI, HF2)), L).

	

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeIncerto: Utente -> {V, F}
% Remove conhecimento incerto relativamente a um utente
removeIncerto(utente(Id, Nome, Idade, Morada)) :-
	incerto(utente(Id)),
	retract(utente(Id, inc01, Idade, Morada)).
removeIncerto(utente(Id, _, _, _)) :-
	impreciso(utente(Id)).
removeIncerto(utente(Id, _, _, _)) :-
	imprecisoIntervalo(utente(Id)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeIncerto: Prestador -> {V, F}
% Remove conhecimento incerto relativamente a um prestador
removeIncerto(prestador(Id, Nome, Esp, Ins)) :-
	incerto(prestador(Id)),
	retract(prestador(Id, Nome, Esp, inc01)).
removeIncerto(prestador(Id, _, _, _)) :-
	impreciso(prestador(Id)).
removeIncerto(prestador(Id, _, _, _)) :-
	imprecisoIntervalo(prestador(Id)).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeIncerto: Instituicao -> {V, F}
% Remove conhecimento incerto relativamente a uma instituicao
removeIncerto(instituicao(Id, Nome, Localidade)) :-
	incerto(instituicao(Id)),
	retract(instituicao(Id, inc01, Localidade)).
removeIncerto(instituicao(Id, _, _)) :-
	impreciso(instituicao(Id)).
removeIncerto(instituicao(Id, _, _)) :-
	imprecisoIntervalo(instituicao(Id)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeIncerto: Cuidado -> {V, F}
% Remove conhecimento incerto relativamente a um cuidado
removeIncerto(cuidado(Data, U, P, Desc, C)) :-
	incerto(cuidado(Data, U, P)).
removeIncerto(cuidado(Data, U, P, _, _)) :-
	impreciso(cuidado(Data, U, P)).
removeIncerto(cuidado(Data, U, P, _, _)) :-
	imprecisoIntervalo(cuidado(Data, U, P)).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeIncerto: Consulta -> {V, F}
% Remove conhecimento incerto relativamente a uma consulta
removeIncerto(consulta(U, P, HI, HF)) :-
	incerto(consulta(U, P, HI)),
	retract(consulta(U, P, HI, inc01)).
removeIncerto(consulta(U, P, HI, _)) :-
	impreciso(consulta(U, P, HI)).
removeIncerto(consulta(U, P, HI, _)) :-
	imprecisoIntervalo(consulta(U, P, HI)).
	
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImperfeito: Utente -> {V, F}
% Remove conhecimento imperfeito relativamente a um utente
removeImperfeito(utente(Id, _, _, _)) :-
	incerto(utente(Id)),
	retract(incerto(utente(Id))).
removeImperfeito(utente(Id, _, _, _)) :-
	imprecisoIntervalo(utente(Id)),
	retract(imprecisoIntervalo(utente(Id))).
removeImperfeito(utente(Id, Nome, Idade, Morada)) :-
	impreciso(utente(Id)),
	retract(excecao(utente(Id, Nome, Idade, Morada2))),
	removeImperfeito(utente(Id, Nome, Idade, Morada)).
removeImperfeito(utente(Id, _, _, _)) :-
	impreciso(utente(Id)),
	retract(impreciso(utente(Id))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImperfeito: Prestador -> {V, F}
% Remove conhecimento imperfeito relativamente a um prestador
removeImperfeito(prestador(Id, _, _, _)) :-
	incerto(prestador(Id)),
	retract(incerto(prestador(Id))).
removeImperfeito(prestador(Id, _, _, _)) :-
	imprecisoIntervalo(prestador(Id)),
	retract(imprecisoIntervalo(prestador(Id))).
removeImperfeito(prestador(Id, Nome, Esp, Ins)) :-
	impreciso(prestador(Id)),
	retract(excecao(prestador(Id, Nome, Esp2, Ins))),
	removeImperfeito(prestador(Id, Nome, Esp, Ins)).
removeImperfeito(prestador(Id, _, _, _)) :-
	impreciso(prestador(Id)),
	retract(impreciso(prestador(Id))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImperfeito: Instituicao -> {V, F}
% Remove conhecimento imperfeito relativamente a uma instituicao
removeImperfeito(instituicao(Id, _, _)) :-
	incerto(instituicao(Id)),
	retract(incerto(instituicao(Id))).
removeImperfeito(instituicao(Id, _, _)) :-
	imprecisoIntervalo(instituicao(Id)),
	retract(imprecisoIntervalo(instituicao(Id))).
removeImperfeito(instituicao(Id, Nome, Localidade)) :-
	impreciso(instituicao(Id)),
	retract(excecao(instituicao(Id, Nome, Loc))),
	removeImperfeito(instituicao(Id, Nome, Localidade)).
removeImperfeito(instituicao(Id, _, _)) :-
	impreciso(instituicao(Id)),
	retract(impreciso(instituicao(Id))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImperfeito: Cuidado -> {V, F}
% Remove conhecimento imperfeito relativamente a um cuidado
removeImperfeito(cuidado(D, U, P, _, _)) :-
	incerto(cuidado(D, U, P)),
	retract(incerto(cuidado(D, U, P))).
removeImperfeito(cuidado(D, U, P, _, _)) :-
	imprecisoIntervalo(cuidado(D, U, P)),
	retract(imprecisoIntervalo(cuidado(D, U, P))).
removeImperfeito(cuidado(D, U, P, Desc, Custo)) :-
	impreciso(cuidado(D, U, P)),
	retract(excecao(cuidado(D, U, P, Desc, C2))),
	removeImperfeito(cuidado(D, U, P)).
removeImperfeito(cuidado(D, U, P, _, _)) :-
	impreciso(cuidado(D, U, P)),
	retract(impreciso(cuidado(D, U, P))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado removeImperfeito: Consulta -> {V, F}
% Remove conhecimento imperfeito relativamente a uma consulta
removeImperfeito(consulta(U, P, HI, _)) :-
	incerto(consulta(U, P, HI)),
	retract(incerto(consulta(U, P, HI))).
removeImperfeito(consulta(U, P, HI, _)) :-
	imprecisoIntervalo(consulta(U, P, HI)),
	retract(imprecisoIntervalo(consulta(U, P, HI))).
removeImperfeito(consulta(U, P, HI, HF)) :-
	impreciso(consulta(U, P, HI)),
	retract(excecao(consulta(U, P, HI, HF2))),
	removeImperfeito(consulta(U, P, HI)).
removeImperfeito(consulta(U, P, HI, _)) :-
	impreciso(consulta(U, P, HI)),
	retract(impreciso(consulta(U, P, HI))).
	

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
    pertence(M, [1, 3, 5, 7, 8, 10, 12]),
	D >= 1,
	D =< 31.
data(D, M, A) :-
	A >= 0,
    pertence(M, [4, 6, 9, 11]),
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
% NEGACAO FORTE

-utente(Id, Nome, Idade, Morada) :-
    nao(utente(Id, Nome, Idade, Morada)),
    nao(excecao(utente(Id, Nome, Idade, Morada))).

-prestador(Id, Nome, Especialidade, Instituicao) :-
    nao(prestador(Id, Nome, Especialidade, Instituicao)),
    nao(excecao(prestador(Id, Nome, Especialidade, Instituicao))).

-cuidado(Data, IdUtente, IdPrestador, Descricao, Custo) :-
    nao(cuidado(Data, IdUtente, IdPrestador, Descricao, Custo)),
    nao(excecao(cuidado(Data, IdUtente, IdPrestador, Descricao, Custo))).

-instituicao(Id, Nome, Localidade) :-
	nao(instituicao(Id, Nome, Localidade)),
	nao(excecao(instituicao(Id, Nome, Localidade))).
	
-consulta(Utente, Prestador, HI, HF) :-
	nao(consulta(Utente, Prestador, HI, HF)),
	nao(excecao(consulta(Utente, Prestador, HI, HF))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% INVARIANTES

% Nao permitir a insercao de um utente que ja exista (mesmo id)
% Id deve ser inteiro
% Idade deve ser inteira e estar entre os valores [0, 125]
% Nao permitir a insercao de conhecimento contraditorio
% Nao permitir a alteracao de conhecimento interdito

+utente(Id, Nome, Idade, Morada) :: (
	integer(Id),
	integer(Idade),
	Idade >= 0,
	Idade =< 125,
    solucoes(Id, utente(Id, _, _, _), S1),
	solucoes(Id, -utente(Id, Nome, Idade, Morada), S2),
	solucoes(M, (utente(Id, Nome, Idade, M), nulo(M)), S3),
    comprimento(S1, 0),
	comprimento(S2, N2),
	comprimento(S3, 0),
	N2 >= 0,
	N2 =< 1
).


% Nao permitir a insercao de uma negacao forte que ja exista
% Nao permitir a insercao de conhecimento contraditorio
% Nao permitir a alteracao de conhecimento interdito

+(-utente(Id, Nome, Idade, Morada)) :: (
    solucoes(Id, utente(Id, Nome, Idade, Morada), S1),
	solucoes(Id, -utente(Id, Nome, Idade, Morada), S2),
	solucoes(M, (utente(Id, N, I, M), nulo(M)), S3), 
    comprimento(S1, 0),
	comprimento(S2, N2),
	comprimento(S3, 0),
	N2 >= 0,
	N2 =< 1
).


% Nao permitir a remocao de utente enquando existirem cuidados prestados e consultas
% associadas ao mesmo

-utente(IdUt, _, _, _) :: (
	solucoes(IdUt, cuidado(_, IdUt, _, _, _), S1),
	solucoes(IdUt, consulta(IdUt, _, _, _), S2),
	comprimento(S1, 0),
	comprimento(S2, 0)
).


% Nao permitir a insercao de um prestador que ja exista (mesmo id) ou cuja instituicao 
% a que pertence nao exista
% Id deve ser inteiro
% Nao permitir a insercao de conhecimento contraditorio

+prestador(Id, Nome, Especialidade, IdIns) :: (
	integer(Id),
    solucoes(Id, prestador(Id, _, _, _), S1),
	solucoes(IdIns, instituicao(IdIns, _, _), S2),
	solucoes(Id, -prestador(Id, Nome, Especialidade, IdIns), S3),
    comprimento(S1, 0),
	comprimento(S2, 1),
	comprimento(S3, N3),
	N3 >= 0, 
	N3 =< 1
).


% Nao permitir a insercao de uma negacao forte que ja exista
% Nao permitir a insercao de conhecimento contraditorio

+(-prestador(Id, Nome, Especialidade, IdIns)) :: (
    solucoes(Id, prestador(Id, Nome, Especialidade, IdIns), S1),
	solucoes(Id, -prestador(Id, Nome, Especialidade, IdIns), S2),
    comprimento(S1, 0),
	comprimento(S2, N2),
	N2 >= 0,
	N2 =< 1
).


% Nao permitir a remocao de prestador enquando existirem cuidados prestados 
% e consultas associadas ao mesmo

-prestador(IdPrest, _, _, _) :: (
	solucoes(IdUt, cuidado(_, _, IdPrest, _, _), S1),
	solucoes(IdPrest, consulta(_, IdPrest, _, _), S2),
	comprimento(S1, 0),
	comprimento(S2, 0)
).


% Nao permitir a insercao de um cuidado ja existente ou que esteja associado a um
% utente e a um prestador que nao existam
% O valor do primeiro argumento deve ser uma data
% O custo deve ser do tipo number e ser maior ou igual a zero
% Nao permitir a insercao de conhecimento contraditorio

+cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
	number(Custo), Custo >= 0, data(Data),
    solucoes(IdUt, utente(IdUt, _, _, _), S1),
    solucoes(IdPrest, prestador(IdPrest, _, _, _), S2),
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S3),
	solucoes((Data, IdUt, IdPrest, Descricao, Custo),
		     -cuidado(Data, IdUt, IdPrest, Descricao, Custo),
			 S4),
	solucoes(M, (cuidado(Data, IdUt, IdPrest, M, Custo), nulo(M)), S5),
    comprimento(S1, 1),
    comprimento(S2, 1),
    comprimento(S3, 0),
	comprimento(S4, N4),
	comprimento(S5, 0),
	N4 >= 0,
	N4 =< 1
).


% Nao permitir a insercao de uma negacao forte que ja exista
% Nao permitir a insercao de conhecimento contraditorio
% Nao permitir a alteracao de conhecimento interdito

+(-cuidado(Data, IdUt, IdPrest, Descr, Custo)) :: (
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S1),
	solucoes((Data, IdUt, IdPrest, Descricao, Custo),
		     -cuidado(Data, IdUt, IdPrest, Descricao, Custo),
			 S2),
	solucoes(M, (cuidado(Data, IdUt, IdPrest, M, Custo), nulo(M)), S3),
    comprimento(S1, 0),
    comprimento(S2, N2),
    comprimento(S3, 0),
	N2 >= 0,
	N2 =< 1
).


% Remocao de um cuidado

-cuidado(Data, IdUt, IdPrest, Descr, Custo) :: (
    solucoes((Data, IdUt, IdPrest, Descricao, Custo),
             cuidado(Data, IdUt, IdPrest, Descricao, Custo),
             S),
    comprimento(S, 1)
).


% Nao permitir a insercao de um instituicao que ja exista
% Id deve ser inteiro
% Nao permitir a insercao de conhecimento contraditorio

+instituicao(Id, Nome, Localidade) :: (
	integer(Id),
	solucoes(Id, instituicao(Id, _, _), S1),
	solucoes(Id, -instituicao(Id, Nome, Localidade), S2),
	comprimento(S1, 0),
	comprimento(S2, N2),
	N2 >= 0,
	N2 =< 1
).


% Nao permitir a insercao de uma negacao forte que ja exista
% Nao permitir a insercao de conhecimento contraditorio

+(-instituicao(Id, Nome, Localidade)) :: (
	solucoes(Id, instituicao(Id, Nome, Localidade), S1),
	solucoes(Id, -instituicao(Id, Nome, Localidade), S2),
	comprimento(S1, 0),
	comprimento(S2, N2),
	N2 >= 0,
	N2 =< 1
).


% Nao permitir a remocao de uma instituicao que tenha prestadores registados

-instituicao(Id, _, _) :: (
	solucoes(Id, prestador(_, _, _, Id), S1),
	solucoes(Id, instituicao(Id, _, _), S2),
	comprimento(S1, 0),
	comprimento(S2, 1)
).


% Nao permitir a insercao de uma consulta que ja exista ou que esteja associada a
% um utente ou a um prestador que nao existam
% O terceiro e o quarto argumentos devem ser horas
% Nao permitir a insercao de uma consulta que colida com o horario de consultas já
% marcadas com um prestador
% Nao permitir a insercao de conhecimento contraditorio

+consulta(IdU, IdP, HI, HF) :: (
	data_hora(HI), data_hora(HF),
	solucoes(IdU, utente(IdU, _, _, _), S1),
	solucoes(IdP, prestador(IdP, _, _, _), S2),
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), S3),
	solucoes((HI1, HF1), consulta(IdU1, IdP, HI1, HF1), S4),
	solucoes((IdU, IdP, HI, HF), -consulta(IdU, IdP, HI, HF), S5),
	comprimento(S1, 1),
	comprimento(S2, 1),
	comprimento(S3, 0),
	comprimento(S5, N5),
	nao_colide(HI, HF, S4),
	N5 >= 0,
	N5 =< 1
).
	

% Nao permitir a insercao de uma negacao forte que ja exista
% Nao permitir a insercao de conhecimento contraditorio
	
+(-consulta(IdU, IdP, HI, HF)) :: (
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), S1),
	solucoes((IdU, IdP, HI, HF), -consulta(IdU, IdP, HI, HF), S2),
	comprimento(S1, 0),
	comprimento(S2, N2),
	N2 >= 0,
	N2 =< 1
).
	
	
% Remocao de uma consulta
	
-consulta(IdU, IdP, HI, HF) :: (
	solucoes((IdU, IdP, HI, HF), consulta(IdU, IdP, HI, HF), S),
    comprimento(S, 1)
).
	

	
	
	
	
	
	
% CONSULTAS %
	
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
% Extensao do predicado procura_consultas: IdU, IdP, HI, HF, Lista -> {V, F}
% Procura consultas por uma dada data

procura_consultas(data(D, M, A), L) :-
	solucoes((IdU, IdP, data_hora(D, M, A, H1, M1), data_hora(D, M, A, H2, M2)),
		consulta(IdU, IdP, data_hora(D, M, A, H1, M1), data_hora(D, M, A, H2, M2)),
		L).
		
	
	

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
utente(11, inc01, 49, 'Rua do Forno'). 
utente(50, 'Costa', 67, int01).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado excecao: Utente -> {V, F}	

excecao(utente(13, 'Zulmira', Idade, 'Rua da Mina')) :-
	Idade >= 25,
	Idade =< 30.
excecao(utente(13, 'Zulma', Idade, 'Rua da Mina')) :-
	Idade >= 25,
	Idade =< 30.
	
	
excecao(utente(Id, Nome, Idade, Morada)) :- 
	utente(Id, inc01, Idade, Morada).

excecao(utente(24, 'Zueiro', 46, 'Rua de tras')).
excecao(utente(24, 'Zueiro', 46, 'Curral de Moinas')).	
excecao(utente(Id, Nome, Idade, Morada)) :-
	utente(Id, Nome, Idade, int01).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado incerto: Utente -> {V, F}	

incerto(utente(11)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imprecisoIntervalo: Utente -> {V, F}	

imprecisoIntervalo(utente(13)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado impreciso: Utente -> {V, F}	

impreciso(utente(24)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado nulo: Valor -> {V, F}	

nulo(int01).
	

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
prestador(11, 'Jonas',    'Cardiologia', inc01).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado excecao: Prestador -> {V, F}	

excecao(prestador(Id, Nome, Especialidade, Instituicao)) :-
	prestador(Id, Nome, Especialidade, inc01).

excecao(prestador(12, 'Luis', 'Oncologia', 3)).
excecao(prestador(12, 'Luis', 'Dermatologia', 3)).
excecao(prestador(12, 'Luis', 'Cardiologia', 3)).
	
excecao(prestador(13, 'Catia', 'Radiografia', I)) :-
	pertence(I, [1, 2, 3, 4]).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado incerto: Prestador -> {V, F}	

incerto(prestador(11)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado impreciso: Prestador -> {V, F}	

impreciso(prestador(12)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imprecisoIntervalo: Prestador -> {V, F}	

imprecisoIntervalo(prestador(13)).


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
cuidado(data(24, 4, 2018), 2, 3, int01, 49.99).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado excecao: Cuidado -> {V, F}	

excecao(cuidado(data(27, 3, 2018), 10, 0, 'Consulta Cardiologia', P)) :-
	P >= 10,
	P =< 50.

excecao(cuidado(Data, Utente, Prestador, Desc, Custo)) :-
	cuidado(Data, Utente, Prestador, int01, Custo).

	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado imprecisoIntervalo: Cuidado -> {V, F}	

imprecisoIntervalo(cuidado(data(27, 3, 2018), 10, 0)).	


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado instituicao: Id, Nome, Cidade -> {V, F}	

instituicao(1, 'Hospital de Braga', 'Braga').
instituicao(2, 'Hospital de Guimaraes', 'Guimaraes').
instituicao(3, 'Hospital do Porto', 'Porto').
instituicao(4, 'Hospital de Lisboa', 'Lisboa').
instituicao(5, inc01, 'Setubal').


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado excecao: Instituicao -> {V, F}	

excecao(instituicao(Id, Nome, Localidade)) :-
	instituicao(Id, inc01, Localidade).

excecao(instituicao(6, 'Curral de Moinas Hospital', 'Curral de Moinas')).
excecao(instituicao(6, 'Curral de Moinas Hospital', 'Moinas do Curral')).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado incerto: Instituicao -> {V, F}	

incerto(instituicao(5)).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado impreciso: Instituicao -> {V, F}	

impreciso(instituicao(6)).



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

consulta(5, 7, data_hora(27, 1, 2018, 16, 40), inc01).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado excecao: Consulta -> {V, F}	

excecao(consulta(Utente, Prestador, HI, HF)) :-
	consulta(Utente, Prestador, HI, inc01).

excecao(consulta(6, 8, data_hora(26, 3, 2018, 13, 0), 
	data_hora(26, 3, 2018, 14, 50))).
excecao(consulta(6, 8, data_hora(26, 3, 2018, 13, 0), 
	data_hora(26, 3, 2018, 14, 30))).
	
	
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado incerto: Consulta -> {V, F}	

incerto(consulta(5, 7, data_hora(27, 1, 2018, 16, 40))).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado impreciso: Consulta -> {V, F}	

impreciso(consulta(6, 8, data_hora(26, 3, 2018, 13, 0))).