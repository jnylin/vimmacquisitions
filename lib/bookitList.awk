#!/bin/awk -f
BEGIN { FS = ";";
		OFS = " " }
	{ print $2,$3,$4,$6 }
END { }