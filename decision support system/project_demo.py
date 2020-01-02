import streamlit as st
import pickle
import numpy as np
from sklearn import metrics

# Load the pipeline and data
# pipe = pickle.load(open('pipe_logistic.sav', 'rb'))
X_test = pickle.load(open('X_test.sav', 'rb'))
y_test = pickle.load(open('y_test.sav', 'rb'))

dic = {0: 'Bad', 1: 'Good'}


# Function to test certain index of dataset
def test_demo(index):
    values = X_test.iloc[index, :]  # Input the value from dataset

    # Create four sliders in the sidebar
    a = st.sidebar.slider('ExternalRiskEstimate', 0.0, 100.0, values[0], 1.0)
    b = st.sidebar.text_input('MSinceOldestTradeOpen:', values[1], 0)
    c = st.sidebar.text_input('MSinceMostRecentTradeOpen:', values[2], 0)
    d = st.sidebar.text_input('AverageMInFile:', values[3], 0)
    e = st.sidebar.text_input('NumSatisfactoryTrades:', values[4], 0)
    f = st.sidebar.text_input('NumTrades60Ever2DerogPubRec:', values[5], 0)
    g = st.sidebar.text_input('NumTrades90Ever2DerogPubRec:', values[6], 0)
    h = st.sidebar.slider('PercentTradesNeverDelq', 0.0, 100.0, values[7], 0.01)
    i = st.sidebar.text_input('MSinceMostRecentDelq:', values[8], 0)
    l = st.sidebar.text_input('NumTotalTrades:', values[9], 0)
    m = st.sidebar.text_input('NumTradesOpeninLast12M:', values[10], 0)
    n = st.sidebar.slider('PercentInstallTrades', 0.0, 100.0, values[11], 0.01)
    o = st.sidebar.text_input('MSinceMostRecentInqexcl7days:', values[12], 0)
    p = st.sidebar.text_input('NumInqLast6M:', values[13], 0)
    q = st.sidebar.text_input('NumInqLast6Mexcl7days:', values[14], 0)
    r = st.sidebar.text_input('NetFractionRevolvingBurden:', values[15], 0)
    s = st.sidebar.text_input('NetFractionInstallBurden:', values[16], 0)
    t = st.sidebar.text_input('NumRevolvingTradesWBalance:', values[17], 0)
    u = st.sidebar.text_input('NumInstallTradesWBalance:', values[18], 0)
    v = st.sidebar.text_input('NumBank2NatlTradesWHighUtilization:', values[19], 0)
    w = st.sidebar.text_input('PercentTradesWBalance:', values[20], 0)
    j0 = st.sidebar.text_input('MD2M_0:', values[21], 0)
    j1 = st.sidebar.text_input('MD2M_1:', values[22], 0)
    j2 = st.sidebar.text_input('MD2M_2:', values[23], 0)
    j3 = st.sidebar.text_input('MD2M_3:', values[24], 0)
    j4 = st.sidebar.text_input('MD2M_4:', values[25], 0)
    j5 = st.sidebar.text_input('MD2M_5:', values[26], 0)
    j6 = st.sidebar.text_input('MD2M_6:', values[27], 0)
    j7 = st.sidebar.text_input('MD2M_7:', values[28], 0)
    j9 = st.sidebar.text_input('MD2M_9:', values[29], 0)
    k2 = st.sidebar.text_input('MDE_2:', values[30], 0)
    k3 = st.sidebar.text_input('MDE_3:', values[31], 0)
    k4 = st.sidebar.text_input('MDE_4:', values[32], 0)
    k5 = st.sidebar.text_input('MDE_5:', values[33], 0)
    k6 = st.sidebar.text_input('MDE_6:', values[34], 0)
    k7 = st.sidebar.text_input('MDE_7:', values[35], 0)
    k8 = st.sidebar.text_input('MDE_8:', values[36], 0)

    vars = [a, b, c, d, e, f, g, h, i, l, m, n, o, p, q, r, s, t, u, v, w, j0, j1, j2, j3, j4, j5, j6, j7, j9, k2,
            k3, k4, k5, k6, k7, k8]

    x = np.array(vars).reshape(1, -1)

    pipe = pickle.load(open('best_clf_rf.sav', 'rb'))
    res = pipe.predict(x)[0]
    st.write('Prediction:  ', dic[res])


# title
st.title('Credit Card Application Decision Support System')
# show data
if st.checkbox('Show dataframe'):
    st.write(X_test)
# st.write(X_train) # Show the dataset

number = st.text_input('Choose sample from dataset (0 - 1974):', 0)  # Input the index number

test_demo(int(number))  # Run the test function

# PLEASE READ #
# in order to run the interface, please open the anaconda prompt or other console,
# locate to this folder, and type in the following (without the #)
# streamlit run project_demo.py
