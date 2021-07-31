from pickle import load
import pandas as pd
import numpy as np
import json

columns = ['Gamma_C3', 'Beta_P7', 'Beta_C4', 'Theta_O1', 'Gamma_O1',
           'Beta_P8', 'Theta_C4', 'Beta_O1', 'Delta_O2', 'Gamma_O2',
           'Delta_P8', 'Gamma_P8']

df_verd = pd.read_csv('Data/Processed/RF_MARS_Up.csv', dtype = 'float')
extracted_model = load(open('model.pkl', 'rb'))

df_calib = pd.read_csv('CalibrationData.csv')
df_calib.columns = columns
estadisticas = df_calib.describe().T

def norm(x):
    return ((x - estadisticas['mean']) / estadisticas['mean'])

delta_x = 60

for i in range(1, len(df_verd/deltax)):
    if ((i + 1) * deltax) > len(df_verd):
        break
    df = df_verd.iloc[(i*deltax):((i+1)*deltax),:]
    df.columns = columns
    df = df.reset_index(drop = True)
    df = norm(df)
    
    df['d-g_O2'] = df.Delta_O2 / df.Gamma_O2
    df['d-g_P8'] = df.Delta_P8 / df.Gamma_P8
    df.drop(columns = ['Delta_O2', 'Gamma_O2','Delta_P8', 'Gamma_P8'], inplace = True)

    prediction = extracted_model.predict(df)

    cants = np.array([prediction[prediction == 1].sum(),
                      prediction[prediction == 2].sum(),
                      prediction[prediction == 3].sum()])
    print(cants)

    if(i == 1):
        data = [{'Time': 1, 'Pred': int(cants.argmax() + 1),
                 'Prob1': (cants[0]/cants.sum())*100,
                 'Prob2': (cants[1]/cants.sum())*100,
                 'Prob3': (cants[2]/cants.sum())*100}]

        with open("resp.json", 'w') as jsonfile:
            datos = json.dumps(data, indent=4, sort_keys=True, separators=(',', ': '))
            jsonfile.write(datos)
    else:
        data.insert(len(data), {'Time': i, 'Pred':  int(cants.argmax() + 1),
                                'Prob1': (cants[0]/cants.sum())*100,
                                'Prob2': (cants[1]/cants.sum())*100,
                                'Prob3': (cants[2]/cants.sum())*100})
        with open('resp.json', 'w') as jsonfile :
            datos = json.dumps(data, indent = 4, sort_keys = True, separators = (',', ': '))
            jsonfile.write(datos)