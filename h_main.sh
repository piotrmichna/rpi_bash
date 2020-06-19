#!/bin/bash
#___main.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
source h_test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test
source h_prog.sh
source h_sys.sh
source h_weather.sh


function main(){
    log_sys "START SYSTEMU"

   while [ 1 ] ; do
        weather_event
        sys_event
        if [ $TRYB -eq -1 ] ; then
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Inicjalizacja systemu' WHERE comm='tryb_info';"
            gpio_init
            pl_init
            TRYB=0
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$TRYB WHERE comm='tryb';"
        fi
        if [ $TRYB -eq 1 ] ; then
            praca
            if [ $PWR -eq 0 ] ; then
                TRYB=2
            fi
        fi
        plukanie
        if [ $TRYB -eq 3 ] ; then
            sudo shutdown now
            sudo systemctl stop homster.service
        fi
        sleep 1
    done
}
main
