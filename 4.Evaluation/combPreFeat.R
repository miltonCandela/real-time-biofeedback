
# The following script joins both FeatureMatrices.mat and FeatureMatrices_pre.mat
# it already has the best features according to each dataset, although, this
# features can be obtained using the hybrid feature selection technique
# described on the previous reports. The WFM.4 document resulted on more than
# ten features, although it will be limited to ten to mantain integrity with 
# the initial model created on WFM.1

library(R.matlab)
library(dplyr)
library(caret)

getDF <- function(mat, doc, lim = 10){
     data <- readMat(mat)
     
     unmin <- as.data.frame(data[doc])
     
     top10_1 <- c("a-g_P8", "Gamma_P8", "Alpha_P8", "d-g_P8", "t-g_O1",
                  "Theta_O1", "Gamma_O1", "t-g_P7", "Beta_FP1", "t-g_FP1",
                  "Clas")
     top10_4 <- c("Alpha_P7", "Theta_O1", "Beta_P8", "Alpha_C4", "d-g_P8",
                  "Beta_C3", "d-g_O2", "Beta_P7", "a-g_C4", "Theta_C4",
                  "Clas")
     
     feature_names <- unlist(data$FMinfo)
     feature_names <- gsub(' \\(', '_', feature_names)
     feature_names <- gsub(')', '', feature_names)
     feature_names <- gsub('`', '', feature_names)
     feature_names <- gsub('\\/', '-', feature_names)
     
     if(mat == 'Data/Raw/FeatureMatrices.mat'){
          EDA_index <- 121:129
          unmin <- unmin[,-EDA_index]
          feature_names <- feature_names[-EDA_index]
     }else{
          feature_names <- c(feature_names, 'Clas')
     }
     
     colnames(unmin) <- feature_names
     if(doc == 'WFM.1'){
             df <- unmin[,top10_1]
     }else if(doc == 'WFM.4'){
             df <- unmin[,top10_4]
     }
     df <- filter_all(df, all_vars(. < lim))
     df <- filter_all(df, all_vars(. > -lim))
     df <- mutate(df, Clas = as.factor(Clas))
     
     set.seed(2031)
     
     df <- upSample(df[,-length(df)], df$Clas, yname = 'Clas')
}

# The threshold is set to 10 as to make that the values on all features
# is between -10 and 10. Although, this threshold can be changed to get
# another results using more nosiy data.

lim <- 10

feature1 <- getDF('Data/Raw/FeatureMatrices.mat', 'WFM.1', lim = lim)
featurePre1 <- getDF('Data/Raw/FeatureMatrices_pre.mat', 'WFM.1', lim = lim)
featureBoth1 <- rbind(feature1, featurePre1)

write.csv(featureBoth1, file = 'Data/Raw/featureBoth1.csv', row.names = FALSE)
featureBoth1 <- read.csv('Data/Raw/featureBoth1.csv')
featureBoth1 <- dplyr::mutate(featureBoth1, Clas = as.factor(Clas))

feature4 <- getDF('Data/Raw/FeatureMatrices.mat', 'WFM.4', lim = lim)
featurePre4 <- getDF('Data/Raw/FeatureMatrices_pre.mat', 'WFM.4', lim = lim)
featureBoth4 <- rbind(feature4, featurePre4)

write.csv(featureBoth4, file = 'Data/featureBoth4.csv', row.names = FALSE)
featureBoth4 <- read.csv('Data/featureBoth4.csv')
featureBoth4 <- dplyr::mutate(featureBoth4, Clas = as.factor(Clas))

# The following functions create a set of pair plots to visualize patterns
# between the data according to the predicted class.

png(filename = '4.Evaluation/featureBoth1Plot.png', width = 1920, height = 1080)
pairs(featureBoth1[,-length(featureBoth1)], col = featureBoth1$Clas)
dev.off()

png(filename = '4.Evaluation/featureBoth4Plot.png', width = 1920, height = 1080)
pairs(featureBoth4[,-length(featureBoth4)], col = featureBoth4$Clas)
dev.off()