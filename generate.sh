#!/bin/bash

LIB=${LIB:-./lib}
CSV=${CSV:-./csv}
OUTPUT=${OUTPUT:-./output}

function openHtml {
	htmlFile=${OUTPUT}/${1}.html;
	htmlStartOpenHead='<!DOCTYPE html><html><head><meta charset="utf-8" />';
	htmlStartCloseHead='<link href="../lib/list.css" rel="stylesheet" type="text/css"></head><body>';
	htmlEnd="</body></html>";

	echo $htmlStartOpenHead > $htmlFile;
	echo "<title>Nyinköp för "$1"</title>" >> $htmlFile;
	echo $htmlStartCloseHead >> $htmlFile;
	echo "<h1>Nyinköp av "$1"media</h1>" >> $htmlFile;	
	
}

function closeHtml {
	echo $htmlEnd >> $htmlFile;
}

function section {
	if [ -e ${OUTPUT}/${1}.csv ]
		then
			echo $2 >> $htmlFile;
			listAsHtmlTable ${1} >> $htmlFile;
	fi
}

function bookitList {
	cat ${CSV}/${1}.csv | iconv -f windows-1252 -t utf-8 | ${LIB}/bookitList.awk | grep -v Hylla;
}

function listAsHtmlTable {
	cat ${OUTPUT}/${1}.csv | ${LIB}/listAsHtmlTable.awk;
}


function generateListFile {
	echo "Genererar $1";
	case $1 in
		romaner|tal*)
			bookitList $1 | grep Hc | grep .02 | sort -t";" > $OUTPUT/${1}.csv \
				&& bookitList $1 | grep Hc | grep .03 | sort -t";" >> $OUTPUT/${1}.csv \
				&& bookitList $1 | grep Hc | grep -v .03 | sort -t";" -k 2 >> $OUTPUT/${1}.csv \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort -t";" >> $OUTPUT/${1}.csv
			;;
		deckare|sf|fantasy|pocket|biografier|jul|nyb|bild|kapitel|spöken|hästar|ungdom|ljud|daisy|bd|tecken|takk*)
			bookitList $1 | grep -v Hylla | sort -t";" -k 2 > $OUTPUT/${1}.csv
			;;
		serier|facklitteratur|språkkurser|vuxendvd|barndvd|smål|utländska|visor|sagor|småbarn|fakta|ung|barnutländska*)
			bookitList $1 | grep -v Hylla | sort -t";" > $OUTPUT/${1}.csv
			;;
		storstil|cd|mp3*)
			bookitList $1 | grep Hc | sort -t";" -k 2,2 > $OUTPUT/${1}.csv \
				&& bookitList $1 | grep -v Hylla | grep -v Hc | sort -t";" >> $OUTPUT/${1}.csv
			;;
	esac
}

function generateHtml {

	case $1 in
		vuxen*)
			echo "Generar vuxenlistan som html";
			openHtml $1;
			
			section romaner "<h2>Romaner, lyrik och annan skönlitteratur</h2>";
			section deckare "<h3>Deckare</h3>";
			section sf "<h3>Science Fiction</h3>";
			section fantasy "<h3>Fantasy</h3>";
			section pocket "<h3>Pocket</h3>";
			section serier "<h3>Tecknade serier</h3>";		
			
			section facklitteratur "<h2>Facklitteratur</h2>";
			section språkkurser "<h3>Språkkurser</h3>";				
			
			section biografier "<h2>Biografier</h2>" >> $htmlFile;
			
			echo "<h2>Ljudböcker</h2>" >> $htmlFile;
			listAsHtmlTable cd >> $htmlFile;
			section mp3 "<h3>Böcker som MP3</h3>";
			
			section utländska "<h2>Böcker på andra språk än svenska, danska, norska, engelska, tyska och franska</h2>";
			section vuxendvd "<h2>Filmer</h2>";

			section smål "<h2>Smålandslitteratur</h2>";
			
			section tal "<h2>Talböcker</h2>";
			
			section storstil "<h2>Storstil</h2>";			
			
			closeHtml;
			;;

		barn*)
			echo "Generar barnlistan som html"
			openHtml $1;

			section visor "<h2>Barnvisor</h2>";
			section småbarn "<h2>Småbarnsböcker</h2>";
			section sagor "<h2>Sagor</h2>";
			section bild "<h2>Bilderböcker</h2>";
			section jul "<h2>Julböcker</h2>";
			section nyb "<h2>Nybörjarläsning</h2>";
			section kapitel "<h2>Kapitelböcker</h2>";
			section spöken "<h2>Spöken</h2>";
			section hästar "<h2>Hästböcker</h2>";
			section fakta "<h2>Faktaböcker</h2>";
			section ungdom "<h2>Ungdomsböcker</h2>";
			section ung "<h3>Att vara ung</h3>";
			section ljud "<h2>Ljudböcker</h2>";
			section daisy "<h2>DAISY</h2>";
			section bd "<h3>Bok & DAISY</h3>";
			section barnutländska "<h2>På andra språk än svenska</h2>";
			section tecken "<h2>Teckenspråk</h2>";
			section takk "<h2>Tecken som alternativ och kompletterande kommunikation</h2>";
			section barndvd "<h2>Filmer</h2>";

			closeHtml;		
			;;
	esac
}

function branches {
	# Snygga till BOOK-IT-listan
	for file in ${CSV}/branches/*.csv; do
		bookitList $(echo $file | sed 's/[\.\/]csv//g') > $OUTPUT/branches/$(basename $file)

		# Jämför
		while read line
		do
			match=$(grep "${line}" $OUTPUT/*.csv);
			echo $match;
		done < $OUTPUT/branches/$(basename $file)		
		
	done
	

}



# Rensa output
( cd $OUTPUT; rm -f *.csv *.txt *.html )

# Utgå från sparade CSV-filer
for file in ${CSV}/*.csv; do
	base=$(basename "$file" ".csv")
	generateListFile $base
done

branches;

# Skriv html-filer
generateHtml "vuxen";
generateHtml "barn";



exit
