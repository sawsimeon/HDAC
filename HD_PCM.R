

library(readxl)
library(RWeka)
library(Rcpi)
library(caret)
data <- read_excel("data.xlsx")
Activity <- data$Activity
compound <- data[, 3:309]
protein <- data[, 311: 937]
### remove zero Variance
zeroVar <- function(dat) {
  out <- lapply(dat, function(x) length(unique(x)))
  want <- which(!out > 1)
  unlist(want)
}

compound <- compound[, -zeroVar(compound)]
protein <- protein[, -zeroVar(protein)]
#### centering and scaling
compound <- compound[, -nearZeroVar(compound, allowParallel = TRUE)]
protein <- protein[, -nearZeroVar(protein, allowParallel = TRUE)]

compound <- apply(compound, MARGIN = 2, FUN = function(x) (x - min(x))/diff(range(x)))
protein <- apply(protein, MARGIN = 2, FUN = function(x) (x -min(x))/diff(range(x)))
#### Correltation Removed 0.7 percent

cor_removed <- function(x) {
  x <- x[, !apply(x, 2, function(x) length(unique(x)) ==1)]
  raw <- cor(x)
  raw_2 <- raw[1: ncol(raw), 1: ncol(raw)]
  high <- findCorrelation(raw_2, cutoff = 0.7)
  remove <- x[, -high]
  input <- remove
  return(input)
}

compound <- cor_removed(compound) ### 33
protein <- cor_removed(protein) ### 26


#pca_compound <- prcomp(compound, retx = TRUE, center = TRUE, scale. = TRUE)
#pca_protein <- prcomp(protein, retx = TRUE, center = TRUE, scale. = TRUE)
#### 
CxP <- getCPI(compound, protein, type = "tensorprod")
CxP <- as.data.frame(CxP)
dfcompound <- names(data.frame(compound[,1:33]))
dfprotein <- names(data.frame(protein[,1:26]))
compoundNamecross <- rep(dfcompound, each = 26)
proteinNamecross <- rep(dfprotein, times = 26)
label <- paste(compoundNamecross, proteinNamecross, sep="_")
colnames(CxP) <- label
CxP <- as.data.frame(CxP)


PxP <- getCPI(protein, protein, type = "tensorprod")
proteinName2 <- rep(dfprotein, times = 26)
proteinName1 <- rep(dfprotein, each = 26)
label_protein <- paste(proteinName1, proteinName2, sep = "_")
colnames(PxP) <- label_protein
index <- seq(1, 676, by = 27)
protein_selfcross <- PxP[, -index]
transposedIndexed_protein <- t(protein_selfcross)
index1 <- which(duplicated(transposedIndexed_protein))
removed_duplicated_protein <- transposedIndexed_protein[-index1, ]
PxP <- t(removed_duplicated_protein)
PxP <- as.data.frame(PxP)

CxC <- getCPI(compound, compound, type = "tensorprod")
compoundName2 <- rep(dfcompound, times = 33)
compoundName1 <- rep(dfcompound, each = 33)
label <- paste(compoundName1, compoundName2, sep = "_")
colnames(CxC) <- label
index3 <- seq(1, 1089, by = 34)
compound_selfcross <- CxC[, -index3]
transposedIndexed_compound <- t(compound_selfcross)
index4 <- which(duplicated(transposedIndexed_compound))
removed_compound <- transposedIndexed_compound[-index4, ]
compound_finalcrossterms <- t(removed_compound)
CxC <- compound_finalcrossterms
CxC <- as.data.frame(CxC)

#compound
C <- compound
C <- as.data.frame(C)
#protein
P <- protein
P <- as.data.frame(P)
#CxP
#CxC
#PxP
C_P <- cbind(C, P)
C_P_CxP_data_block_scale <- cbind(C, P, CxP) * (1/sqrt(length(C)+length(P)+length(CxP)))
#A_B_AxB_data <- cbind(affinity, A_B_AxB_data_block_scale)
C_P_CxC_data_block_scale <- cbind(C, P, 
                                  CxC) * (1/sqrt(length(C)+length(P)+length(CxC)))
