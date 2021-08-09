# Author: Milton Candela (https://github.com/milkbacon)
# Date: August 2021

# The following code integrates the created model on python, and the calibration DataFrame created from the EO and EC
# initial data collected from the experiment. Here it uses the same DF that was used to train the model, just to
# represent how it could be implemented using an unknown CSV file, the final implementation is on another repo.

from pickle import load
import pandas as pd
import numpy as np
import json

# Both the dummy df and the df_calibration would be extracted, and so the columns are the same for each one,
# with the difference that a "statistics" variable is created with the mean from the df_calibration, model is also
# extracted, the model is created and dumped into a pickle file, using the "create_model.py" script.

columns = ['Gamma_C3', 'Beta_P7', 'Beta_C4', 'Theta_O1', 'Gamma_O1', 'Delta_O2',
           'Gamma_O2', 'Beta_P8', 'Theta_C4', 'Beta_O1', 'Delta_P8', 'Gamma_P8']

df = pd.read_csv('Data/Processed/RF_MARS_Up.csv', dtype='float')
df.columns = columns
extracted_model = load(open('model.pkl', 'rb'))

df_calibration = pd.read_csv('CalibrationData.csv')
df_calibration.columns = columns
statistics = df_calibration.describe().T


def norm(x):
    """
    This function takes a float value from the non-normalized DataFrame, uses the statistics extracted by the
    Calibration.csv file, and normalizes the value with respect to the column on which the value belong to.

    :param float x: Non-normalized value for each column.
    :return float: Normalized value by its mean.
    """

    return (x - statistics['mean']) / statistics['mean']


# The delta_x value corresponds to the window size on which the predictions would be made, on seconds.
delta_x = 60

# The following for loop iterates all over a non-normalized DataFrame, and it normalizes its values using a previously
# created .csv named "CalibrationData.csv", it dumps the predictions on a JSON file named "resp.json".
for i in range(1, len(df.shape[0]/deltax)):
    if ((i + 1) * deltax) > len(df):
        break
    df_temp = df.iloc[(i*deltax):((i+1)*deltax), :]
    df_temp.columns = columns
    df_temp = df_temp.reset_index(drop=True)
    df_temp = norm(df_temp)

    # As combined features are created, the non-used features would be then dumped.
    df_temp['d-g_O2'] = df_temp.Delta_O2 / df_temp.Gamma_O2
    df_temp['d-g_P8'] = df_temp.Delta_P8 / df_temp.Gamma_P8
    df_temp.drop(columns=['Delta_O2', 'Gamma_O2', 'Delta_P8', 'Gamma_P8'], inplace=True)

    prediction = extracted_model.predict(df_temp)

    cants = np.array([prediction[prediction == 1].sum(),
                      prediction[prediction == 2].sum(),
                      prediction[prediction == 3].sum()])

    # If the "data" variable is not yet initialized, it is then created, otherwise, the new data is inserted.
    if i == 1:
        data = [{'Time': 1, 'Prediction': int(cants.argmax() + 1),
                 'Prob1': (cants[0]/cants.sum())*100,
                 'Prob2': (cants[1]/cants.sum())*100,
                 'Prob3': (cants[2]/cants.sum())*100}]
    else:
        data.insert(len(data), {'Time': i, 'Prediction':  int(cants.argmax() + 1),
                                'Prob1': (cants[0]/cants.sum())*100,
                                'Prob2': (cants[1]/cants.sum())*100,
                                'Prob3': (cants[2]/cants.sum())*100})

    # The results are dumped into a JSON file with a time-related variable, in this case corresponds to the for-loop.
    with open("resp.json", 'w') as json_file:
        dumped_data = json.dumps(data, indent=4, sort_keys=True, separators=(',', ': '))
        json_file.write(dumped_data)
