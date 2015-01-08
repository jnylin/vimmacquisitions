#!/bin/bash

# Copyright 2015 Jakob Nylin (jakob [dot] nylin [at] gmail [dot] com)
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


SCRIPTDIR=${SCRIPTDIR:-vimmacquisitions}
CWD=$(pwd)
PERIOD=$1
LIB=${LIB:-$CWD/lib}
CSV=${CSV:-$CWD/csv}
OUTPUT=${OUTPUT:-$CWD/output}

## HTML 
function openHtml {
	htmlFile=${OUTPUT}/${1}.html
	local htmlStartOpenHead='<!DOCTYPE html><html><head><meta charset="utf-8" />'
	local css='<style>caption{text-align:left;font-weight:bold;margin-top:.83em;margin-bottom:.4em}caption.h2{font-size:1.5em}caption.h3{font-size:1.169em}h2{margin-bottom:0}.branch{font-style:italic}</style>'
	local htmlStartCloseHead='</head><body>'

	echo $htmlStartOpenHead > $htmlFile
	echo "<title>Nyinköp för "$1"</title>" >> $htmlFile
	echo $css >> $htmlFile	
	echo $htmlStartCloseHead >> $htmlFile
	echo "<header><h1>Nyhetslista Vimmerby bibliotek</h1><p>Inköp av ${1}media under ${PERIOD} </p></header>" >> $htmlFile
	
}

function section {
	if [ -e ${OUTPUT}/${1}.csv ]
		then
			echo $2 >> $htmlFile
			listAsHtmlTable ${1} >> $htmlFile
	fi
}

function newSection {
	if [ -e ${OUTPUT}/${1}.csv ]
		then
			listAsHtmlTable ${1} "${2}" "${3}" >> $htmlFile
	fi
}

function listAsHtmlTable {
	cat ${OUTPUT}/${1}.csv | ${LIB}/listAsHtmlTable.awk - "${2}" "${3}"
}

function closeHtml {
	local htmlEnd="</body></html>";
	echo $htmlEnd >> $htmlFile;
}

function generateHtml {

	case $1 in
		vuxen*)
			echo "Generar vuxenlistan som html"
			openHtml $1 
			
			newSection romaner "Romaner, lyrik och annan skönlitteratur" h2
			newSection deckare "Deckare" h3
			newSection sf "Science Fiction" h3
			newSection fantasy "Fantasy" h3
			newSection pocket "Pocket" h3
			newSection serier "Tecknade serier" h3

			newSection facklitteratur "Facklitteratur" h2
			newSection språkkurser "Språkkurser" h3
			
			newSection biografier "Biografier" h2
			
			newSection cd "Ljudböcker" h2
			newSection mp3 "Böcker som MP3" h3
			
			newSection utländska "Böcker på andra språk än svenska, danska, norska, engelska, tyska och franska" h2
			newSection vuxendvd "Filmer" h2
			newSection smål "Smålandslitteratur" h2
			newSection tal "Talböcker" h2
			newSection storstil "Storstil" h2
			
			closeHtml;
			;;

		barn*)
			echo "Generar barnlistan som html"
			openHtml $1

			newSection visor "Barnvisor" h2
			newSection småbarn "Småbarnsböcker" h2
			newSection sagor "Sagor" h2
			newSection bild "Bilderböcker" h2
			newSection jul "Julböcker" h2
			newSection nyb "Nybörjarläsning" h2
			newSection kapitel "Kapitelböcker" h2
			newSection spöken "Spöken" h2
			newSection hästar "Hästböcker" h2
			newSection fakta "Faktaböcker" h2
			newSection ungdom "Ungdomsböcker" h2
			newSection ung "Att vara ung" h3
			newSection ljud "Ljudböcker" h2
			newSection daisy "DAISY" h2
			newSection bd "Bok & DAISY" h3
			newSection barnutländska_utf "På andra språk än svenska" h2;
			newSection tecken "Teckenspråk" h2
			newSection takk "Tecken som alternativ och kompletterande kommunikation" h2
			newSection barndvd "Filmer" h2

			closeHtml	
			;;
	esac
}

## CSV
function bookitList {

	cat $CSV/${1}.csv |	if [ $(echo $1 | grep -c utf) -lt 1 ]
	then
		iconv -f windows-1252 -t utf-8
	else
		cat
	fi	| ${LIB}/bookitList.awk | grep -v Hylla

}

function sortSection {
	# Vilket är bästa sättet att sortera utländska språk? Nu sorteras det på författare
	local tmp=tmpSortSection.csv

	case $1 in
		romaner|tal*)
			cat $2 | grep Hc | grep .02 | sort -t";" > $tmp \
				&& cat $2 | grep Hc | grep .03 | sort -t";" >> $tmp \
				&& cat $2 | grep Hc | grep -v .03 | sort -t";" -k 2 >> $tmp \
				&& cat $2 | grep -v Hylla | grep -v Hc | sort -t";" >> $tmp
			cat $tmp
			;;
		deckare|sf|fantasy|pocket|biografier|jul|nyb|bild|kapitel|spöken|hästar|ungdom|ljud|daisy|bd|tecken|takk|utländska|barnutländska*)
			cat $2 | grep -v Hylla | sort -t";" -k 2
			;;
		serier|facklitteratur|språkkurser|vuxendvd|barndvd|smål|visor|sagor|småbarn|fakta|ung*)
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

function branches {
	# Snygga till BOOK-IT-listan
	for file in ${CSV}/branches/*.csv; do
		bookitList $(echo branches/$(basename $file ".csv")) > $OUTPUT/branches/$(basename $file)
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
				# FIXA: Kontroll av angiven class
				( cd $OUTPUT;

				  echo $line";"$branch >> ${class}.csv
				  sortSection $class ${class}.csv > ${class}.new.csv \
				  && mv ${class}.new.csv ${class}.csv )

			fi
		done < $OUTPUT/branches/$(basename $file)		
		
	done

}


## Main

# Kontrollera att det körs från rätt katalog 
if ! [[ $(basename $(pwd)) == $SCRIPTDIR ]]
then
	echo "Scriptet måste köras från sin egen katalog"
	exit 1
fi

# Rensa output
( cd $OUTPUT; rm -f *.csv *.txt *.html )

# Utgå från sparade CSV-filer
for file in ${CSV}/*.csv; do
	generateListFile $(basename "$file" ".csv")
done

# Lägg till filialer
branches;

# Skriv html-filer
generateHtml "vuxen";
generateHtml "barn";

exit
