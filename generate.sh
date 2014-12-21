#!/bin/bash

LIB=${LIB:-./lib}
CSV=${CSV:-./csv}
OUTPUT=${OUTPUT:-./output}

function bookitList {
	cat ${CSV}/${1}.csv | iconv -f windows-1252 -t utf-8 | ${LIB}/bookitList.awk;
}

function listAsHtmlTable {
	cat ${OUTPUT}/${1}.csv | ${LIB}/listAsHtmlTable.awk;
}


function generateListFile {
	echo "Genererar $1";
	case $1 in
		romaner*)
			bookitList $1 | grep Hc | grep .02 | sort -t";" > $OUTPUT/${1}.csv \
				&& bookitList $1 | grep Hc | grep .03 | sort -t";" >> $OUTPUT/${1}.csv \
				&& bookitList $1 | grep Hc | grep -v .03 | sort -t";" -k 2 >> $OUTPUT/${1}.csv \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort -t";" >> $OUTPUT/${1}.csv
			;;
		deckare|biografier*)
			bookitList $1 | grep -v Hylla | sort -t";" -k 2 > $OUTPUT/${1}.csv
			;;
		serier|facklitteratur|smål|utländska*)
			bookitList $1 | grep -v Hylla | sort -t";" > $OUTPUT/${1}.csv
			;;
		storstil|cd|mp3*)
			bookitList $1 | grep Hc | sort -t";" -k 2,2 > $OUTPUT/${1}.csv \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort -t";" >> $OUTPUT/${1}.csv
			;;
	esac
}

function generateHtml {
	htmlFile=${OUTPUT}/${1}.html;
	htmlStartOpenHead='<!DOCTYPE html><html><head><meta charset="utf-8" />';
	htmlStartCloseHead='<link href="../lib/list.css" rel="stylesheet" type="text/css"></head><body>';
	htmlEnd="</body></html>";

	case $1 in
		vuxen*)
			echo "Generar vuxenlistan";
			echo $htmlStartOpenHead > $htmlFile;
			echo "<title>Nyinköp för "$1"</title>" >> $htmlFile;
			echo $htmlStartCloseHead >> $htmlFile;

			echo "<h1>Nyinköp av "$1"media</h1>" >> $htmlFile;
			echo "<h2>Romaner, lyrik och annan skönlitteratur</h2>" >> $htmlFile;
			listAsHtmlTable romaner >> $htmlFile;
			echo "<h3>Deckare</h3>" >> $htmlFile;
			listAsHtmlTable deckare >> $htmlFile;
			echo "<h2>Facklitteratur</h2>" >> $htmlFile;
			listAsHtmlTable facklitteratur >> $htmlFile;
			echo "<h2>Biografier</h2>" >> $htmlFile;
			listAsHtmlTable biografier >> $htmlFile;

			echo $htmlEnd >> $htmlFile;
			;;

		barn*)
			echo "Generar barnlistan"
			;;
	esac
}

# Rensa output
( cd $OUTPUT; rm -f *.csv *.txt *.html )

# Utgå från sparade CSV-filer
for file in ${CSV}/*.csv; do
	base=$(basename "$file" ".csv")
	generateListFile $base
done

# Skriv html-filer
generateHtml "vuxen";
generateHtml "barn";

exit
