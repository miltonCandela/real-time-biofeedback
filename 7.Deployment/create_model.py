# Author: Milton Candela (https://github.com/milkbacon)
# Date: August 2021

# The following script creates a Machine Learning model based on the EDA analysis done in R, unfortunately, the model
# needs to be trained on Python, since the other IoT devices would be interconnected using Python. And thus an interface
# which uses the same programming language is ideal, the data and parameters would be the same as in the R analysis.

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from shap import TreeExplainer, summary_plot
import matplotlib.pyplot as plt

# The same data is used to train the rf model now in python, the data is divided on the same 80:20 split and the target
# variable is converted into a category type of data.

df = pd.read_csv('Data/Processed/RF_MARS_Up.csv')
X = df.drop('Clas', axis=1)
y = df['Clas'].astype('category')
X_train, X_test, y_train, y_test = train_test_split(X, y, train_size=0.8, random_state=42)

# The rf model is trained using the X_train and y_train, and some of the best parameters are used in python.
rf = RandomForestClassifier(max_features=9, n_estimators=60, max_leaf_nodes=1300).fit(X_train, y_train)
prediction = rf.predict(X_test)

from sklearn import metrics
# Some metrics are imported as sanity checks, in order to validate the effectiveness of the python-trained model.
print(metrics.classification_report(y_test, prediction))
print(metrics.confusion_matrix(y_test, prediction))
print(metrics.accuracy_score(y_test, prediction))

# A SHapley Additive exPlanations summary plot is made, to observe the relation of the source and target variables
shap_values = TreeExplainer(rf).shap_values(X_test)[1]
fig = plt.figure()
summary_plot(shap_values, X_test, show=False)
fig.savefig('fig/SHAP.png', format='png', dpi=150, bbox_inches="tight")

from pickle import dump
# The model is exported into a pickle file, useful for quick importing and to make later predictions on new data.
dump(rf, open('Data/Processed/model.pkl', 'wb'))
