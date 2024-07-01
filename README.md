The dataset used for this analysis is the Cleveland Heart Disease dataset from the UCI repository. The goal is to classify whether an individual has heart disease (1) or not (0). By applying logistic regression to the top three features most strongly associated with heart disease, I achieved an accuracy of 83%.

## The Data

Source: Datacamp

| Column     | Type | Description              |
|------------|------|--------------------------|
|`age` | continuous | age in years | 
|`sex` | discrete | 0=female 1=male |
|`cp`| discrete | chest pain type: 1=typical angina, 2=atypical angina, 3=non-anginal pain, 4=asymptom |
|`trestbps`| continuous | resting blood pressure (in mm Hg) |
|`chol`| continuous | serum cholesterol in mg/dl |
|`fbs`| discrete | fasting blood sugar>120 mg/dl: 1=true 0=False |
|`restecg`| discrete | result of electrocardiogram while at rest are represented in 3 distinct values 0=Normal 1=having ST-T wave abnormality (T wave inversions and/or ST elevation or depression of > 0.05 mV) 2=showing probable or definite left ventricular hypertrophy Estes' criteria (Nominal) |
|`thalach`| continuous | maximum heart rate achieved |
|`exang`| discrete | exercise induced angina: 1=yes 0=no |
|`oldpeak`| continuous | depression induced by exercise relative to rest |
|`slope`| discrete | the slope of the peak exercise segment: 1=up sloping 2=flat, 3=down sloping
|`ca`| continuous | number of major vessels colored by fluoroscopy that ranged between 0 and 3 |
|`thal`| discrete | 3=normal 6=fixed defect 7=reversible defect |
|`class`| discrete | diagnosis classes: 0=no presence 1=minor indicators for heart disease 2=>1 3=>2 4=major indicators for heart disease|
