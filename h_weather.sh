#!/bin/bash

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"

MIN_DELAY=-1
MIN_DIV=0
HOU_DELAY=-1

T_MIN=0
T_MAX=0
H_MIN=0
H_MAX=0
TEM=0
HUM=0

BME[0]=0
BME_AVT[0]=0
BME_AVP[0]=0
BME_AVH[0]=0
BME_AV_NUM=0
function get_bme(){
    local  tmp=$( ./bme280 )
    BME=( $( for i in $tmp ;do echo $i ;done ) )

    CUR_DATTIME=$(date +"%s")
    mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO temp_min (id, dattim, tem) VALUES (NULL, $CUR_DATTIME, '${BME[0]}');"
    mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO press_min (id, dattim, press) VALUES (NULL, $CUR_DATTIME, '${BME[1]}');"
    mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO humi_min (id, dattim, humi) VALUES (NULL, $CUR_DATTIME, '${BME[2]}');"
    
    mysql -D$DBW -u $USER -p$PASS -N -e"UPDATE bme set valu='${BME[0]}' WHERE para='temp';"
    mysql -D$DBW -u $USER -p$PASS -N -e"UPDATE bme set valu='${BME[1]}' WHERE para='press';"
    mysql -D$DBW -u $USER -p$PASS -N -e"UPDATE bme set valu='${BME[2]}' WHERE para='humi';"
    BME_AVT[$BME_AV_NUM]=${BME[0]}
    BME_AVP[$BME_AV_NUM]=${BME[1]}
    BME_AVH[$BME_AV_NUM]=${BME[2]}
		BME_AV_NUM=$(( BME_AV_NUM+1 ))
}

function get_bme_min(){
    local CUR_SEC=$(date +"%-S")
    if [ $CUR_SEC -eq 0 ] ; then
        local CUR_MIN_MOD_DELAY=$(date +"%-M")
        CUR_MIN_MOD_DELAY=$(( CUR_MIN_MOD_DELAY%MIN_DELAY ))
        if [ $CUR_MIN_MOD_DELAY -eq 0 ] ; then
						local t=0
						local p=0
						local h=0
            for (( i=0 ; i<BME_AV_NUM ; i++ )) ; do
							t=$(( t+BME_AVT[$i} ))
							p=$(( p+BME_AVP[$i] ))
							h=$(( p+BME_AVH[$i] ))
							unset BME_AVT[$i]
							unset BME_AVP[$i]
							unset BME_AVH[$i]
						done
						BME[0]=$(( t/BME_AV_NUM ))
						BME[1]=$(( p/BME_AV_NUM ))
						BME[2]=$(( h/BME_AV_NUM ))
						BME_AV_NUM=0
    				CUR_DATTIME=$(date +"%s")
						CUR_DATTIME=$(( CUR_DAT_TIME-MIN_DIV ))

    				mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO temp_min (id, dattim, tem) VALUES (NULL, $CUR_DATTIME, '${BME[0]}');"
    				mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO press_min (id, dattim, press) VALUES (NULL, $CUR_DATTIME, '${BME[1]}');"
    				mysql -D$DBW -u $USER -p$PASS -N -e"INSERT INTO humi_min (id, dattim, humi) VALUES (NULL, $CUR_DATTIME, '${BME[2]}');"
            echo " temp= ${BME[0]}"
            echo "press= ${BME[1]}"
            echo " humi= ${BME[2]}"
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

function temp_is(){
	if [ ${BME[0]} -lt $T_MIN ] && [ $TEM -eq 0 ] ; then
		TEM=1
	fi
	if [ ${BME[0]} -gt $T_MAX ] && [ $TEM -eq 1 ] ; then
		TEM=0
	fi
	echo "$TEM"
}

function humi_is(){
	if [ ${BME[2]} -lt $T_MIN ] && [ $HUM -eq 0 ] ; then
		HUM=1
	fi
	if [ ${BME[2]} -gt $T_MAX ] && [ $HUMM -eq 1 ] ; then
		HUM=0
	fi
	echo "$HUM"
}

function weather_event(){
    if [ $MIN_DELAY -eq -1 ] ; then
        init_weather
    fi
	get_bme_min
}
