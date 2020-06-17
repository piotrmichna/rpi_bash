#!/bin/bash
#_____h_tim.sh

# get_tim_form_S 242323
# get_date_form_S 242323
# get_s_from_data_time "2000-01-12" lub "2000-01-21 10:32:03"

function get_tim_from_S(){
	local tim=""
	if [ -z $1 ] || [[ $1 =~ '^[0-9]+$' ]] ; then
        echo ""
    else
		if [ $1 -gt 0 ] ; then
			tim=$(date -d @$1 "+%T")
		fi
		echo "$tim"
	fi
}

function get_date_from_S(){
	local dat=""
	if [ -z $1 ] || [[ $1 =~ '^[0-9]+$' ]] ; then
        echo ""
    else
		if [ $1 -gt 0 ] ; then
			dat=$(date -d @$1 "+%F")
		fi
		echo "$dat"
	fi
}

function get_s_from_data_time(){
	local sec=0
	if [ ! -z $2 ] && ! [[ $2 =~ '^[0-9]+$' ]] && ! [[ $1 =~ '^[0-9]+$' ]] ; then
		local datt="$1 $2"
	else
		if [ ! -z $1 ] && ! [[ $1 =~ '^[0-9]+$' ]] ; then
			local datt="$1"
		fi
	fi
	if [ ! -z $1 ] && ! [[ $1 =~ '^[0-9]+$' ]] ; then
		sec=`date --date="$datt" "+%s"`
	fi
	echo "$sec"
}
