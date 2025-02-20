library(R.matlab) # Lee el documento .mat
library(dplyr) # Manejo de información en general
library(caret) # Partir la información y es muy bueno para ML
library(MASS) # Responsable de LDA
library(earth) # Otorga importance a las variables

getDf <- function(){
     data <- readMat('Data/Raw/FeatureMatrices.mat') # Lee la matriz de matlab
     
     unmin <- as.data.frame(data$WFM.1) # Obtiene la WFM.1 y la convierte en un data frame
     
     feature_names <- unlist(data$FMinfo) # Obtiene los nombres del documento FMinfo
     
     feature_names <- gsub(' \\(', '_', feature_names) ## Remueve 
     feature_names <- gsub(')', '', feature_names)
     feature_names <- gsub('`', '', feature_names)
     feature_names <- gsub('\\/', '-', feature_names)
     
     colnames(unmin) <- feature_names # Aplica estos nombres al df creado
     
     df <- filter_all(unmin, all_vars(. < 20)) # Filtra a rows que estén debajo de 20
     df <- mutate(df, Clas = as.factor(Clas)) # Clas como variable categórica
     
     ## Index de datos no usados
     EDA_index <- 121:129 # Variables como EDA, TEMP, HR, HF, LF, VLF, TP, LF_HF, LF_NU
     div_index <- 41:120 # Las divisiones de las variables principales
     
     df <- df[,-EDA_index] # Remueve las variables EDA
     
     set.seed(2031)
     
     df <- upSample(df[,-length(df)], df$Clas, yname = 'Clas') # Realiza un upSample
     # Esto es para reducir el class imbalance que existe en el set de datos
     
     return(df)
}

df <- getDf() # Obtiene el df con la función generada anteriormente

ldaProf <- function(df, sizes = 1:50) {
     set.seed(1002)
     
     inTrain <- createDataPartition(df$Clas, p = .75, list = FALSE)[,1]
     
     train <- df[ inTrain, -length(df)] # Sólo variables continuas
     trainClass <- df$Clas[inTrain] # Variable categórica
     
     set.seed(302)
     
     ## Realiza un perfil de importancia respecto a LDA
     ldaProfile <- rfe(train, trainClass, sizes = sizes,
                       rfeControl = rfeControl(functions = ldaFuncs, method = 'cv'))
     ldaProfile
}

dfTopN <- function(df, n = 44){
     topn <- head(ldaProf(df)$variables$var, n) # Las mejores 44 variables (daba 0.9)
     
     df <- df[,c(topn, 'Clas')] # Subset con estas mejores variables
     
     ## Multivariate Adaptive Regression Splines para importancia de features
     marsModel <- earth(Clas ~ ., data = df, pmethod = 'cv', nfold = 5)
     ev <- evimp(marsModel) # Estima la importancia de cada variable
     
     nombresMARS <- gsub("`", "", rownames(ev)) # Nombres de las columnas
     
     df <- df[,c(nombresMARS, 'Clas')] # Subset con las columnas MARS
     
     return(df)
}

df <- dfTopN(df, n = 44) # Función declarada anteriormente para obtener top 10 variables

## Generalized Testing using gbm & rf

geneTesting <- function(df){ 
     set.seed(1002)
     
     trainIndex <- createDataPartition(df$Clas, p = 0.70, list = FALSE) # Divide los datos
     training <- df[trainIndex,] # Data del training
     testing <- df[-trainIndex,] # Data del testing
     
     prob_modelo <- function(training, met, testing, control){
          
          if(met == 'gbm'){
               modelo <- train(Clas ~ ., data = training, method = met, trControl = control, 
                               verbose = FALSE) # verbose = FALSE cuando se usa gbm
          } else{
               modelo <- train(Clas ~ ., data = training, method = met, trControl = control,
                               tuneLength = length(train)) # tuneLength = ncols(train) cuando rf
          }
          
          Pred <- predict(modelo, testing) # Se predicen los valores con base en testing
          
          acc <- round(confusionMatrix(testing$Clas, Pred)$overall[1], 5) # Accuracy de resultados
          return(acc)
     }
     
     n <- 5 # Número máximo de folds en crossvalidations
     metodos <- c('rf', 'gbm') # Los dos métodos usados
     df_modelos <- data.frame(rf = NA, gbm = NA) # df inicial de ambos métodos
     for(metodo in metodos){
          accs <- c() # Vector vacio donde se depositarán las accuracies
          for(num in 2:n){
               control <- trainControl(method = 'cv', number = num) # Número de folds en crossvalidation
               acc <- prob_modelo(training, metodo, testing, control) # Función de arriba para acc
               accs <- c(accs, acc) # Accs del mismo método, diferentes folds de crossvalidation
          }
          df_modelos[,metodo] <- mean(accs) # Append al dataframe de promedio(accs) dependiendo del método 
     }
     return(df_modelos)
}


n <- length(df) - 1 # Cantidad de features máximas encontradas en el df
dfEval <- data.frame(n_vars = 2:n, rf = NA, gbm = NA) # Declaración de df vacio, donde estarán las accs

for(i in 2:n){
     dfEval[dfEval$n_vars == i,c('rf', 'gbm')] <- geneTesting(df[,c(1:i, length(df))]) # Append de accs
     #print(paste(round(((i - 1)/(length(2:n))), 2) * 100, '%', sep = '')) # Para medir cuanto le falta a la maquina
}
dfEval # df de accuracies que existen en 

colnames(df) # Top 10 columnas con base en los métodos utilizados