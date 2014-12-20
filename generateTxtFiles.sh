#!/bin/bash

LIB=${LIB:-./lib}
CSV=${CSV:-./csv}
OUTPUT=${OUTPUT:-./output}

function generateTxtFile {
	echo "Genererar $1";
	case $1 in
		romaner*)
			cat ${CSV}/${1}.csv | ${LIB}/bookitList.awk | grep Hc | grep .03 | sort > $OUTPUT/${1}.txt \
				&& cat ${CSV}/${1}.csv | ${LIB}/bookitList.awk | grep Hc | grep -v .03 | sort -k 2 >> $OUTPUT/${1}.txt \
				&& cat ${CSV}/${1}.csv | ${LIB}/bookitList.awk | grep -v Hylla | grep -v Hc | sort >> $OUTPUT/${1}.txt
			;;
		deckare|biografier*)
			cat ${CSV}/${1}.csv | ${LIB}/bookitList.awk | grep -v Hylla | sort -k 2,2 >> $OUTPUT/${1}.txt
			;;
	esac
}

# Rensa output
( cd $OUTPUT; rm -f *.txt )

# Utgå från sparade CSV-filer
(
	for file in ${CSV}/*.csv; do
		base=$(basename "$file" ".csv")
		generateTxtFile $base
	done

)

exit

# Romaner och annan skönliteratur
# Deckare
# Biografier
