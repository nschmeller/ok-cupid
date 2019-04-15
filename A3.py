import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter

profiles = pd.read_csv('profiles.csv', low_memory=False)

# Remove unused features
col = list(profiles)
used = ['essay0', 'essay1', 'essay2', 'essay3', 'essay4', 'essay5', 'essay6', 'essay7', 'essay8', 'essay9', 'ethnicity', 'orientation', 'sex']
for i in col:
	if i not in used:
		profiles = profiles.drop(i, axis=1)
# profiles.to_csv('profiles_trim.csv', index=False)

# one-hot encoding for categorical data
categorical_columns = ['ethnicity', 'orientation', 'sex']
profiles_trim_hot = pd.get_dummies(profiles, columns=categorical_columns)

np.unique(profiles_trim_hot.dtypes)

sub_cols = [c for c in profiles_trim_hot.columns.values if 
           (profiles_trim_hot[c].dtype == 'uint8') or
           (profiles_trim_hot[c].dtype == 'int64') or
           (profiles_trim_hot[c].dtype == 'float64')]
profiles_trim_hot = profiles_trim_hot[sub_cols]
profiles_trim_hot.to_csv('profiles_trim_hot.csv', index=False)

# Essays 
essays = profiles[['essay0', 'essay1', 'essay2', 'essay3', 'essay4', 'essay5', 'essay6', 'essay7', 'essay8', 'essay9']]
essays = essays.dropna()

essays['essay0_BOW'] = essays.essay0.apply(lambda x: Counter(x.split(" ")))
essays.to_csv('temp.csv', index=False)

