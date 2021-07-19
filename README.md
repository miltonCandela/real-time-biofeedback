## Overview
The Advanced Learner Assistance System (ALAS) architecture is composed by a set of modules, the current GitHub repository contains scripts used by the Machine Learning module. The repository in question is organized as a set of milestones that led to the final model, which predicted a 3-level mental fatigue with a 92.25% accuracy using EEG features, obtained developing a spectral analysis from a 8-channel OpenBCI helmet.

## Data
The raw data used was drawn from the following IEEE database: [EEG and Empatica E4 Signals - Five Minute P300 Test and FAS Scores](https://ieee-dataport.org/documents/eeg-and-empatica-e4-signals-five-minute-p300-test-and-fas-scores), which obtained EEG signals and related it to mental fatigue via the Fatigue Assessment Scale (FAS).

Features included in the dataset:
- Spectral analysis: 40
- Ratios: 80
- Empatica E4: 9
- FAS Class: 1

The raw data was in matrices in the default MATLAB's extension (.mat), and thus was converted to Comma-Separated Values (CSV), useful for Data Frame creation using R. Both the raw and processed data have their respective sub-folders inside the main "Data" folder.

## Analysis
The analysis was developed using 70:30, 75:25 and 80:20 splits of the training and testing dataset, incremental cross-validations that from two to five, as well as various feature-selection techniques. The objective of the analysis was developing a categorical, parsimonious, and balanced model which predicted, in real time, a person's fatigue level using solely their EEG signals as a reliable, biometric measure.

As a multiclass-classification problem, a set of tree-based and non-tree-based Machine Learning core algorithms were used, such as the following:
- Random Forest (RF)
- Support Vector Machine (SVM)
- Generalized Boosted Modeling (GBM)
- Classification and Regression Trees (CART)
- Linear Discriminant Analysis (LDA)

## Contents
Each folder has a milestone report (rendered into HTML or PDF format) and a variety of R scripts inside, it is represented as an ordered list because it was a sequential order of discoveries that lead to the final features and reliable model. Although the scripts can be visualized via the folders, the following ordered list contains a hyperlink to each module's milestone report already rendered into HTML:
1. [Exploration](https://htmlpreview.github.io/?https://github.com/milkbacon/ALAS-ML/blob/main/1.Exploration/index.html)
2. [Feature Selection](https://htmlpreview.github.io/?https://github.com/milkbacon/ALAS-ML/blob/main/2.Feature_Selection/index.html)
3. [Fitting](https://htmlpreview.github.io/?https://github.com/milkbacon/ALAS-ML/blob/main/3.Fitting/index.html)

## Results
As a result of multiple testing, the final models’ average correct classification percentage, on a balanced dataset using Up-Sampling and a 5-fold stratified cross-validation (CV), was the following: Random Forest (RF) was superior (92.25%), followed by radial-kernel Support Vector Machine (SVM) (80.85%) and Generalized Boosted Modeling (GBM) (79.49%), lastly, Classification and Regression Trees (CART) (57.86%) and Linear Discriminant Analysis (LDA) (53.53%).

The final model was fitted using both *FeatureMatrices.mat* and *FeatureMtrices_pre.mat* into a filtered dataset, in order to remove outliers, a hard-coded filter of threshold 10 was implemented, in so that all the values trained by the model resided into -10 and +10. That prospective was taken due to the fact that the data was already standardized using its mean, and so values that were that big are due to an error from the biometric device, and so it is inappropriate to train the model using that noisy data.
![confMat](https://github.com/milkbacon/ALAS-ML/blob/main/fig/confMat.png)

## Insights
Interesting insights were drawn on the final model (RF), since its a tree-based model, its hard to draw explanations or insights about the data it was used and how it accurately predicted the 3-class fatigue level. Although, there are some methods that compute the contribution of each feature to the final prediction, the one used is called SHapley Additive exPlanations (SHAP), more specifically, _TreeSHAP_ for tree-based models.

The analysis revealed that high values of features from P7 and P8 channels were correlated with low levels of mental fatigue, in contrast to the C4 channel, in which high values of _Gamma_ C4 were correlated with lower levels of mental fatigue.
![SHAP](https://github.com/milkbacon/ALAS-ML/blob/main/fig/SHAP.png)

On the other hand, *FeatureMatrices_post.mat* did not had classes, and so the final model predicted the classes based on the biometric signals gathered. The results are displayed on the following plot, which represents the prevalence of fatigue classes and how the predominant class changed from _No Fatigue_ to _Moderate Fatigue_. This represents an additional validation to the model, because the data the subject passed a test which provoke him fatigue, and thus it reasonable that its mental fatigue increased due to the fact that the test provoke him an additional mental burden.
![barPrePos](https://github.com/milkbacon/ALAS-ML/blob/main/fig/barPrePos.png)
