#!/bin/bash

# Copyright 2014 Jakob Nylin (jakob [dot] nylin [at] gmail [dot] com)
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

	local tmp=$OUTPUT/tmpGenerateListFile.csv
	local result=$OUTPUT/${1}.csv

	bookitList $1 > $tmp
	sortSection $1 $tmp > $result

	if [ -e $tmp ]
	then
		rm $tmp
	fi

}

function sortSection {
	local tmp=$OUTPUT/tmpSortSection.csv

	case $1 in
		romaner|tal*)
			cat $2 | grep Hc | grep .02 | sort -t";" > $tmp \
				&& cat $2 | grep Hc | grep .03 | sort -t";" >> $tmp \
				&& cat $2 | grep Hc | grep -v .03 | sort -t";" -k 2 >> $tmp \
				&& cat $2 | grep -v Hylla | grep -v Hc | sort -t";" >> $tmp
			cat $tmp
			;;
		deckare|sf|fantasy|pocket|biografier|jul|nyb|bild|kapitel|spöken|hästar|ungdom|ljud|daisy|bd|tecken|takk*)
			cat $2 | grep -v Hylla | sort -t";" -k 2
			;;
		serier|facklitteratur|språkkurser|vuxendvd|barndvd|smål|utländska|visor|sagor|småbarn|fakta|ung|barnutländska*)
			cat $2 | grep -v Hylla | sort -t";"
			;;
		storstil|cd|mp3*)
			cat $2 | grep Hc | sort -t";" -k 2,2 > $tmp \
				&& cat $2 | grep -v Hylla | grep -v Hc | sort -t";" >> $tmp
			cat $tmp
			;;
	esac

	if [ -e $tmp ]
	then
		rm $tmp
	fi

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
		bookitList $(echo ${file} | sed 's/[\.\/]csv//g') > $OUTPUT/branches/$(basename ${file})
		case $(basename ${file} ".csv") in
			storebro*)
				branch=ST
				;;
			"södra_vi"*)
				branch=SÖ
				;;
		esac
		
		# Jämför
		while read line
		do
			match=$(grep -l "${line}" $OUTPUT/*.csv)
			if [ $match ]
			then
				# HB om inte redan tillagt, börja med det
				sed "s/\(${line};[HS][BTÖ].*\)\$/\1, ${branch}/" $match > ${match}.new \
					&& mv ${match}.new $match
				sed "s/\(${line}\)\$/\1;HB, ${branch}/" $match > ${match}.new \
					&& mv ${match}.new $match
			else
				# Utan träff måste vi fråga om kategori
				echo -n "Hur ska följande titel kategoriseras ${line}? "
				read class </dev/tty

				# Lägg till i rätt fil
				echo $line";"$branch >> $OUTPUT/${class}.csv
				sortSection $class $OUTPUT/${class}.csv > ${class}.new.csv \
					&& mv ${class}.new.csv ${class}.csv

			fi
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
