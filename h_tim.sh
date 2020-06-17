#!/bin/bash
#_____h_time.sh

TIM_A=$(date +"%-s")
echo "    TIM_A[s]= $TIM_A"
temp=$(date -d @$TIM_A "+%F %T")
echo "TIM_A[%F %T]= $temp"

sleep 2

TIM_B=$(date +"%-s")
echo "    TIM_B[s]= $TIM_B"
temp=$(date -d @$TIM_B "+%F %T")
echo "TIM_B[%F %T]= $temp"
echo "________"

TIM_MID=$(( TIM_B-TIM_A ))
TIM_MID=$(( TIM_MID/2 ))
TIM_MID=$(( TIM_A+TIM_MID ))

echo "    TIM_A[s]= $TIM_A"
echo "  TIM_MID[s]= $TIM_MID"
echo "    TIM_B[s]= $TIM_B"
echo "_"
tempA=$(date -d @$TIM_A "+%T")
echo "  TIM_A[%T]= $tempA"
tempMID=$(date -d @$TIM_MID "+%T")
echo "TIM_MID[%T]= $tempMID"
tempB=$(date -d @$TIM_B "+%T")
echo "  TIM_B[%T]= $tempB"

# czas na sekundy i data na sekundy
temp=`date --date="$tempA" "+%s"`
echo " TIM_A -> SEC = $temp"
echo "        TIM_A = $TIM_A"
tim=0
temp=$(date -d @$tim "+%F %T")
echo "data od 542 -> $temp"

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
