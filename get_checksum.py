#!/usr/bin/env python3

import re
import os

re_name = re.compile('^(.+)_(\d+)-(\d+)\.out$') 
re_adler = re.compile('adler32: ([\dabcdef]+) ')
with open('mc-minbias-2011.csv', 'w') as csv:
    for name in os.listdir('log'):
        match = re_name.match(name)
        if not match:
           continue

        stem, cluster, proc = match.groups()
        with open(os.path.join('log', name), 'r') as inp:
             data = inp.read()
             match = re_adler.search(data)
             if match:
                 print(f"{stem}_{cluster}-{proc}.root\t{match.group(1)}", file=csv)
             else:
                 print( 'No match', name)
