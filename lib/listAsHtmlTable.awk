#!/bin/awk -f
BEGIN { FS = ";";
		OFS = "</td><td>";
		print "<table><caption class='"ARGV[3]"'>"ARGV[2]"</caption>"
		delete ARGV[2] 
		delete ARGV[3]
   	}
	{ if ( NF > 1 ) {
		print "<tr><td>"$1,$2,$3,$4"</td><td class='branch'>"$5"</td></tr>"
	  } 
	}
END { print "</table>" }
