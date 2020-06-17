#!/bin/bash

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"

MIN_DELAY=-1
HOU_DELAY=-1

BME[0]=0

function get_bme(){
    local  tmp=$( ./bme280 )
    BME=( $( for i in $tmp ;do echo $i ;done ) )

    CUR_DAT=$(date +"%F")
    CUR_TIM=$(date +"%T")
}

function get_bme_min(){
    local CUR_SEC=$(date +"%-S")
    if [ $CUR_SEC -eq 0 ] ; then
        local CUR_MIN_MOD_DELAY=$(date +"%-M")
        CUR_MIN_MOD_DELAY=$(( CUR_MIN_MOD_DELAY%MIN_DELAY ))
        if [ $CUR_MIN_MOD_DELAY -eq 0 ] ; then
            get_bme
            mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO temp_min (id, dat, tim, tem) VALUES (NULL, '$CUR_DAT', '$CUR_TIM', '${BME[0]}');"
            mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO press_min (id, dat, tim, press) VALUES (NULL, '$CUR_DAT', '$CUR_TIM', '${BME[1]}');"
            mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO humi_min (id, dat, tim, humi) VALUES (NULL, '$CUR_DAT', '$CUR_TIM', '${BME[2]}');"
            #echo " temp= ${BME[0]}"
            #echo "press= ${BME[1]}"
            #echo " humi= ${BME[2]}"
        fi
    fi
}

function init_weather(){
    local tmp=$(echo "SELECT valu FROM cnf WHERE comm='min_delay'" | mysql -D$DBW -u $USER -p$PASS -N)
    MIN_DELAY=${tmp[0]}
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='hour_delay'" | mysql -D$DBW -u $USER -p$PASS -N)
    HOU_DELAY=${tmp[0]}
    log_sys "Inicjalizacja czujników"
    echo "MIN_DELAY=$MIN_DELAY"
    echo "HOU_DELAY=$HOU_DELAY"
    get_bme
}


function weather_event(){
    if [ $MIN_DELAY -eq -1 ] ; then
        init_weather
    fi
	get_bme_min
}
