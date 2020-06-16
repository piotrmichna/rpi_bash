#!/bin/bash


source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
source h_prog_gpio.sh
# gpio_get_data #pobiera pramtry gpio z mysql
# gpio_list # wyswietla na ekranie liste dostepnych portow

function get_weather(){
	while [ 1 ] ; do
		tmp=$( python bme280.py )

		WT_PAR=( $( for i in $tmp ;do echo $i ;done ) )
		WT_PAR[3]=0
		mysql -D$DB -u $USER -p$PASS -N -e"INSERT INTO weather (id, temp, press, humid, light) VALUES (NULL, ${WT_PAR[0]}, ${WT_PAR[1]}, ${WT_PAR[2]}, ${WT_PAR[3]});"
		sleep 3
	done
}
get_weather
