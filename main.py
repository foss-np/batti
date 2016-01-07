#!/usr/bin/env python3

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
    for col in row:
        try:
            val = col[i]
        except:
            val = "--:-----:--"

        if i > 0:
            val0 = col[i-1].split('-')[-1].replace(':', '')
            val1 = val.split('-')[0].replace(':', '')
            if int(val0) > int(val1):
                val = "--:-----:--"
                flag = True

        print(val, end="\t")
    print()
