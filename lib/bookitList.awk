#!/bin/awk -f
BEGIN { FS = ";";
		OFS = ";" }
	{ if ( NF > 1 ) {
		print $2,$3,$4,$6 
	  } 
	}
END { }
