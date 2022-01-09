#!/bin/sh -x
#

SCRIPT=$(realpath "$1")
shift

WORKDIR="/scratch-cbe/users/$LOGNAME/work_${SLURM_JOB_ID:-$$}"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit

SIF="/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmsopendata/cmssw_5_3_32:latest"

# download simulation fragment from release
curl  -s https://raw.githubusercontent.com/cms-sw/genproductions/V01-00-46/python/MinBias_TuneZ2_7TeV_pythia6_cff.py \
      --retry 2 --create-dirs -o  Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py  
[ -s Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py ] || exit $?

# ensure CVMFS ...


singularity run -e "$SIF" "$SCRIPT" "$@" 
