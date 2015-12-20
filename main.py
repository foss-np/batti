#!/usr/bin/env python3

import sys
data = open(sys.argv[1]).read()

row = [ [], [], [], [], [], [], [] ]
for line in data.splitlines()[1:6]:
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

for i in range(3):
    for col in row:
        try:
            val = col[i]
        except:
            val = "--:-----:--"

        print(val, end="\t")
    print()
