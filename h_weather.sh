#!/bin/bash
#---h_weather.sh-----
source h_prog_gpio.sh
# gpio_get_data #pobiera pramtry gpio z mysql
# gpio_list # wyswietla na ekranie liste dostepnych portow

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

