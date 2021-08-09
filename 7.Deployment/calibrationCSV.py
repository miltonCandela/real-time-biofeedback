# Author: Milton Candela (https://github.com/milkbacon)
# Date: August 2021

# The following code takes a set of .csv files which comprise the spectral analysis for each signal, these csv files
# are exported as a "Calibration.csv" file, as the values correspond to EO and EC data, used to normalize the data
# that would be provided in real-time, and thus the tree-based ML model would understand that data.

import pandas as pd

folder, category = 'calibra', 'New'
name_Alpha = r'{}\Alpha{}.csv'.format(folder, category)
name_Beta = r'{}\Beta{}.csv'.format(folder, category)
name_Gamma = r'{}\Gamma{}.csv'.format(folder, category)
name_Delta = r'{}\Delta{}.csv'.format(folder, category)
name_Theta = r'{}\Theta{}.csv'.format(folder, category)

# Gamma_C3, Beta_P7, Beta_C4, Theta_O1, Gamma_O1, Delta_O2,
# Gamma_O2, Beta_P8, Theta_C4, Beta_O1, Delta_P8, Gamma_P8

# channels={'FP2','FP1','C4','C3','P8','P7','O1','O2'};
# c_index={ '0',  '1',  '2', '3', '4', '5', '6', '7'};

df_GC3 = pd.read_csv(name_Gamma, usecols=[3])
df_BP7 = pd.read_csv(name_Beta, usecols=[5])
df_BC4 = pd.read_csv(name_Beta, usecols=[2])
df_TO1 = pd.read_csv(name_Theta, usecols=[6])
df_GO1 = pd.read_csv(name_Gamma, usecols=[6])
df_DO2 = pd.read_csv(name_Delta, usecols=[7])

df_GO2 = pd.read_csv(name_Gamma, usecols=[7])
df_BP8 = pd.read_csv(name_Beta, usecols=[4])
df_TC4 = pd.read_csv(name_Theta, usecols=[2])
df_BO1 = pd.read_csv(name_Beta, usecols=[6])
df_DP8 = pd.read_csv(name_Delta, usecols=[4])
df_GP8 = pd.read_csv(name_Gamma, usecols=[4])

# The separate DataFrames are concatenated into a final DataFrame, with a fixed order of columns for our model.
data_df = pd.concat([df_GC3, df_BP7, df_BC4, df_TO1, df_GO1, df_DO2,
                    df_GO2, df_BP8, df_TC4, df_BO1, df_DP8, df_GP8], axis=1)
datadf.columns = ['Gamma_C3', 'Beta_P7', 'Beta_C4', 'Theta_O1', 'Gamma_O1', 'Delta_O2',
                  'Gamma_O2', 'Beta_P8', 'Theta_C4', 'Beta_O1', 'Delta_P8', 'Gamma_P8']
datadf.to_csv(path='CalibrationData.csv', index=False)
