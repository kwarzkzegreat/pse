#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version
#
# Molecular mass calculator for the GNU gelemental Periodic table
# Its allowed arguments are:
#	-None, Any Element Number, Any Element Name in two-letter-code 
# 	 (eg. Ni|28 for Nickel), without anything, or followed by 
#    <Property you're interested in>, which returns the value specified or
#	 <short>, which returns a short list of interesting values.
#	-Any empirical Formula, or molecular Formula for an Molecule 
#    (eg. H2O as well as HOH (if you dare)),
# 	 followed by <eval>
# BUGS: None so far
# TASKS: Add reaction eval


pse() {

M_weight=0
	if [ -z "$1" ] ; then
	  gelemental --help
	  echo "User Options:"
	  echo "	e.g.: ~$ pse H2O eval yields 'M(H20): 18.0153 g/mol'."
	else
	  if [ "$2" == "short" ] ; then
		gelemental -p $1 \
		| grep 'Atomic number\|Period\|Group\|Atomic mass\|Oxidation states\|Melting point\|Density,'
	  else
		if [ "$2" == "Density" ] ; then
		  gelemental -p $1 \
		  | grep "Density,"
		else
		  if [ "$2" == "eval" ] ; then
			local Elements=`echo $1 \
			| sed 's/.[0-9]*\|.[a-z][0-9]*/&\n/g'`
			# echo "$Elements"
			for Element in $Elements ; do
				local Mass=`echo $Element \
				| tr -d 0-9\
				| xargs gelemental -p \
				| grep 'Atomic mass' \
				| tr -d [:alpha:][:blank:]:/ \
				| sed 's/,/./g'`
				local Mol=`echo $Element \
				| tr -d [:alpha:]`
					if [ -z "$Mol" ] ; then
						local Mol=1
					fi
				# local Molmass=`echo "$Mol * $Mass" | bc -l`
				local Molmass=`awk "BEGIN {print $Mol*$Mass}"`
				# echo $Molmass
				M_weight=`awk "BEGIN {print $M_weight+$Molmass}"`
			done
			echo "M($1): $M_weight g/mol"
		  else
			if [ -z "$2" ] ; then
			  gelemental -p $1
			else
				gelemental -p $1 \
				| grep "$2 $3"
			fi
		  fi
		fi
	  fi
	fi
}

pse "$1" "$2" "$3"

