#!/bin/sh -x

srcurl="root://eosuser.cern.ch/eos/user/l/liko/mc-minbias-2011"
dsturl="root://eos.grid.vbc.ac.at//eos/vbc/experiments/cms/store/user/liko/mc-minbias-2011"
for name in $(gfal-ls $srcurl)
do
    gfal-copy -f $srcurl/$name $dsturl/$name
done