#A_B_AxA_data <- cbind(affinity, A_B_AxA_data_block_scale)
C_P_PxP_data_block_scale <- cbind(C, P,
                                  PxP) * (1/sqrt(length(C)+length(P)+length(PxP)))
#A_B_BxB_data <- cbind(affinity, A_B_BxB_data_block_scale)
C_P_CxP_CxC_data_block_scale <- cbind(C, P, CxP,
                                      CxC) * (1/sqrt(length(C)+length(P)+length(CxP)+length(CxC)))
#A_B_AxB_AxA_data <- cbind(affinity, A_B_AxB_AxA_data_block_scale)
C_P_CxP_PxP_data_block_scale <- cbind(C, P, CxP,
                                      PxP) * (1/sqrt(length(C)+length(P)+length(CxP)+length(PxP)))
#A_B_AxB_BxB_data <- cbind(affinity, A_B_AxB_BxB_data_block_scale)
C_P_CxC_PxP_data_block_scale <- cbind(C, P, CxC,
                                      PxP) * (1/sqrt(length(C)+length(P)+length(CxC)+length(PxP)))
#A_B_AxA_BxB_data <- cbind(affinity, A_B_AxA_BxB_data_block_scale)
C_P_CxP_CxC_PxP_data_block_scale <- cbind(C, P, CxP, CxC, PxP) * (1/sqrt(length(C)+length(P)+
                                                                           length(CxC)+length(PxP)))
#A_B_AxB_AxA_BxB_data <- cbind(affinity, A_B_AxB_AxA_BxB_data_block_scale)

C <- cbind(Activity, C)
P <- cbind(Activity, P)
CxP <- cbind(Activity, CxP)
CxC <- cbind(Activity, CxC)
PxP <- cbind(Activity, PxP)
C_P <- cbind(Activity, C_P)
C_P_CxP <- cbind(Activity, C_P_CxP_data_block_scale)
C_P_CxC <- cbind(Activity, C_P_CxC_data_block_scale)
C_P_PxP <- cbind(Activity, C_P_PxP_data_block_scale)
C_P_CxP_CxC <- cbind(Activity, C_P_CxP_CxC_data_block_scale)
C_P_CxP_PxP <- cbind(Activity, C_P_CxP_PxP_data_block_scale)
C_P_CxC_PxP <- cbind(Activity, C_P_CxC_PxP_data_block_scale)
C_P_CxP_CxC_PxP <- cbind(Activity, C_P_CxP_CxC_PxP_data_block_scale)

### Preparing input for build model

input <- list(C = C,
              P = P, 
              CxP = CxP,
              CxC = CxC,
              PxP = PxP,
              C_P = C_P,
              C_P_CxP = C_P_CxP,
              C_P_CxC = C_P_CxC,
              C_P_PxP = C_P_PxP,
              C_P_CxP_CxC = C_P_CxP_CxC,
              C_P_CxP_PxP = C_P_CxP_PxP,
              C_P_CxC_PxP = C_P_CxC_PxP,
              C_P_CxP_CxC_PxP = C_P_CxP_CxC_PxP)


#### J48 training
J48_training <- function(x) {
  library(parallel)
  library(doSNOW)
  cl <- makeCluster(8)
  registerDoSNOW(cl)
  results <- list(100)
  
  results <- foreach(i = 1:100) %dopar% {
    in_train <- caret::createDataPartition(x$Activity, p = 0.8, list = FALSE)
    train <- x[in_train, ]
    test <- x[-in_train, ]
    rm(in_train)
    rm(test)
    model_train <- RWeka::J48(Activity~., data = train)
    summary <- summary(model_train)
    rm(model_train)
    confusionmatrix <- summary$confusionMatrix
    results[[i]] <- as.numeric(confusionmatrix)
  }
  return(results)
  stopCluster(cl)
}

