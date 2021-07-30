
# The following script uses another feature selection technique that replaces
# the previously used LDA. As rf showed promising results, its feature
# selection technique will be used, as the computation of GINI Importance.
# This technique will reduce the dimensionality to 20, on which the MARS model
# will be fitted, and so the number of features would be reduced to 10.

library(caret)
library(R.matlab)
library(dplyr)
library(randomForest)
library(earth)

getDF <- function(mat, doc, lim = 10, columns = NULL){
     data <- readMat(mat)
     unmin <- as.data.frame(data[doc])
     
     feature_names <- unlist(data$FMinfo)
     feature_names <- gsub(' \\(', '_', feature_names)
     feature_names <- gsub(')', '', feature_names)
     feature_names <- gsub('`', '', feature_names)
     feature_names <- gsub('\\/', '.', feature_names)
     
     if(mat == 'Data/Raw/FeatureMatrices.mat'){
          EDA_index <- 121:129
          unmin <- unmin[,-EDA_index]
          feature_names <- feature_names[-EDA_index]
     }else{
          feature_names <- c(feature_names, 'Clas')
     }
     
     colnames(unmin) <- feature_names
     if(!is.null(columns)){
          unmin <- unmin[,columns]
     }
     df <- unmin
     df <- filter_all(df, all_vars(. < lim))
     df <- filter_all(df, all_vars(. > -lim))
     df <- mutate(df, Clas = as.factor(Clas))
     return(df)
}

perfDocs <- function(doc, lim, columns = NULL, sampling = 'none'){
     mats <- c('Data/Raw/FeatureMatrices.mat', 'Data/Raw/FeatureMatrices_pre.mat')
     
     df1 <- getDF(mats[1], doc, lim, columns)
     df2 <- getDF(mats[2], doc, lim, columns)
     df <- rbind(df1, df2)
     
     if(samp == 'Up'){
          set.seed(2031)
          df <- upSample(df[,-length(df)], df$Clas, yname = 'Clas')
     } else if(samp == 'Down'){
          set.seed(2031)
          df <- downSample(df[,-length(df)], df$Clas, yname = 'Clas')
     }
     return(df)
}

df <- perfDocs(doc = 'WFM.4',lim =  10)

features <- c()
for(seed in 1:20){
     set.seed(seed)
     
     datos_exp <- df
     colnames(datos_exp) <- sapply(1:length(datos_exp), FUN = function(x){paste('V', x, sep = '')})
     colnames(datos_exp)[length(datos_exp)] <- 'Clas'
     rf <- randomForest(Clas ~ ., data = datos_exp)
     feat_import <- importance(rf)
     varImpPlot(rf)
     featImportOrd <- feat_import[order(feat_import, decreasing = TRUE),]
     top10 <- head(featImportOrd, 20)
     top10 <- t(t(top10))
     topFeat <- as.numeric(gsub('V', '', rownames(top10)))
     df2 <- df[,c(topFeat, length(df))]
     
     marsModel <- earth(Clas ~ ., data = df2)
     ev <- evimp(marsModel)
     nombresMARS <- gsub("`", "",rownames(ev))
     dfMARS <- df[,c(nombresMARS, 'Clas')]
     features <- c(features, colnames(dfMARS))
}

df_results <- data.frame(feature = unique(unlist(features)), freq = NA)
for(feature in df_results$feature){
     df_results[df_results$feature == feature,'freq'] <- sum(feature == features)
     if(feature == 'Clas'){
          df_results[df_results$feature == feature,'freq'] <- 0
     }
}
df_results <- df_results[order(df_results$freq, decreasing = TRUE),]
rownames(df_results) <- NULL
best_features <- c(df_results$feature[1:10], 'Clas')

sampling <- c('None', 'Up', 'Down')
for(samp in sampling){
     df <- perfDocs(doc = 'WFM.4', lim = 10, columns = best_features, sampling = samp)
     print(samp)
     print(summary(df$Clas))
     write.csv(df, paste0('Data/Processed/RF_MARS_', samp, '.csv'), row.names = FALSE)
}