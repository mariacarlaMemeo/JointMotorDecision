
"""
Tools and settings.
"""

import numpy as np

#######################################################################################################

def compute_pvalues(seq, dmean=None, optsided='two', direction=None):
    """
    seq = sequence of outputs (nPerms+1 x nOut)
          seq[0,:] = original values
          seq[1:,:] = values from permuted input
    dmean = distribution mean
    optsided = 'one' for one-sided, 'two' for two-sided
    direction = 1 or -1, for one-sided case
    """

    seq = np.array(seq)
    if len(seq.shape)==1:
        seq = np.expand_dims(seq,1)
    if dmean==None:
        dmean = np.mean(seq[1:,:], axis=0)
    seq -= dmean
    nPerms = seq.shape[0] - 1
    nOut = seq.shape[1]
    if optsided=='one':
        pvalues = np.zeros(nOut)
        for iOut in range(nOut):
            one_sided_direction = np.sign(seq[0,iOut]) if direction==None else direction
            if one_sided_direction > 0:
                pvalues[iOut] = np.sum(seq[1:,iOut] >= seq[0,iOut])/nPerms
            else:
                pvalues[iOut] = np.sum(seq[1:,iOut] <= seq[0,iOut])/nPerms
    elif optsided=='two':
        pvalues = np.sum(np.abs(seq[1:,:]) >= np.abs(seq[0,:]), 0)/nPerms
    else:
        print('Invalid optsided value (must be either \'one\' or \'two\')')

    return pvalues


#######################################################################################################
