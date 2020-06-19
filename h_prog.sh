#!/bin/bash
#___h_prog.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
source h_prog_gpio.sh
# gpio_get_data #pobiera pramtry gpio z mysql
# gpio_list # wyswietla na ekranie liste dostepnych portow
# gpio_init # pobiera parametry gpio z mysql i inicjuje gpio
source h_test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test

TNOW=$(date +"%T") #zminna zawierający aktualny czas
TRYB=-1

EZ_BUZ_TIM=0         #czas napelnienia buzaw
PM_PMP_TIM=0    #czas oproznienia buzaw
PL_START_N=0          # ilosc plukan na starcie
PL_STOP_N=0            #ilosc plukani na stop
PL_STAN=0                 # stan funkcji plukania 1= NAPELNIANIE 2= WYLEANIE 0=KONIEC

EZ_BUZ_CNT=0
PMP_BUZ_CNT=0
PL_START_CNT=0
PL_STOP_CNT=0

function pl_init(){
    local tmp=$(echo "SELECT valu FROM prog WHERE comm='ez_buz_time'" | mysql -D$DB -u $USER -p$PASS -N)
    EZ_BUZ_TIM=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pmp_buz_time'" | mysql -D$DB -u $USER -p$PASS -N)
    PMP_BUZ_TIM=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pl_start_n'" | mysql -D$DB -u $USER -p$PASS -N)
    PL_START_N=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pl_stop_n'" | mysql -D$DB -u $USER -p$PASS -N)
    PL_STOP_N=${tmp[0]}
    PL_STAN=0
    mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
}

function plukanie(){
    if [ $TRYB -eq 0 ] || [ $TRYB -eq 2 ] ; then
        if $TRYB -eq 0 ] ; then # PLUKANIE NA START
            echo "plukanie na start"
            TRYB=1
        else # PLUKANIE NA STOP
            echo "plukanie na stop"
            TRYB=3
        fi
    fi
}
while [ 1 ] ; do
    if [ $TRYB -eq -1 ] ; then
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Inicjalizacja systemu' WHERE comm='tryb_info';"
        gpio_init
        pl_init
        TRYB=0
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$TRYB WHERE comm='tryb';"
    fi
    echo "tryb=$TRYB PL_START_N=$PL_START_N"
     sleep 1
done
