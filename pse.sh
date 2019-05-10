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
#    	 <Property you're interested in>, which returns the value specified or
#	 <short>, which returns a short list of interesting values.
#	-Any empirical Formula, or molecular Formula for an Molecule 
#    	 (eg. H2O as well as HOH (if you dare)),
# 	 followed by <eval>
# BUGS: None so far
# TASKS: Add reaction eval


get_gelemental_path() {
    
    shopt -s nullglob
    local g_path=(/usr/bin/gelemental)
    shopt -u nullglob
        [[ -x "$g_path" ]] && \
            { gelem_path="$g_path"; return; } && \
                echo "$gelem_path"
}


pse() {
    
    get_gelemental_path
    local gm="$gelem_path"
    M_weight=0
	if [ -z "$1" ] ; then
	  $gm '--help'
	  echo "User Options:"
	  echo "	e.g.: ~$ pse H2O eval yields 'M(H20): 18.0153 g/mol'."
	else
	  if [ "$2" == "short" ] ; then
	      $gm -p "$1" \
              | grep 'Name\|Ordnungszahl\|Periode\|Gruppe\|Atomasse\|Oxidationszahlen\|Schmelzpunkt\|Dichte,'
	  else
		if [ "$2" == "Dichte" ] ; then
		  $gm -p "$1" \
		  | grep "Dichte,"
		else
		  if [ "$2" == "eval" ] ; then
			local Elements=`echo $1 \
			| sed 's/.[0-9]*\|.[a-z][0-9]*/&\n/g'`
			# echo "$Elements"
			for Element in $Elements ; do
				local Mass=`echo $Element \
				| tr -d 0-9\
				| xargs gelemental -p \
				| grep 'Atommasse' \
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
			  $gm -p "$1"
			else
				$gm -p "$1" \
				| grep "$2 $3"
			fi
		  fi
		fi
	  fi
	fi
}

main() {

    get_gelemental_path
    if [[ ! -x "$gelem_path" ]]; then
        printf "gelemental path not found, aborting.\n" \
            && exit
    else
        #for i in "$1"; do 
        #    if $(echo "$i" | grep -q [0-9]); then
        #        local ev=1 && \
        #            break
        #    else
        #        local ev=
        #    fi
        #done
        local ev=$(echo "$1" | tr -d [:alpha:])
        if [ ! -z "$ev" -a -z "$2" ]; then
            pse "$1" 'eval'
        else
            pse "$@"
        fi
    fi
}

main "$@"
# pse "$1" "$2" "$3"

