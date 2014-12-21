#!/bin/bash

LIB=${LIB:-./lib}
CSV=${CSV:-./csv}
OUTPUT=${OUTPUT:-./output}

function bookitList {
	cat ${CSV}/${1}.csv | iconv -f windows-1252 -t utf-8 | ${LIB}/bookitList.awk;
}

function generateTxtFile {
	echo "Genererar $1";
	case $1 in
		romaner*)
			bookitList $1 | grep Hc | grep .02 | sort > $OUTPUT/${1}.txt \
				&& bookitList $1 | grep Hc | grep .03 | sort >> $OUTPUT/${1}.txt \
				&& bookitList $1 | grep Hc | grep -v .03 | sort -k 2 >> $OUTPUT/${1}.txt \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort >> $OUTPUT/${1}.txt
			;;
		deckare|biografier*)
			bookitList $1 | grep -v Hylla | sort -k 2,2 > $OUTPUT/${1}.txt
			;;
		serier|facklitteratur|smål|utländska*)
			bookitList $1 | grep -v Hylla | sort > $OUTPUT/${1}.txt
			;;
		storstil|cd|mp3*)
			bookitList $1 | grep Hc | sort -k 2,2 > $OUTPUT/${1}.txt \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort >> $OUTPUT/${1}.txt
			;;
	esac
}

function generateHtml {
	htmlStartOpenHead='<!DOCTYPE html><html><meta charset="utf-8" /><head>';
	htmlStartCloseHead="</head><body>";
	htmlEnd="</body></html>";

	case $1 in
		vuxen*)
			echo "Generar vuxenlistan";
			echo $htmlStartOpenHead > ${OUTPUT}/${1}.html
			echo "<title>"$1"</title>" >> ${OUTPUT}/${1}.html
			echo $htmlStartCloseHead >> ${OUTPUT}/${1}.html
			echo "<h1>Nyinköp</h1>" >> ${OUTPUT}/${1}.html
			echo "<h2>Romaner, lyrik och annan skönlitteratur</h2>" >> ${OUTPUT}/${1}.html
			cat ${OUTPUT}/romaner.txt | ${LIB}/listAsHtmlTable.awk >> ${OUTPUT}/${1}.html
			echo "<h3>Deckare</h3>" >> ${OUTPUT}/${1}.html
			cat ${OUTPUT}/deckare.txt | ${LIB}/listAsHtmlTable.awk >> ${OUTPUT}/${1}.html
			echo "<h2>Facklitteratur</h2>" >> ${OUTPUT}/${1}.html
			cat ${OUTPUT}/facklitteratur.txt | ${LIB}/listAsHtmlTable.awk >> ${OUTPUT}/${1}.html
			echo $htmlEnd >> ${OUTPUT}/${1}.html
			;;
		barn*)
			echo "Generar barnlistan"
			;;
	esac
}

# Rensa output
( cd $OUTPUT; rm -f *.txt *.html )

# Utgå från sparade CSV-filer
for file in ${CSV}/*.csv; do
	base=$(basename "$file" ".csv")
	generateTxtFile $base
done

# Skriv html-filer
generateHtml "vuxen";
generateHtml "barn";

exit
