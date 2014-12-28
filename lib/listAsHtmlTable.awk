#!/bin/awk -f
BEGIN { FS = ";";
		OFS = "</td><td>";
		print "<table>"
   	}
	{ if ( NF > 1 ) {
		print "<tr><td>"$1,$2,$3,$4,$5"</td></tr>"
	  } 
	}
END { print "</table>" }
