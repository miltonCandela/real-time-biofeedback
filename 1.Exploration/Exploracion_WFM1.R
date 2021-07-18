
library(R.matlab)
library(dplyr)

## Leer la información
data <- readMat('Data/Raw/FeatureMatrices.mat')

unmin <- as.data.frame(data$WFM.1) # Utilizando el primer documento de 1 minuto

feature_names <- unlist(data$FMinfo) # Obterner e incluir las columnas en el df
colnames(unmin) <- feature_names

unmin <- as.data.frame(unmin)
unmin <- mutate(unmin, Clas = as.factor(Clas)) # Convertir la clase a una variable de tipo factor

unmin <- unmin[,c(1:120,length(colnames(unmin)))] # Quitar variables de la Empatica (EDA TEMP HR HF)

## División de información por clase

library(caret)

set.seed(1002)

trainIndex <- createDataPartition(unmin$Clas, p = 0.75, list = FALSE)
training <- unmin[trainIndex,]
testing <- unmin[-trainIndex,]

## Prueba de tres modelos
# La información está normalizada, por lo que se puede usar directamente

prob_modelo <- function(training, met, testing, control){
     # Esta función prueba un modelo con la training y testing data
     # varia el número de cross-validations y el método usado

     if(met == 'gbm'){
          modelo <- train(Clas ~ ., data = training, method = met,
                          trControl = control, verbose = FALSE)
     } else{
          modelo <- train(Clas ~ ., data = training, method = met,
                          trControl = control)
     }
     
     Pred <- predict(modelo, testing) # Predicciones usado el modelo
     acc <- round(confusionMatrix(testing$Clas, Pred)$overall[1], 5)
     return(acc)
}

n_max <- 10 # Plantea el número máximo de cross-validations (CV)
metodos <- c('rf', 'gbm', 'lda')
df <- data.frame('rf' = 2:n_max, 'gbm' = 2:n_max, 'lda' = 2:n_max)

# El siguiente ciclo "for" itera entre los métodos del vector "metodos"
# prueba con diferentes CV, desde 2 hasta n_max
for(metodo in metodos){
        print(paste('Método usado:', metodo))
        acc_l <- c()
        for(num in 2:n_max){
                control <- trainControl(method = 'cv', number = num)
                acc <- prob_modelo(training, metodo, testing, control)
                acc_l <- c(acc_l, acc)
                print(paste('Precisión usando', num, 'folds', acc))
        }
        df[,metodo] <- acc_l
}
png(filename = '1. Exploration/EvModelosWFM1.png')
plot(y = df[,1], x = 2:n_max, ylim = c(0.8, 1), xlim = c(2,5), type = 'l', col = 1, lwd = 2,
     ylab = 'Precisión', xlab = 'Cross-Validations (CV)', main = 'Precisión de modelos respecto a CV')
lines(y = df[,2], x = 2:n_max, col = 2, lwd = 2)
lines(y = df[,3], x = 2:n_max, col = 3, lwd = 2)
legend('bottomright', legend = c('rf', 'gbm', 'lda'), col = 1:3, lty = 1, lwd = 2)
dev.off()

# LDA tuvo los mejores resultados, por lo que se trabajará más con el modelo

library(MASS)

modelo_lda <- lda(Clas ~ ., data = training)

## Evaluacion del modelo en training

valores <- predict(modelo_lda)

# Histograma de los grupos
png('1. Exploration/ldaHistogramaTraining1.png')
ldahist(valores$x[,1], g = training$Clas)
dev.off()
png('1. Exploration/ldaHistogramaTraining2.png')
ldahist(valores$x[,2], g = training$Clas)
dev.off()

# Plot usando LDA1 y LDA2, con clases predichas
png('1. Exploration/ldaPlotTraining.png')
plot(valores$x[,1], valores$x[,2], col = training$Clas, xlab = 'LDA1', ylab = 'LDA2', main = 'Clusters por clase')
legend('topright', legend = c(1:3), col = c('black', 'red', 'green'), pch = 20)
dev.off()

## Evaluacion del modelo en testing

pred <- predict(modelo_lda, testing)

print(confusionMatrix(testing$Clas, pred$class))

outliers <- pred$x[,1] > 1000
pred$x[outliers,] <- c(median(pred$x[,1]), median(pred$x[,2]))

png('1. Exploration/ldaHistogramaTesting1.png')
ldahist(pred$x[,1], g = testing$Clas)
dev.off()
png('1. Exploration/ldaHistogramaTesting2.png')
ldahist(pred$x[,2], g = testing$Clas)
dev.off()

num <- 203

outliers <- pred$x[,1] > 1000 
pred$x[outliers,] <- c(median(pred$x[,1]), median(pred$x[,2]))

# Plot usando LDA1 y LDA2, con clases predichas
png('1. Exploration/ldaPlotTesting.png')
plot(pred$x[,1], pred$x[,2], col = testing$Clas, xlab = 'LDA1', ylab = 'LDA2', main = 'Clusters por clase')
legend('topright', legend = c(1:3), col = c('black', 'red', 'green'), pch = 20)
dev.off()

## Analisis del outlier

png('1. Exploration/OutlierWFM1.png')
out_df <- testing[outliers,]
barplot(as.matrix(out_df), las = 2, ylab = 'Valor estandarizado',
        cex.names = 0.5, main = paste('Valores de la fila número ', row.names(out_df)))
dev.off()
