%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3 - EXERCICIO 1


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag(discontiguous_warnings, off).
:- set_prolog_flag(single_var_warnings, off).
:- set_prolog_flag(unknown, fail).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op(900, xfy, '::').
:- dynamic utente/4.
:- dynamic cuidado_prestado/4.
%:- dynamic ato_medico/4.

:- dynamic profissional/4.
:- dynamic atribuido/2.
:- dynamic ato_medico/5.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Inv
+utente(Id, _, _, _) :: (
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
    N == 1
).

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