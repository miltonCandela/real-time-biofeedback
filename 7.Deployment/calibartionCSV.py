import pandas as pd

folder = 'calibra'
categoria = 'New'

nombreAlpha = folder + '\Alpha' + categoria + '.csv'
nombreBeta = folder + '\Beta' + categoria + '.csv'
nombreGamma = folder + '\Gamma' + categoria + '.csv'
nombreDelta = folder + '\Delta' + categoria + '.csv'
nombreTheta = folder + '\Theta' + categoria + '.csv'
'''
df_AP7 = pd.read_csv(nombreAlpha, usecols = [5])
df_BP8 = pd.read_csv(nombreBeta, usecols = [4])
df_BP7 = pd.read_csv(nombreBeta, usecols = [5])
df_GFP2 = pd.read_csv(nombreGamma, usecols = [0])
df_Gc3 = pd.read_csv(nombreGamma, usecols = [3])
df_GP8 = pd.read_csv(nombreGamma, usecols = [4])
df_GP7 = pd.read_csv(nombreGamma, usecols = [5])
df_DP8 = pd.read_csv(nombreDelta, usecols = [4])
df_TC4 = pd.read_csv(nombreTheta, usecols = [3])
df_TO1 = pd.read_csv(nombreTheta, usecols = [6])
df_TP8 = pd.read_csv(nombreTheta, usecols = [7])
'''

df_B = pd.read_csv(nombreBeta, usecols = [2, 4, 5, 6])
df_T = pd.read_csv(nombreTheta, usecols = [2, 6])
df_G = pd.read_csv(nombreGamma, usecols = [3, 4, 6, 7])
df_D = pd.read_csv(nombreDelta, usecols = [4, 7])

# Generamos CSV en formato:['['Alpha_P7', 'Beta_P7', 'Beta_P8', 'Theta_C4', 'Theta_O1', 'Gamma_C3', 'Gamma_FP2', 'Gamma_P7', 'Delta_P8', 'Gamma_P8']
#channels={'FP2','FP1','C4','C3','P8','P7','O1','O2'};

data = [df_G.iloc[:,0], df_B.iloc[:,2], df_B.iloc[:,0], df_T.iloc[:,1], df_G.iloc[:,3],
        df_B.iloc[:,1], df_T.iloc[:,0], df_B.iloc[:,3], df_D.iloc[:,1], df_G.iloc[:,2],
        df_D.iloc[:,0], df_G.iloc[:,1]]

datadf = pd.concat(data, axis = 1)

columns = ['Gamma_C3', 'Beta_P7', 'Beta_C4', 'Theta_O1', 'Gamma_O1',
           'Beta_P8', 'Theta_C4', 'Beta_O1', 'Delta_O2', 'Gamma_O2',
           'Delta_P8', 'Gamma_P8']

datadf.columns = columns
datadf.to_csv('CalibrationData.csv', index = False)