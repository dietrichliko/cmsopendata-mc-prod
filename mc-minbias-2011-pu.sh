#!/bin/sh -x
#
# Simulate MinBias 7TeV for 2011 using CNS Opendata using cmsconnect
# http://opendata.cern.ch/record/36
# (yilun.wu@Vanderbilt.Edu)
#
# Dietrich.Liko@oeaw.ac.at

EVENTS=$1
CONDOR_JOB_ID=$2
CONDOR_PROC_ID=$3

tar xzvf start53_lv6a1.tgz

find .



# Patch for conditions database

patch_global_tag() {
    sed -f - -i "$1" <<SED_SCRIPT
/^process.GlobalTag = /a process.GlobalTag.connect = cms.string('sqlite_file:${PWD}/START53_LV6A1.db')
/^process.GlobalTag = /a process.GlobalTag.globaltag = 'START53_LV6A1::All'
/^process.GlobalTag = /d
SED_SCRIPT
}

source /opt/cms/cmsset_default.sh
scramv1 project CMSSW ${CMSSW_VERSION}
cd ${CMSSW_VERSION}/src
eval `scramv1 runtime -sh`

mkdir -p Configuration/GenProduction/python/
mv ../../MinBias_TuneZ2_7TeV_pythia6_cff.py Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py

scram b

cd ../..

# GEN-SIM

cmsDriver.py Configuration/GenProduction/python/MinBias_TuneZ2_7TeV_pythia6_cff.py \
	--mc \
	--eventcontent RAWSIM \
	--customise SimG4Core/Application/reproc2011_2012_cff.customiseG4 \
	--datatier GEN-SIM \
	--conditions START53_LV6A1::All \
	--beamspot Realistic7TeV2011CollisionV2 \
	--step GEN,SIM \
	--python_filename MinBias-Summer11-GENSIM.py \
	--no_exec \
        --fileout MinBias-Summer11-GENSIM.root \
	--number "$EVENTS"

patch_global_tag MinBias-Summer11-GENSIM.py

cmsRun MinBias-Summer11-GENSIM.py 

# HLT

cmsDriver.py step1 \
	--mc \
	--step=DIGI,L1,DIGI2RAW,HLT:2011 \
	--datatier GEN-RAW \
	--conditions=START53_LV6A1::All \
	--eventcontent RAWSIM \
	--pileup_input root://eos.grid.vbc.ac.at//eos/vbc/experiments/cms/store/user//liko/mc-minbias-2011/MinBias-Summer11-RECO-11288508-9.root \
        --pileup 2011_FinalDist_OOTPU \
	--python_filename MinBias-Summer11-HLT.py \
	--no_exec \
	--filein file:MinBias-Summer11-GENSIM.root \
	--fileout=MinBias-Summer11-HLT.root \
	--number "$EVENTS"

patch_global_tag MinBias-Summer11-HLT.py

cmsRun MinBias-Summer11-HLT.py

# RECO

cmsDriver.py step2 \
	--mc \
	--step RAW2DIGI,L1Reco,RECO,VALIDATION:validation_prod,DQM:DQMOfflinePOGMC \
	--datatier AODSIM,DQM \
	--conditions START53_LV6::All \
	--eventcontent AODSIM,DQM \
	--python_filename MinBias-Summer11-RECO.py \
	--no_exec \
	--filein file:MinBias-Summer11-HLT.root \
	--fileout MinBias-Summer11-RECO.root \
	--number "$EVENTS"

patch_global_tag MinBias-Summer11-RECO.py

cmsRun MinBias-Summer11-RECO.py

xrdcp -np -adler MinBias-Summer11-RECO.root \
    root://eos.grid.vbc.ac.at//eos/vbc/experiments/cms/store/user/liko/mc-minbias-2011-pu/MinBias-Summer11-RECO-${CONDOR_JOB_ID}-${CONDOR_PROC_ID}.root

# xrdcp -np -adler MinBias-Summer11-RECO.root \
#	root://eosuser.cern.ch//eos/user/l/liko/mc-minbias-2011i-pu/MinBias-Summer11-RECO-${CONDOR_JOB_ID}-${CONDOR_PROC_ID}.root

