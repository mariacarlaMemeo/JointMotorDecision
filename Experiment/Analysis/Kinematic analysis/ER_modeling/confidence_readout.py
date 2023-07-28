
"""
Training and evaluation of confidence readout model.
"""

from pyglmnet import GLMCV

import copy
import numpy as np
import math
import pandas as pd

import matplotlib
import matplotlib.pyplot as plt
from matplotlib import colors as mcolors
matplotlib.rcParams.update({'font.size': 20, 'font.sans-serif' : 'Arial'})

import os

from utils import compute_pvalues

#######################################################################################################
# OPTIONS

# Dataset
timebins = 4 # [can range from 1 to 100] kinematics is averaged over chunks of (100/timebins)% of the movement
kinfeat = range(3,7) # which kinematic variables to use:
                     # 0:'IV', 1:'IA', 2:'IJ',
                     # 3:'UV', 4:'UA', 5:'UJ', 6:'UH'
                     # For IMPLICIT READOUT (w/ kinematics), specify a set of indices of kinematic variables;
                     # For EXPLICIT READOUT (w/ confidence), set kinfeat=None.

disagree_trials = True # whether to restrict the model to disagreement trials

include_contrast = True # whether to include contrast
include_accuracy = True # whether to include accuracy
include_dt = True # whether to include deliberation time

# Model and training
alpha = 0. # sparsity coefficient in elastic net regularization
lambdas = np.logspace(math.log(.1), 0, num=10, base=math.e)[::-1] # values of L2 regularization coefficient
                                                                  # (spaced logarithmically)

# Statistics
permtest = False # permutation test
num_perms = 500 # number of random permutations for permtest
cv = False # cross-validation (CV)
kcv = 5 # number of CV folds
ncv = 50 # number of CV repetitions


#######################################################################################################
# SETUP

for dir in ('Results', 'permtest_data', 'figures'): # create directories where to store results
    if not os.path.exists(dir):
       os.makedirs(dir)

# names
feat_names = ['IV', 'IA', 'IJ', 'UV', 'UA', 'UJ', 'UH']
conf_names = ['low', 'high']
pairs_id = ['P100', 'P101', 'P103']

model_prefix = 'glm_'+str(timebins)

if kinfeat is not None:
    feat_names = [feat_names[fe] for fe in kinfeat]
    Nf = len(kinfeat) # number of selected kinematic variables
totfeat = 7 # total number of kinematic variables

nperms = num_perms if permtest else 0


#######################################################################################################
# Load and prepare data

print('\n%d-bin DATASET\n' %(timebins))

npairs = len(pairs_id)
print('Loading data...')
data = [pd.read_excel(os.path.join('..', 'DATA', 'jointdm_data', 'pilotData_kin_model_new.xlsx'),
                      sheet_name=pairs_id[sp]).drop(columns=['rt_final1', 'rt_final2', 'rt_finalColl',
                        'dt_final1', 'dt_finalColl', 'mt_final1', 'mt_final2', 'mt_finalColl',
                        'tstart1', 'tmove1', 'tstop1', 'tstart2', 'tmove2', 'tstop2', 'tstartColl',
                        'tmoveColl', 'tstopColl'] + ([] if include_dt else ['dt_final2'])).dropna()
        for sp in range(npairs)]

print('Done!')

#######################################################################################################
# TRAIN READOUT MODELS

# Define the classifier
clf = GLMCV(distr='binomial', alpha=alpha, reg_lambda=lambdas)

if cv:
    trial_acc = [[] for _ in range(npairs*2)] # to be filled with single-trial accuracies on each fold
    fold_ind = [[] for _ in range(npairs*2)] # to be filled with video indices for each fold for each subject
    cvpreds = [[] for _ in range(npairs*2)] # to be filled with predictions for each fold for each subject
else:
    trainperf = [] # to be filled with training accuracy
    trainpreds = [] # to be filled with single-trial predictions
    trainprobs = [] # to be filled with single-trial classification probabilities
    readbetas = [] # to be filled with model coefficients

if permtest:
    permacc = [[] for _ in range(npairs*2)] # to be filled with model accuracies on permuted data
    permbetas = [[] for _ in range(npairs*2)] # to be filled with model coefficients on permuted data

ratios, nsample_all = [],[]


