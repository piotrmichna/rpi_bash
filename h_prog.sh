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
TRYB=-1 # -1 inicjalizacja 0 plukanie start 1 praca 2 plukanie na koniec 3 koniec

EZ_BUZ_TIM=0         #czas napelnienia buzaw
PMP_BUZ_TIM=0    #czas oproznienia buzaw
PL_START_N=0          # ilosc plukan na starcie
PL_STOP_N=0            #ilosc plukani na stop
PL_STAN=0                 # stan funkcji plukania 0=START WYLEWANIA 1= WYLEANIE 2= KONIEC WYLEWANIA 3= NAPELNIANIE 4=KONIEC NAPELNIANIA

EZ_BUZ_CNT=0
PMP_BUZ_CNT=0
PL_START_CNT=0
PL_STOP_CNT=0

BUZ_STAN=0
WENT_STAN=0
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
    EZ_BUZ_CNT=0
    PMP_BUZ_CNT=0
    PL_START_CNT=0
    PL_STOP_CNT=0
}

function wylewanie() {
    if [ $PMP_BUZ_CNT -eq 0 ] ; then
        gpo_out "pmp_buz" 0
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Buzawy pusta' WHERE comm='pl_info';"
        PL_STAN=2
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
    else
        if [ $PMP_BUZ_CNT -eq $PMP_BUZ_TIM ] ; then
            gpo_out "pmp_buz" 1
            PL_STAN=1
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Wylewanie wody z buzaw' WHERE comm='pl_info';"
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
        fi
        PMP_BUZ_CNT=$(( PMP_BUZ_CNT-1 ))
    fi
}

function napelnianie() {
    if [ $EZ_BUZ_CNT -eq 0 ] ; then
        gpo_out "ez_buz" 0
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Buzawy pelne' WHERE comm='pl_info';"
        PL_STAN=4
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
    else
        if [ $EZ_BUZ_CNT -eq $EZ_BUZ_TIM ] ; then
            gpo_out "ez_buz" 1
            PL_STAN=3
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Napełnianie wodą buzaw' WHERE comm='pl_info';"
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
        fi
        EZ_BUZ_CNT=$(( EZ_BUZ_CNT-1 ))
    fi
}

function plukanie(){
    if [ $TRYB -eq 0 ] ; then # PLUKANIE NA START
        echo "plukanie na START"
        if [ $PL_START_CNT -lt $PL_START_N ] ; then
            if [ $PL_STAN -lt 4 ] ; then
                if [ $PL_STAN -lt 2 ] ; then
                    if [ $PL_STAN -eq 0 ] && [ $PMP_BUZ_CNT -eq 0 ] ; then
                        PMP_BUZ_CNT=$PMP_BUZ_TIM
                        echo "wylewanie"
                    fi
                    wylewanie
                else
                    if [ $PL_STAN -eq 2 ] && [ $EZ_BUZ_CNT -eq 0 ] ; then
                        EZ_BUZ_CNT=$EZ_BUZ_TIM
                        echo "napelnianie"
                    fi
                    napelnianie
                fi
            else
                PL_STAN=0
                PL_START_CNT=$(( PL_START_CNT+1 ))
            fi
        else
            if [ $PL_STAN -eq 0 ] ; then
                echo "rozpoczecie garowania"
                TRYB=1
            fi
        fi
    fi
    if [ $TRYB -eq 2 ] ; then # PLUKANIE NA STOP
        echo "plukanie na STOP"
        echo "stop_cnt $PL_STOP_CNT  stop_n $PL_STOP_N"
        if [ $PL_STOP_CNT -lt $PL_STOP_N ] ; then
            if [ $PL_STAN -lt 4 ] ; then
                if [ $PL_STAN -lt 2 ] ; then
                    if [ $PL_STAN -eq 0 ] && [ $PMP_BUZ_CNT -eq 0 ] ; then
                        PMP_BUZ_CNT=$PMP_BUZ_TIM
                        echo "wylewanie"
                    fi
                    wylewanie
                else
                    if [ $PL_STAN -eq 2 ] && [ $EZ_BUZ_CNT -eq 0 ] ; then
                        EZ_BUZ_CNT=$EZ_BUZ_TIM
                        echo "napelnianie"
                    fi
                    napelnianie
                fi
            else
                PL_STAN=0
                PL_STOP_CNT=$(( PL_STOP_CNT+1 ))
            fi
        else
            if [ $PL_STAN -eq 0 ] ; then
                echo "rozpoczecie garowania"
                TRYB=3
            fi
        fi
    fi
}

function wentylator(){
     if [ -z ${1+x} ] ; then
        log_sys "er" "setowanie wentylatorem bez stanu"
    else
        if [ $WENT_STAN -ne $1 ] ; then
            WENT_STAN=$1
            gpo_out "went" $1
            local info=NULL
            if [ $1 -eq 1 ] ; then
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Praca nadmuch', valu=$1 WHERE comm='buz_stan';"
            else
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info=NULL, valu=$1 WHERE comm='buz_stan';"
            fi
        fi
    fi
}

function buzawa(){
    if [ -z ${1+x} ] ; then
        log_sys "er" "setowanie buzawy bez stanu"
    else
        if [ $BUZ_STAN -ne $1 ] ; then
            BUZ_STAN=$1
            gpo_out "buz" $1
            local info=NULL
            if [ $1 -eq 1 ] ; then
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Praca buzawy', valu=$1 WHERE comm='buz_stan';"
            else
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info=NULL, valu=$1 WHERE comm='buz_stan';"
            fi
        fi
    fi
}

tcnt=4

while [ 1 ] ; do
    if [ $TRYB -eq -1 ] ; then
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Inicjalizacja systemu' WHERE comm='tryb_info';"
        gpio_init
        pl_init
        TRYB=0
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$TRYB WHERE comm='tryb';"
    fi
    if [ $TRYB -eq 1 ] ; then
        if [ $tcnt -gt 0 ] ; then
            echo "PRACA"
            tcnt=$(( tcnt-1 ))
        else
            TRYB=2
        fi
    fi
    plukanie
    echo "tryb=$TRYB PL_STAN=$PL_STAN"
     sleep 1
done
