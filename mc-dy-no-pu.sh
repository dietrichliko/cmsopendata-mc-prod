#!/bin/sh -x
#
# Run simulation in cmsopendata ebvironment
#
# Follows https://github.com/dietrichliko/EventProductionExamplesTool


patch_global_tag() {
    sed -f - -i "$1" <<SED_SCRIPT
/^process.GlobalTag = /a process.GlobalTag.connect = cms.string('sqlite_file:/cvmfs/cms-opendata-conddb.cern.ch/START53_LV6A1.db')
/^process.GlobalTag = /a process.GlobalTag.globaltag = 'START53_LV6A1::All'
/^process.GlobalTag = /d
SED_SCRIPT
}

events=100

ln -sf /cvmfs/cms-opendata-conddb.cern.ch/START53_LV6A1 START53_LV6A1
ln -sf /cvmfs/cms-opendata-conddb.cern.ch/START53_LV6A1.db START53_LV6A1.db

# GEN-SIM

cmsDriver.py DYToLL_M_50_TuneZ2_7TeV_pythia6_tauola_cff.py \
    --mc --no_exec \
    --eventcontent RAWSIM \
    --datatier GEN-SIM \
    --conditions START53_LV6A1::All \
    --step GEN,SIM \
    --python_filename gensimDY.py \
    --number $events \
    --fileout gensimDY.root

patch_global_tag gensimDY.py
cmsRun gensimDY.py

# HLT

cmsDriver.py step1 \
    --mc --no_exec \
    --step DIGI,L1,DIGI2RAW,HLT:2011 \
    --datatier GEN-RAW \
    --conditions=START53_LV6A1::All \
    --eventcontent RAWSIM \
    --python_filename hltDY.py \
    --number $events \
    --filein file:gensimDY.root \
    --fileout hltDY.root 

patch_global_tag hltDY.py
cmsRun hltDY.py

# RECO

cmsDriver.py step2 \
    --mc --no_exec \
    --step RAW2DIGI,L1Reco,RECO,VALIDATION:validation_prod,DQM:DQMOfflinePOGMC \
    --datatier AODSIM,DQM \
    --conditions START53_LV6::All \
    --eventcontent AODSIM,DQM \
    --python_filename recoDY.py \
    --number $events \
    --filein file:hltDY.root \
    --fileout=recoDY.root

patch_global_tag recoDY.py
cmsRun recoDY.py