### mean and SD value

mean_and_sd <- function(x) {
  c(round(mean(x, na.rm = TRUE), digits = 4),
    round(sd(x, na.rm = TRUE), digits = 4))
}

J48_train <- function(x) {
  ok <- J48_training(x)
  results <- data.frame(ok)
  data <- data.frame(results)
  m = ncol(data)
  ACC  <- matrix(nrow = m, ncol = 1)
  SENS  <- matrix(nrow = m, ncol = 1)
  SPEC  <-matrix(nrow = m, ncol = 1)
  MCC <- matrix(nrow = m, ncol = 1)
  
  for(i in 1:m){ 
    ACC[i,1]  = (data[1,i]+data[4,i])/(data[1,i]+data[2,i]+data[3,i]+data[4,i])*100
    SENS[i,1]  =  (data[4,i])/(data[3,i]+data[4,i])*100
    SPEC[i,1]  = (data[1,i]/(data[1,i]+data[2,i]))*100
    MCC1      = (data[1,i]*data[4,i]) - (data[2,i]*data[3,i])
    MCC2      =  (data[4,i]+data[2,i])*(data[4,i]+data[3,i])
    MCC3      =  (data[1,i]+data[2,i])*(data[1,i]+data[3,i])
    MCC4  =  sqrt(MCC2)*sqrt(MCC3)
    
    
    MCC[i,1]  = MCC1/MCC4
  }
  results_ACC <- mean_and_sd(ACC)
  results_SENS <- mean_and_sd(SENS)
  results_SPEC <- mean_and_sd(SPEC)
  results_MCC <- mean_and_sd(MCC)
  results_all <- (data.frame(c(results_ACC, results_SENS, results_SPEC, results_MCC)))
  rownames(results_all) <- c("ACC_Mean", "ACC_SD", "Sens_Mean",
                             "Sens_SD", "Spec_Mean", "Spec_SD",
                             "MCC_Mean", "MCC_SD")
  return(results_all)
}

results_HD_PCM_Training <- lapply(input, function(x) {
  results <- J48_train(x)
  return(results)
})
print(results_HD_PCM_Training)


### function for 10 fold cross validation

J48_10fold <- function(x) {
  library(parallel)
  library(doSNOW)
  cl <- makeCluster(8)
  registerDoSNOW(cl)
  results <- list(100)
  
  results <- foreach(i = 1:100) %dopar% {
    in_train <- caret::createDataPartition(x$Activity, p = 0.8, list = FALSE)
    train <- x[in_train, ]
    test <- x[-in_train, ]
    rm(in_train)
    rm(test)
    
    model_train <- J48(Activity~., data = train)
    eval_j48 <- evaluate_Weka_classifier(model_train, numFolds = 10, complexity = FALSE, seed = 1, class = TRUE)
    confusionmatrix <- eval_j48$confusionMatrix
    results[[i]] <- as.numeric(confusionmatrix)
  }
  return(results)
}

