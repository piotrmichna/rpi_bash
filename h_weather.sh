#!/bin/bash

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"

MIN_DELAY=0
HOU_DELAY=0

BME[0]=0

function get_bme(){
    local  tmp=$( ./bme280 )
    WT_PAR=( $( for i in $tmp ;do echo $i ;done ) )

    CUR_DAT=$(date +"%F")
    CUR_TIM=$(date +"%T")
}

function init_weather(){
    local tmp=$(echo "SELECT valu FROM cnf WHERE comm='min_delay'" | mysql -D$DBW -u $USER -p$PASS -N)
    MIN_DELAY=${tmp[0]}
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='hour_delay'" | mysql -D$DBW -u $USER -p$PASS -N)
    HOU_DELAY=${tmp[0]}
    log_sys "Inicjalizacja czujników"
    echo "MIN_DELAY=$MIN_DELAY"
    echo "HOU_DELAY=$HOU_DELAY"
}


function get_weather(){
	while [ 1 ] ; do
		tmp=$( ./bme280 )

		WT_PAR=( $( for i in $tmp ;do echo $i ;done ) )
		WT_PAR[3]=0
		echo " temp= ${WT_PAR[0]}"
		echo "press= ${WT_PAR[1]}"
		echo " high= ${WT_PAR[2]}"
		echo "------"
		sleep 3
	done
}

get_weather
