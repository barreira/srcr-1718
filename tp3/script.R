set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

# ir buscar dados
dados <- read.csv("C:\\Users\\João Pires Barreira\\Documents\\GitHub\\srcr-1718\\tp3\\dataset\\bank.csv", sep=";")

# mostrar a cabeca dos dados
head(dados)

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

dados$job <- match(dados$job, jobs)
dados$marital <- match(dados$marital, maritals)
dados$education <- match(dados$education, educations)
dados$default <- match(dados$default, booleans) - 1
dados$housing <- match(dados$housing, booleans) - 1
dados$loan <- match(dados$loan, booleans) - 1
dados$contact <- match(dados$contact, contacts)
dados$month <- match(dados$month, months)
dados$poutcome <- match(dados$poutcome, outcomes)
dados$y <- match(dados$y, booleans) - 1

max(dados$balance)
min(dados$balance)

# balance <- discretize(dados$balance, method="cluster", categories=20, labels=seq(1,20))
# dados$balance <- as.numeric(balance)

funcao <- y ~ default+balance+housing+loan

treino <- dados[1:2300, ]
teste <- dados[2301:4521, ]

testeargs <- subset(teste, select=c("default","balance","housing","loan"))

dados

rede <- neuralnet(funcao, treino, hidden=c(8,4), lifesign="full", linear.output=FALSE, threshold=0.1)

# plot(rede, rep="best")

rede.resultados <- compute(rede, testeargs)

resultados <- data.frame(atual = teste$y, previsao = rede.resultados$net.result)

resultados$previsao <- round(resultados$previsao, digits=0)

rmse(c(teste$y), c(resultados$previsao))