J48_cross_validation <- function(x) {
  ok <- J48_10fold(x)
  results <- data.frame(ok)
  data <- data.frame(results)
  m = ncol(data)
  ACC  <- matrix(nrow = m, ncol = 1)
  SENS  <- matrix(nrow = m, ncol = 1)
  SPEC  <-matrix(nrow = m, ncol = 1)
  MCC <- matrix(nrow = m, ncol = 1)
  
  for(i in 1:m){ 
    ACC[i,1]  = (data[1,i]+data[4,i])/(data[1,i]+data[2,i]+data[3,i]+data[4,i])*100
    SENS[i,1]  =  (data[4,i])/(data[3,i]+data[4,i])*100
    SPEC[i,1]  = (data[1,i]/(data[1,i]+data[2,i]))*100
    MCC1      = (data[1,i]*data[4,i]) - (data[2,i]*data[3,i])
    MCC2      =  (data[4,i]+data[2,i])*(data[4,i]+data[3,i])
    MCC3      =  (data[1,i]+data[2,i])*(data[1,i]+data[3,i])
    MCC4  =  sqrt(MCC2)*sqrt(MCC3)
    
    
    MCC[i,1]  = MCC1/MCC4
  }
  results_ACC <- mean_and_sd(ACC)
  results_SENS <- mean_and_sd(SENS)
  results_SPEC <- mean_and_sd(SPEC)
  results_MCC <- mean_and_sd(MCC)
  results_all <- (data.frame(c(results_ACC, results_SENS, results_SPEC, results_MCC)))
  rownames(results_all) <- c("ACC_Mean", "ACC_SD", "Sens_Mean",
                             "Sens_SD", "Spec_Mean", "Spec_SD",
                             "MCC_Mean", "MCC_SD")
  return(results_all)
}

#### results for 10 fold cross validation

results_HD_PCM_10_fold <- lapply(input, function(x) {
  results <- J48_cross_validation(x)
  return(results)
})
print(results_HD_PCM_10_fold)



#### J48 modeling testing results
J48_testing <- function(x) {
  library(parallel)
  library(doSNOW)
  cl <- makeCluster(8)
  registerDoSNOW(cl)
  results <- list(100)
  
  results <- foreach(i = 1:100) %dopar% {
    in_train <- caret::createDataPartition(x$Activity, p = 0.8, list = FALSE)
    train <- x[in_train, ]
    test <- x[-in_train, ]
    rm(in_train)
    model_train <- J48(Activity~., data = train)
    eval_external <- evaluate_Weka_classifier(model_train, newdata = test, numFolds = 0, complexity = FALSE, seed = 1, class = TRUE)
    confusionmatrix <- eval_external$confusionMatrix
    results[[i]] <- as.numeric(confusionmatrix)
  }
  return(results)
}

J48_external <- function(x) {
  ok <- J48_testing(x)
  results <- data.frame(ok)
  data <- data.frame(results)
  m = ncol(data)
  ACC  <- matrix(nrow = m, ncol = 1)
  SENS  <- matrix(nrow = m, ncol = 1)
  SPEC  <-matrix(nrow = m, ncol = 1)
  MCC <- matrix(nrow = m, ncol = 1)
  
  for(i in 1:m){ 
    ACC[i,1]  = (data[1,i]+data[4,i])/(data[1,i]+data[2,i]+data[3,i]+data[4,i])*100
    SENS[i,1]  =  (data[4,i])/(data[3,i]+data[4,i])*100
    SPEC[i,1]  = (data[1,i]/(data[1,i]+data[2,i]))*100
    MCC1      = (data[1,i]*data[4,i]) - (data[2,i]*data[3,i])
    MCC2      =  (data[4,i]+data[2,i])*(data[4,i]+data[3,i])
    MCC3      =  (data[1,i]+data[2,i])*(data[1,i]+data[3,i])
    MCC4  =  sqrt(MCC2)*sqrt(MCC3)
    
    
    MCC[i,1]  = MCC1/MCC4
  }
  results_ACC <- mean_and_sd(ACC)
  results_SENS <- mean_and_sd(SENS)
  results_SPEC <- mean_and_sd(SPEC)
  results_MCC <- mean_and_sd(MCC)
  results_all <- (data.frame(c(results_ACC, results_SENS, results_SPEC, results_MCC)))
  rownames(results_all) <- c("ACC_Mean", "ACC_SD", "Sens_Mean",
                             "Sens_SD", "Spec_Mean", "Spec_SD",
                             "MCC_Mean", "MCC_SD")
  return(results_all)
}

### results for testing set

results_HD_PCM_testing <- lapply(input, function(x) {
  results <- J48_external(x)
  return(results)
})
print(results_HD_PCM_testing)
