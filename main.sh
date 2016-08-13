#!/usr/bin/env bash

i=0
for pdf in *.pdf; do
    let i++
    echo "* TEST $i: '$pdf'"
    cp $pdf /tmp/nea.pdf
    2>/dev/null ../main.sh -u > /dev/null
    diff ~/.cache/batti.sch ${pdf/pdf/out} && echo "  SUCCESS"
    echo
done
