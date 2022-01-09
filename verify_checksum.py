#! /usr/bin/env python3

import csv
import os

PATH='/eos/vbc/experiments/cms/store/user/liko/mc-minbias-2011'

with open("mc-minbias-2011.csv", "r") as csvfile:
    for name, checksum in csv.reader(csvfile, delimiter='\t'):
        path = os.path.join(PATH, f"MinBias-Summer11-RECO-{name[16:]}")
        if not os.path.exists(path):
            print(path)
        if checksum != os.getxattr(path, 'eos.checksum').decode('utf-8'):
            print('Checksum Error', path)



