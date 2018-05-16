set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

# ir buscar dados
dados <- read.csv("D:\\SRCR\\projeto\\srcr-1718\\tp3\\dataset\\bank-full.csv", sep=";")

normalize <- function(x) { (x - min(x)) / (max(x) - min(x))}

if (FALSE) {
  dados$age == 50
  
  var <- dados[dados$y=="yes", ]
  
  summary(var)
  
  var[, c(5,6,7,8)]
  
  sum(var[, 6]<0)
  
  length(var)
  
  nrow(var)
  
  sum(var[, 5]=="yes") 
}

jobs <- c("admin.","unknown","unemployed","management","housemaid","entrepreneur","student","blue-collar","self-employed","retired","technician","services")
maritals <- c("married","divorced","single")
educations <- c("unknown","secondary","primary","tertiary")
contacts <- c("unknown","telephone","cellular")
outcomes <- c("unknown","other","failure","success")
months <- c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")
booleans <- c("no", "yes")

dados$job <- normalize(match(dados$job, jobs))
dados$marital <- normalize(match(dados$marital, maritals))
dados$education <- normalize(match(dados$education, educations))
dados$default <- match(dados$default, booleans) - 1
dados$housing <- match(dados$housing, booleans) - 1
dados$loan <- match(dados$loan, booleans) - 1
dados$contact <- normalize(match(dados$contact, contacts))
dados$month <- normalize(match(dados$month, months))
dados$poutcome <- normalize(match(dados$poutcome, outcomes))
dados$y <- match(dados$y, booleans) - 1
dados$duration <- normalize(dados$duration)
dados$pdays <- normalize(dados$pdays)
dados$poutcome <- normalize(dados$poutcome)
dados$balance <- normalize(dados$balance)

selecao <- regsubsets(y ~ age+job+marital+education+default+balance+housing+loan+contact+day+month+duration+campaign+pdays+previous+poutcome, dados, method="backward")
summary(selecao)

funcao1 <- y ~ duration
funcao2 <- y ~ duration+poutcome
funcao3 <- y ~ housing+duration+poutcome
funcao4 <- y ~ housing+duration+pdays+poutcome
funcao5 <- y ~ housing+contact+duration+pdays+poutcome
funcao6 <- y ~ housing+loan+contact+duration+pdays+poutcome
funcao7 <- y ~ marital+housing+loan+contact+duration+pdays+poutcome
funcao8 <- y ~ marital+balance+housing+loan+contact+duration+pdays+poutcome

treino <- dados[1:4521, ]
teste <- dados[4522:45211, ]

testeargs1 <- subset(teste, select=c("duration"))
testeargs2 <- subset(teste, select=c("duration","poutcome"))
testeargs3 <- subset(teste, select=c("housing","duration","poutcome"))
testeargs4 <- subset(teste, select=c("housing","duration","pdays","poutcome"))
testeargs5 <- subset(teste, select=c("housing","contact","duration","pdays","poutcome"))
testeargs6 <- subset(teste, select=c("housing","loan","contact","duration","pdays","poutcome"))
testeargs7 <- subset(teste, select=c("marital","housing","loan","contact","duration","pdays","poutcome"))
testeargs8 <- subset(teste, select=c("marital","balance","housing","loan","contact","duration","pdays","poutcome"))


rede <- neuralnet(funcao8, treino, hidden=c(3,2), lifesign="full", linear.output=FALSE, threshold=0.01)

plot(rede, rep="best")

rede.resultados <- compute(rede, testeargs8)

resultados <- data.frame(atual = teste$y, previsao = rede.resultados$net.result)

resultados$previsao <- round(resultados$previsao, digits=0)

rmse(c(teste$y), c(resultados$previsao))





# nova rede 

dados2 <- data.frame(default=dados$default, loan=dados$loan, housing=dados$housing, balance=dados$balance, y=numeric(nrow(dados)))
dados2$y <- dados$default == 0 & dados$loan == 0 & dados$housing == 0 & dados$balance > 0
dados2$y <- as.integer(as.logical(dados2$y))

selecao2 <- regsubsets(y ~ default+loan+housing+balance, dados2, method="backward")

funcao2 <- y ~ default+loan+housing+balance

treino2 <- dados2[1:25000, ]
teste2 <- dados2[25001:45211, ]

testeargs2 <- subset(teste2, select=c("default","loan","housing","balance"))

rede2 <- neuralnet(funcao2, treino2, hidden=c(3,2), lifesign="full", linear.output=FALSE, threshold=0.01)

plot(rede2, rep="best")

rede.resultados2 <- compute(rede2, testeargs2)

resultados2 <- data.frame(atual = teste2$y, previsao = rede.resultados2$net.result)

resultados2$previsao <- round(resultados2$previsao, digits=0)

rmse(c(teste2$y), c(resultados2$previsao))