
"""
Encoding-readout alignment.
"""

import numpy as np

from utils import compute_pvalues

#######################################################################################################

pairs_id = ['P100', 'P101', 'P103']
npairs = len(pairs_id)

encbetas = np.load('Results/glm_gam4_betas_enc.npy') # saved encoding weights
readbetas = np.load('Results/glm_4_betas_readkin.npy') # saved (implicit) readout weights

for subj in zip(range(npairs*2), ['B','Y']*npairs, [i for i in range(npairs) for _ in range(2)]):

    isub, color, sp = subj # subject index, subject color, subject pair

    eb, rb = encbetas[isub][:-1], readbetas[isub][1:-3] # isolate weights of kinematic variables (exclude covariates)

    align = (rb*eb/np.linalg.norm(rb, ord=2)/np.linalg.norm(eb, ord=2)).sum() # alignment index

    # Compute null hypothesis distribution for alignment index
    null_al = [align]
    for ip in range(100000):
        rsign = np.random.choice([-1,1], size=16) # randomly switch the sign of the weights
        b1 = np.random.permutation(rb)*rsign # randomly permute the variables
        b2 = eb
        tal = np.sum(b1*b2/np.linalg.norm(b1)/np.linalg.norm(b2))
        null_al.append(tal)
    p_al = compute_pvalues(null_al)
    p_al_above = compute_pvalues(null_al, optsided='one', direction=1)

    print('\n%s%s: %.3f (2-sided: p=%.4f; 1-sided: p=%.4f)'
          %(pairs_id[sp], color, align, p_al, p_al_above))

#######################################################################################################