for iperm in range(nperms+1):

    if permtest:
        print('========= Permutation #%d/%d %s========='
              %(iperm,nperms,'(non-permuted data) ' if iperm==0 else ''))

    if iperm>0 and ncv>5:
        ncv = 5

    for subj in zip(range(npairs*2), ['B','Y']*npairs, [i for i in range(npairs) for _ in range(2)]):

        cvpreds = []

        isub, color, sp = subj # subject index, subject color, subject pair
        other_color = 'Y' if color=='B' else 'B'

        # Extract kinematic variables and targets from dataframe
        data_subj = data[sp]
        conf1_all = data_subj[other_color+'_conf'].to_numpy()
        dec2 = data_subj['AgentTakingSecondDecision'].to_numpy()
        if disagree_trials:
            disagree = (data_subj['B_decision']!=data_subj['Y_decision']).to_numpy()
            valid = (dec2==color) & disagree
        else:
            valid = dec2==color
        conf1 = conf1_all[valid]
        covariates = []
        if include_accuracy:
            acc1_all = data_subj[other_color+'_acc'].to_numpy()
            acc1 = acc1_all[valid]
            covariates.append(acc1.reshape(-1,1))
        if include_contrast:
            contrast_all = data_subj['targetContrast'].to_numpy()
            contr = contrast_all[valid]
            covariates.append(contr.reshape(-1,1))
        if include_dt:
            dt_all = data_subj['dt_final2'].to_numpy()
            dt = dt_all[valid]
            covariates.append(dt.reshape(-1,1))
        target = data_subj['Switch'].to_numpy()[valid]

        if kinfeat is not None:
            kindata = data_subj[valid].iloc[:,20+include_dt:20+include_dt+100*totfeat].to_numpy()
            # Downsample over time bins
            kindata = kindata.reshape((-1,totfeat,100))
            nRshp = 100//timebins
            kindata = kindata.reshape((-1,totfeat,timebins,nRshp)).mean(axis=3)
            # Select the desired subset of kinematic features
            kindata = kindata[:, kinfeat, 0:timebins]
            # Flatten kinematic data
            kindata = kindata.reshape(-1,Nf*timebins)
            # Concatenate with covariates
            traindata = np.concatenate([conf1.reshape(-1,1), kindata] + covariates, axis=1)
        else:
            conf2_all = data_subj[color+'_conf'].to_numpy()
            conf2 = conf2_all[valid]
            # Concatenate with covariates
            traindata = np.concatenate([conf1.reshape(-1,1), conf2.reshape(-1,1)] + covariates, axis=1)


        nsample = len(target)

        if permtest and (iperm > 0):
            permidx = np.random.permutation(np.arange(nsample))
            target = target[permidx]

        ind0 = np.where(target==0)[0] # indices of class 0
        ind1 = np.where(target==1)[0] # indices of class 1

        ratio = len(ind1)/nsample # fraction of class 1 responses
        ratios.append(ratio)
        nsample_all.append(nsample)

        if cv: # set up cv folds

            foldsize = math.ceil(nsample/kcv)
            fractions = [i/foldsize for i in range(foldsize+1)]

            fold1 = min(max(1, (np.abs(np.array(fractions) - ratio)).argmin()), foldsize-1) # number of class 1 samples in CV fold
            nfolds = min(math.floor(len(ind0)/(foldsize-fold1)), math.floor(len(ind1)/fold1))
            cvfolds = []
            i = 0
            for n in range(ncv):
                    shuffled0 = np.random.permutation(ind0)
                    shuffled1 = np.random.permutation(ind1)
                    for f in range(nfolds):
                        cvfolds.append(list(shuffled0[(foldsize-fold1)*f:(foldsize-fold1)*(f+1)])\
                                  + list(shuffled1[fold1*f:fold1*(f+1)]))
                        # (balancing the two classes in each fold as they are in the whole dataset)
                    if (foldsize-fold1)*(f+1)<len(shuffled0) or fold1*(f+1)<len(ind1): # last fold
                        cvfolds.append(list(shuffled0[(foldsize-fold1)*(f+1):])\
                                      + list(shuffled1[fold1*(f+1):]))
                        nfolds += 1 if n==ncv-1 else 0
            fr = fractions[fold1]
            cv_chance = max(fr,1-fr)
            fold_ind[isub].append(cvfolds)

        print('\n%s model: %d TIME BINS data --- %s subject of pair #%d/%d (ID %s)\n'
              %('Explicit' if kinfeat is None else 'Implicit', timebins,color,sp+1,npairs,pairs_id[sp])
              + ('' if not permtest else ' (perm#%d)' %iperm))

        ntrials = nfolds*ncv if cv else 1

        # Cross validation (if enabled)
        # -----------------------------

        cvperf = []

        for trial in range(ntrials):

            train_idx = np.arange(nsample)

            if cv:
                cv_idx = cvfolds[trial]
                train_idx = np.delete(train_idx, cv_idx)
                Xcv, Ycv = traindata[cv_idx,:], target[cv_idx] # test-data for the current fold

            Xtrain, Ytrain = traindata[train_idx,:], target[train_idx] # train-data for the current fold

            dmean = Xtrain.mean(0, keepdims=True)
            dstd = Xtrain.std(0, keepdims=True)

            Xtrain = (Xtrain - dmean)/dstd # z-score kinematic data wrt training mean and std

            if cv:
                print('\n%d TIME BINS data --- %s subject of pair #%d/%d (ID %s) --- FOLD #%d'
                      %(timebins,color,sp+1,npairs,pairs_id[sp],trial+1)
                      + ('' if not permtest else ' (perm#%d)' %iperm))

            # Fit the classifier
            clf.fit(Xtrain, Ytrain)

            # Performance on training set
            trpreds = clf.predict(Xtrain)
            temp_acc = np.mean(trpreds==Ytrain)
            trprobs = clf.predict_proba(Xtrain)
            predratio = np.mean(trpreds)


            print('Finished Training' + (' for fold #%d' %(trial+1) if cv else ''))


            if cv:
                # Evaluate the classifier on testing data of the current fold:
                Xcv = (Xcv - dmean)/dstd  # z-score kinematic data wrt training mean and std
                preds = clf.predict(Xcv)
                cvpreds = cvpreds + list(preds)
                tempacc = np.mean(preds==Ycv)
                cvperf.append(tempacc)
                print('Evaluation on out-of-sample elements: %.3f' %(tempacc))
                print('Mean accuracy until now = %.3f (theoretical chance level: %.3f)\n'
                      %(np.mean(cvperf), max(ratio, 1-ratio)))
                trial_acc[isub].append(preds==Ycv)
            else:
                betas = clf.beta_ # linear coefficients of the model
                if iperm==0:
                    trainperf.append(temp_acc)
                    trainpreds.append(trpreds)
                    trainprobs.append(trprobs)
                    readbetas.append(betas)


        if permtest and cv:
            permacc[isub].append(np.mean(cvperf))
        elif permtest and not cv:
            permacc[isub].append(temp_acc)
            permbetas[isub].append(betas)


    if iperm==0 and not cv:
        np.save(os.path.join('Results', '%s_betas_read%s%s' %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all')), readbetas)
        np.save(os.path.join('Results', '%s_read_trainperf%s%s' %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all')), trainperf)
        np.save(os.path.join('Results', '%s_read_trainpreds%s%s' %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all')), trainpreds)
        np.save(os.path.join( 'Results', '%s_read_trainprobs%s%s' %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all')), trainprobs)


    if permtest and iperm!=0 and not iperm%100: # save every 100 permutations
        if cv:
            np.save(os.path.join('permtest_data', '%s_read%s%s_permacc[cv%dx%d]_%dperms'
                    %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all',kcv,ncv,iperm)), permacc)
        else:
            np.save(os.path.join('permtest_data', '%s_read%s%s_permbetas_%dperms'
                %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all',iperm)), permbetas)


    if cv and (iperm==0):
        np.save(os.path.join('Results', '%s_read%s%s_trialacc[cv%dx%d]'
                %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all',kcv,ncv)), trial_acc)
        np.save(os.path.join('Results', '%s_read%s%s_cvfolds[cv%dx%d]'
                %(model_prefix,
                'conf' if kinfeat is None else 'kin', '' if disagree_trials else '_all',kcv,ncv)), fold_ind)

#######################################################################################################
# Results


print('\n%d TIME BINS data\n' %(timebins))

chance = np.maximum(ratios, [1-x for x in ratios])

cov_names =[]
if include_accuracy:
    cov_names = cov_names + ['acc1']
if include_contrast:
    cov_names = cov_names + ['contrast']
if include_dt:
    cov_names = cov_names + ['dt']

# Model performance
print('%s accuracy' %('cross-validated' if cv else 'training'))
accs, accs_sem = [], []
for subj in zip(range(npairs*2), ['B','Y']*npairs, [i for i in range(npairs) for _ in range(2)]):
    isub, color, sp = subj
    if cv:
        foldacc = [np.mean(trial_acc[isub][fold]) for fold in range(len(trial_acc[isub]))]
        print('%s subject of pair %s: %.3f+-%.3f (%d trials, chance=%.3f)'
         %(color,pairs_id[sp],np.mean(foldacc),np.std(foldacc), nsample_all[isub], chance[isub]))
        accs.append(np.mean(foldacc))
        accs_sem.append(np.std(foldacc)/math.sqrt(len(foldacc)))
    else:
        print('%s subject of pair %s: %.3f (%d trials, chance=%.3f)'
         %(color,pairs_id[sp],trainperf[isub], nsample_all[isub], chance[isub]))
        accs.append(trainperf[isub])
if cv: # visualize cross-validated model performance
    f = plt.figure()
    plt.bar(np.arange(npairs*2), accs)
    plt.bar(np.arange(npairs*2), chance, color='w', alpha=.5)
    plt.errorbar(np.arange(npairs*2), accs, accs_sem,
                 linestyle='none', c='k')
    plt.xticks(np.arange(npairs*2), ['B','Y']*npairs)
    plt.xlabel((' '*11).join(pairs_id))
    plt.ylim([.5,1])
    plt.ylabel('%s accuracy' %('CV' if cv else 'training'))
    f.savefig('figures/%s_read%s%s_accs%s.pdf'
              %(model_prefix, 'conf' if kinfeat is None else 'kin',
                '' if disagree_trials else '_all', '[cv%dx%d]' %(kcv,ncv) if cv else ''),
                          bbox_inches='tight')
elif kinfeat is not None: # plot model weights for implicit readout
    vmin = .25
    vmax = .65
    colors = plt.cm.Greys(np.linspace(vmin, vmax, timebins))
    color_map = matplotlib.colors.LinearSegmentedColormap.from_list('cut_map', colors) # new colormap from those colors
    norm = mcolors.Normalize(vmin=vmin, vmax=vmax)
    f = plt.figure(figsize=(8,10))
    for subj in zip(range(npairs*2), ['B','Y']*npairs, [i for i in range(npairs) for _ in range(2)]):
        isub, color, sp = subj
        encbetas = readbetas[isub][1:1+Nf*timebins].reshape(-1,timebins)
        encind = np.argsort(np.abs(encbetas).sum(axis=1))[::-1] #range(17) #
        coef_sorted = np.array([encbetas[ii,:] for ii in encind])
        names_sorted = [feat_names[ii] for ii in encind]

        ax = plt.subplot(npairs,2,isub+1)
        bottomp, bottomn = 0, 0
        for tt in range(timebins):
            coefp = coef_sorted[:,tt]*(coef_sorted[:,tt]>0)
            coefn = coef_sorted[:,tt]*(coef_sorted[:,tt]<0)
            plt.bar(np.arange(Nf), coefp, bottom=bottomp,
                    color=colors[tt], width=.5)
            plt.bar(np.arange(Nf), coefn, bottom=bottomn,
                    color=colors[tt], width=.5)
            bottomp += coefp
            bottomn += coefn
        plt.bar([-1], [readbetas[isub][0]], color='darksalmon', width=.5)
        if include_accuracy or include_contrast or include_dt:
            plt.bar(np.arange(Nf,Nf+len(cov_names)),
                    readbetas[isub][Nf*timebins+1:], color='tab:blue', width=.5)
        plt.axhline(0, c='k', linewidth=1)
        plt.xticks(np.arange(-1,Nf+len(cov_names)), ['conf1']+names_sorted+cov_names, rotation='vertical')
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        plt.title('%s%s' %(pairs_id[sp],color))
    plt.subplots_adjust(wspace=.5, hspace=.7)
    f.savefig('figures/%s_readkin%s_betas.pdf' %(model_prefix, '' if disagree_trials else '_all'),
                          bbox_inches='tight')
else: # plot model weights for explicit readout
    f = plt.figure(figsize=(8,10))
    for subj in zip(range(npairs*2), ['B','Y']*npairs, [i for i in range(npairs) for _ in range(2)]):
        isub, color, sp = subj
        ax = plt.subplot(npairs,2,isub+1)
        plt.bar(np.arange(len(readbetas[isub])), readbetas[isub],
                color=['darksalmon','lightgray']+['tab:blue']*len(cov_names))
        plt.axhline(0, c='k', linewidth=1)
        plt.xticks(np.arange(len(readbetas[isub])), ['conf1', 'conf2'] + cov_names, rotation='vertical')
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        plt.title('%s%s' %(pairs_id[sp],color))
    plt.subplots_adjust(wspace=.5, hspace=.9)
    f.savefig('figures/%s_readconf%s_betas.pdf' %(model_prefix, '' if disagree_trials else '_all'),
                          bbox_inches='tight')

if permtest: # check which subjects had significant readout according to permutation test
    pvalues_acc = [compute_pvalues(permacc[isub], optsided='one', direction=1) for isub in range(npairs*2)]
    print('p<.05 for subject #: '
          + ', '.join([isub for isub in range(npairs*2) if pvalues_acc[isub]<.05])
          +'\n')
