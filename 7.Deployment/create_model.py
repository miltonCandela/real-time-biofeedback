import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import shap

df = pd.read_csv('Data/Processed/RF_MARS_Up.csv')

X = df.drop(df.columns[10], axis = 1)
y = df['Clas'].astype('category')

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.7, random_state = 42)

model = RandomForestClassifier(n_estimators = 175, max_depth = 4000, min_samples_split = 2)
rf = model.fit(X_train, y_train)
prediction = rf.predict(X_test)

from sklearn import metrics
print(metrics.classification_report(y_test, prediction))
print(metrics.confusion_matrix(y_test, prediction))

## SHAP
shap_values = shap.TreeExplainer(rf).shap_values(X_test)[1]
f = shap.summary_plot(shap_values, X_test)

from pickle import dump
nombre = 'model.pkl'
dump(rf, open('model.pkl', 'wb'))