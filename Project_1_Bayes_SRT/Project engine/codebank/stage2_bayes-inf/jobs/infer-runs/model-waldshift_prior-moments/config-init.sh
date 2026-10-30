#!/bash

# PRELIMINARY DEFINITIONS
# =======================

# Generic
# -------
projectdir=$HOME/projects/bayes-srt
respath=$projectdir/code/resources
codepath=$projectdir/code/apparatus
datapath=$projectdir/data
execname=bayesfit-waldshift-mom-sim250

# Job-specific
# ------------
study=sim-study
modeldir=wald_shift
modelprefix=waldshift
dataset=simdata-250
unitname=subject-


# GENERAL INPUT DEFINITIONS
# =========================

# Generic
# -------
libexport=${codepath}/library/*
genutils=${codepath}/general-tools/*
priorutils=${codepath}/matlab-multinest/priors-flat/*

# Job-specific  --  REQUIRED files and information
# ------------
gllfunc=get_loglike_${modelprefix}.m
llfunc=${respath}/bayes-inputs/${modeldir}/loglikes/loglike_srt_${modelprefix}.m
prior=${respath}/bayes-inputs/generic/prior-moments.mat
dataroot=${datapath}/${study}/${dataset}/${unitname}

# Auxiliary  --  files, directories, information for proper code functioning
# ---------
auxpriorfuncs=${respath}/bayes-inputs/${modeldir}/reparam/convert_${modelprefix}.m 
auxmodelfuncs=${codepath}/stat-models/${modeldir}/*
auxmodelutils=${codepath}/stat-models/utils-flat/*

# GENERAL OUTPUT DEFINITIONS
# ==========================

chainsroot=${projectdir}/results/${study}/${dataset}/${model}/${unitname}
