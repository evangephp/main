import pickle
import warnings
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm
import json
import requests
from pandas import Series, DataFrame
import sklearn
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
import sklearn.metrics as metrics
from sklearn.metrics import confusion_matrix
from sklearn.preprocessing import Imputer

# load data frame
# data preprocessing

# please relocate to the correct directory to get the data
df = pd.read_csv('C:/Users/hap01/Desktop/data.csv')
credit = df.copy()
credit.RiskPerformance[credit.RiskPerformance == 'Bad'] = 1
credit.RiskPerformance[credit.RiskPerformance == 'Good'] = 0

# data cleaning
allMissingRows = []
for i in range(len(credit)):
    if (credit.iloc[i, 1:] < 0).all():
        allMissingRows.append(i)

credit = credit.drop(allMissingRows).reset_index(drop=True)

credit.MSinceMostRecentDelq = credit.MSinceMostRecentDelq + 1
credit.MSinceMostRecentInqexcl7days = credit.MSinceMostRecentInqexcl7days + 1
credit.MSinceMostRecentDelq[credit.MSinceMostRecentDelq == -6] = 0
credit.MSinceMostRecentInqexcl7days[credit.MSinceMostRecentInqexcl7days == -6] = 0

dummy1 = pd.get_dummies(credit['MaxDelq2PublicRecLast12M'], prefix='MD2M')
dummy2 = pd.get_dummies(credit['MaxDelqEver'], prefix='MDE')
credit = credit.drop(['MaxDelq2PublicRecLast12M', 'MaxDelqEver'], axis=1)
credit = pd.concat([credit, dummy1, dummy2], axis=1)

credit = credit.mask(credit < 0)
# change all the negative numbers to NaN
imputer = Imputer(strategy='median')
credit_new = pd.DataFrame(imputer.fit_transform(credit))
# use median to impute NaN

credit_new.columns = ['RiskPerformance', 'ExternalRiskEstimate', 'MSinceOldestTradeOpen',
                      'MSinceMostRecentTradeOpen', 'AverageMInFile', 'NumSatisfactoryTrades',
                      'NumTrades60Ever2DerogPubRec', 'NumTrades90Ever2DerogPubRec',
                      'PercentTradesNeverDelq', 'MSinceMostRecentDelq', 'NumTotalTrades',
                      'NumTradesOpeninLast12M', 'PercentInstallTrades',
                      'MSinceMostRecentInqexcl7days', 'NumInqLast6M', 'NumInqLast6Mexcl7days',
                      'NetFractionRevolvingBurden', 'NetFractionInstallBurden',
                      'NumRevolvingTradesWBalance', 'NumInstallTradesWBalance',
                      'NumBank2NatlTradesWHighUtilization', 'PercentTradesWBalance', 'MD2M_0',
                      'MD2M_1', 'MD2M_2', 'MD2M_3', 'MD2M_4', 'MD2M_5', 'MD2M_6', 'MD2M_7',
                      'MD2M_9', 'MDE_2', 'MDE_3', 'MDE_4', 'MDE_5', 'MDE_6', 'MDE_7',
                      'MDE_8']

credit_new.RiskPerformance = credit_new.RiskPerformance.astype('bool', copy=False)

# split train and test value
from sklearn.model_selection import train_test_split

train_set, test_set = train_test_split(credit_new, test_size=0.2, random_state=1)

# train Random Forest model

clf_rf = RandomForestClassifier()
X = train_set.iloc[:, 1:]
Y = train_set.iloc[:, 0]
clf_rf = clf_rf.fit(X, Y)


def bestForest(estimator, param_grid):
    GridSearch_rf = GridSearchCV(estimator=estimator,
                                 param_grid=param_grid,
                                 scoring='accuracy',
                                 cv=10,
                                 return_train_score=True
                                 )
    GridSearch_rf.fit(X, Y)
    best_clf_rf = GridSearch_rf.best_estimator_
    best_clf_rf_train = best_clf_rf.fit(X, Y)
    print('train score:', best_clf_rf_train.score(X, Y))
    return best_clf_rf_train


y_true = test_set.RiskPerformance.astype(int)


def ModelPerformance(y_pred):
    mat = confusion_matrix(y_true, y_pred, labels=[1, 0])
    R = mat[0][0] / (mat[0][0] + mat[1][0])
    P = mat[0][0] / (mat[0][0] + mat[0][1])
    A = (mat[0][0] + mat[1][1]) / (mat[0][0] + mat[0][1] + mat[1][1] + mat[1][0])
    F_1 = 2 * P * R / (P + R)

    fpr, tpr, threshold = metrics.roc_curve(y_true, y_pred)
    roc_auc = metrics.auc(fpr, tpr)

    print("#Confusion Matrix#")
    print("\n", mat)
    print("\nAccuracy: " + str(A))
    print("Recall: " + str(R))
    print("Precision: " + str(P))
    print("F1 Score: " + str(F_1))
    print("AUC: " + str(roc_auc))

    plt.title('Receiver Operating Characteristic')
    plt.plot(fpr, tpr, 'darkorange', label='AUC = %0.2f' % roc_auc)
    plt.legend(loc='lower right')
    plt.plot([0, 1], [0, 1], 'navy', linestyle='--')
    plt.xlim([0, 1])
    plt.ylim([0, 1])
    plt.ylabel('True Positive Rate')
    plt.xlabel('False Positive Rate')
    plt.show()


X_test = test_set.iloc[:, 1:]

best_clf_rf = bestForest(clf_rf, [
    {'n_estimators': [100], 'max_features': [0.1], 'max_depth': [30], 'min_samples_split': [20], 'random_state': [1]}])
y_test = best_clf_rf.predict(X_test)
accuracy = np.mean(sum(test_set.iloc[:, 0] == y_test) / len(y_test))
print('accuracy:', accuracy)
ModelPerformance(y_test)

# prepare the data and pipeline
warnings.filterwarnings('ignore')
pickle.dump(best_clf_rf, open('best_clf_rf.sav', 'wb'))
pickle.dump(X_test, open('X_test.sav', 'wb'))
pickle.dump(y_test, open('y_test.sav', 'wb'))

