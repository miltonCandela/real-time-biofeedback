# The following script creates a hypergrid of Random Forest's hyperparameters, 
# the objective of this grid search is to find the best parameters for our model.
# This will slightly increase the accuracy on the training set, as well as on
# the testing set.
# It takes some time, as it need to fir a RF model multiple times for each
# unique combination of parameters.

library(dplyr)
library(randomForest)
library(caret)

df <- read.csv('Data/Processed/RF_MARS_Up.csv')
df <- mutate(df, Clas = as.factor(Clas))

set.seed(1002)
trainIndex <- createDataPartition(df$Clas, p = 0.7, list = FALSE)
training <- df[trainIndex,]
testing <- df[-trainIndex,]

hyper_grid <- expand.grid(
     ntree = seq(10, 300, 10),
     maxnodes = seq(100, 1500,100),
     nodesize = c(2:10),
     mtry = c(1:10),
     accTa = 0,
     accTe = 0
)

hyper_grid <- read.csv('5.Tuning/rfGrid.csv')
N <- nrow(hyper_grid)
for(i in 16150:N){
     set.seed(200)
     model <- randomForest(Clas ~ ., data = training, ntree = hyper_grid$ntree[i],
                           type = 'classification', nodesize = hyper_grid$nodesize[i],
                           maxnodes = hyper_grid$maxnodes[i])
     
     predTa <- predict(model, training)
     predTe <- predict(model, testing)
     
     accTa <- round(confusionMatrix(training$Clas, predTa)$overall[1], 5)
     accTe <- round(confusionMatrix(testing$Clas, predTe)$overall[1], 5)
     
     hyper_grid$accTa[i] <- accTa
     hyper_grid$accTe[i] <- accTe
     
     if(i %in% seq(N/100, N, N/100)){
          print(paste((i/N)*(100), '%'))
     }
}
write.csv(hyper_grid, '5.Tuning/rfGrid.csv', row.names = FALSE)