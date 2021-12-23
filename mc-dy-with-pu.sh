#!/bin/sh -x
#
# Run simulation in cmsopendata ebvironment


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
    --mc \
    --beamspot Realistic7TeV2011CollisionV2 \
    --eventcontent=RAWSIM \
    --datatier=GEN-SIM \
    --conditions=START53_LV6A1::All \
    --step=GEN,SIM \
    --python_filename=gensimDY.py \
    --number $events \
    --fileout=gensimDY.root \
    --no_exec

patch_global_tag gensimDY.py
cmsRun gensimDY.py

# HLT

cmsDriver.py step1 \
    --mc \
    --eventcontent RAWSIM \
    --datatier GEN-RAW \
    --conditions START53_LV6A1::All \
    --step DIGI,L1,DIGI2RAW,HLT:2011 \
    --python_filename hltDY.py \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --number $events \
    --pileup_input root://eospublic.cern.ch//eos/opendata/cms/MonteCarlo2011/Summer11LegDR/MinBias_TuneZ2_7TeV-pythia6/GEN-SIM/START53_LV4-v1/10000/00064CCC-A218-E311-A2E9-D485646A4E1A.root \
    --pileup 2011_FinalDist_OOTPU \
    --filein file:gensimDY.root  \
    --fileout hltDY.root \
    --no_exec 

patch_global_tag hltDY.py
cmsRun hltDY.py

# RECO

cmsDriver.py step2 \
    --mc \
    --step RAW2DIGI,L1Reco,RECO,VALIDATION:validation_prod,DQM:DQMOfflinePOGMC \
    --datatier AODSIM,DQM \
    --conditions START53_LV6A1::All \
    --eventcontent AODSIM,DQM  \
    --python_filename recoDY.py \
    --number $events \
    --filein file:hltDY.root \
    --fileout recoDY.root \
    --no_exec

patch_global_tag recoDY.py
cmsRun recoDY.py


