#!/bin/sh

# Romaner och annan skönliteratur
cat $1 | bookitList.awk | grep Hc | grep .03 | sort > ../output/romaner.txt \
&& cat $1 | bookitList.awk | grep -v '^$' | grep Hc | grep -v .03 | sort -k 2 >> ../output/romaner.txt \
&& cat $1 | bookitList.awk | grep -v '^$' | grep -v Hylla | grep -v Hc | sort >> ../output/romaner.txt;
