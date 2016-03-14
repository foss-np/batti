#!/usr/bin/env python
from __future__ import print_function

import sys

data = open(sys.argv[1]).read()

row = [ [], [], [], [], [], [], [] ]
for line in data.splitlines()[1:]:
    b = 16
    for i in range(7):
        a = b
        b = a + 12
        guess = line[a:b].strip()
        l = len(guess)
        if l == 0: continue
        elif l <  11:
            b = b + (12 - l)
            guess = line[a:b].strip()

        row[i].append(guess)


n = max(len(l) for l in row)
flag = False

for i in range(n):
    if flag: break
    for j, col in enumerate(row):
        try:
            val = col[i]
        except:
            val = "--:-----:--"

        if i > 0:
            if row[j-1][0] == val:
                val = "--:-----:--"
                flag = True

        print(val, end="\t")
    print()
