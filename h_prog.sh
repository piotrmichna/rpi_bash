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
source h_weather.sh

TNOW=$(date +"%T") #zminna zawierający aktualny czas
TRYB=-1 # -1 inicjalizacja 0 plukanie start 1 praca 2 plukanie na koniec 3 koniec

EZ_BUZ_TIM=0         #czas napelnienia buzaw
PMP_BUZ_TIM=0    #czas oproznienia buzaw
PL_START_N=0          # ilosc plukan na starcie
PL_STOP_N=0            #ilosc plukani na stop
PL_STAN=0                 # stan funkcji plukania 0=START WYLEWANIA 1= WYLEANIE 2= KONIEC WYLEWANIA 3= NAPELNIANIE 4=KONIEC NAPELNIANIA

EZ_BUZ_CNT=0
EZ_BUZ_STAN=0
PMP_BUZ_CNT=0
PL_START_CNT=0
PL_STOP_CNT=0

BUZ_STAN=0
WENT_STAN=0
WENT_STOP_TIM=-1
WENT_STOP_CNT=0
WENT_ALL=1
GRZA_STAN=0
OSW_STAN=0
PRAD_BUZ=0
ZB_GRZA=0
SENS_NEW=0
ERR=0
TEMP=0
PWR=0
function prog_data(){
    local tmp=$(echo "SELECT valu FROM prog WHERE comm='ez_buz_time'" | mysql -D$DB -u $USER -p$PASS -N)
    EZ_BUZ_TIM=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pmp_buz_time'" | mysql -D$DB -u $USER -p$PASS -N)
    PMP_BUZ_TIM=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pl_start_n'" | mysql -D$DB -u $USER -p$PASS -N)
    PL_START_N=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='pl_stop_n'" | mysql -D$DB -u $USER -p$PASS -N)
    PL_STOP_N=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='wetn_stop_tim'" | mysql -D$DB -u $USER -p$PASS -N)
    WENT_STOP_TIM=${tmp[0]}
    tmp=$(echo "SELECT valu FROM prog WHERE comm='wetn_all" | mysql -D$DB -u $USER -p$PASS -N)
    WENT_ALL=1
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='temp_min'" | mysql -D$DBW -u $USER -p$PASS -N)
    T_MIN=${tmp[0]}
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='temp_max'" | mysql -D$DBW -u $USER -p$PASS -N)
    T_MAX=${tmp[0]}
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='humi_min'" | mysql -D$DBW -u $USER -p$PASS -N)
    H_MIN=${tmp[0]}
    tmp=$(echo "SELECT valu FROM cnf WHERE comm='humi_max'" | mysql -D$DBW -u $USER -p$PASS -N)
    H_MAX=${tmp[0]}
}
function pl_init(){
    mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET valu=$PL_STAN WHERE comm='pl_stan';"
    EZ_BUZ_TIM=0         #czas napelnienia buzaw
    PMP_BUZ_TIM=0    #czas oproznienia buzaw
    PL_START_N=0          # ilosc plukan na starcie
    PL_STOP_N=0            #ilosc plukani na stop
    PL_STAN=0                 # stan funkcji plukania 0=START WYLEWANIA 1= WYLEANIE 2= KONIEC WYLEWANIA 3= NAPELNIANIE 4=KONIEC NAPELNIANIA

    EZ_BUZ_CNT=0
    EZ_BUZ_STAN=0
    PMP_BUZ_CNT=0
    PL_START_CNT=0
    PL_STOP_CNT=0

    BUZ_STAN=0
    WENT_STAN=0
    WENT_STOP_TIM=-1
    WENT_STOP_CNT=0
    WENT_ALL=1
    GRZA_STAN=0
    OSW_STAN=0
    PRAD_BUZ=0
    ZB_GRZA=0
    SENS_NEW=0
    ERR=0
    TEMP=0
    PWR=0
    prog_data
}
function praca_init(){
    echo "praca_init"
    local tmp=$(echo "SELECT valu FROM prog WHERE comm='wetn_stop_tim'" | mysql -D$DB -u $USER -p$PASS -N)
    WENT_STOP_TIM=${tmp[0]}
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

function oswietlenie(){
        if [ -z ${1+x} ] ; then
        log_sys "er" "setowanie oświetleniem bez stanu"
    else
        if [ $OSW_STAN -ne $1 ] ; then
            OSW_STAN=$1
            gpo_out "osw" $1
            local info=NULL
            if [ $1 -eq 1 ] ; then
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Oświetlenie', valu=$1 WHERE comm='osw_stan';"
            else
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info=NULL, valu=$1 WHERE comm='osw_stan';"
            fi
        fi
    fi
}

function ogrzewanie(){
     if [ -z ${1+x} ] ; then
        log_sys "er" "setowanie ogrzewaniem bez stanu"
    else
        if [ $GRZA_STAN -ne $1 ] ; then
            GRZA_STAN=$1
            gpo_out "grza" $1
            local info=NULL
            if [ $1 -eq 1 ] ; then
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Praca nagrzewanie', valu=$1 WHERE comm='grza_stan';"
            else
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info=NULL, valu=$1 WHERE comm='grza_stan';"
            fi
        fi
    fi
}

function wentylator(){
     if [ -z ${1+x} ] ; then
        log_sys "er" "setowanie wentylatorem bez stanu"
    else
        local info=NULL
        if [ $1 -eq 1 ] ; then
            if [ $WENT_STAN -ne $1 ] ; then
                WENT_STAN=1
                WENT_STOP_CNT=$WENT_STOP_TIM
                WENT_STOP_CNT=$(( WENT_STOP_CNT-1 ))
                gpo_out "went" 1
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Praca nadmuch', valu=$1 WHERE comm='went_stan';"
            fi
        else
            if [ $WENT_STOP_CNT -eq 0 ] ; then
                WENT_STAN=0
                gpo_out "went" 0
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info=NULL, valu=$1 WHERE comm='went_stan';"
            else
                WENT_STOP_CNT=$(( WENT_STOP_CNT-1 ))
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

function prad_buzawa(){
    local tmp=$( echo `sensor "i_buz"` )
    if [ $tmp -ne $PRAD_BUZ ] ; then
        PRAD_BUZ=$tmp
        SENS_NEW=1
    fi
}

function power(){
     local tmp=$( echo `sensor "det_pwr"` )
    if [ $tmp -ne $PWR ] ; then
        PWR=$tmp
        SENS_NEW=1
    fi
}
function zb_grzalki(){
    local tmp=$( echo `sensor "zb_grza"` )
    if [ $tmp -ne $ZB_GRZA ] ; then
        ZB_GRZA=$tmp
        SENS_NEW=1
    fi
}

function temperatura(){
    weather_event
    zb_grzalki
    local tem=$( echo "${BME[0]}/1" | bc )
    if [ $tem -lt $T_MIN ] ; then
        if [ $ZB_GRZA -eq 1 ] ; then
            ogrzewanie 1

                wentylator 1

        fi
    fi
    if [ $ZB_GRZA -eq 0 ] ; then
        ogrzewanie 0
         if [ $WENT_ALL -eq 0 ] ; then
                wentylator 0
            fi
        ERR=1
        mysql -D$DB -u $USER -p$PASS -N -e"UPDATE prog SET info='Błąd zabezpieczenia grzałki' WHERE comm='er';"
    fi
    if [ $tem -gt $T_MAX ] ; then
        ogrzewanie 0
         if [ $WENT_ALL -eq 0 ] ; then
            wentylator 0
        fi
    fi
}

function wilgotnosc(){
    weather_event
    local wil=$( echo "${BME[2]}/1" | bc )
    if [ $wil -lt $H_MIN ] ; then
        buzawa 1
        wentylator 1
    fi
    if [ $BUZ_STAN -eq 1 ] ; then
        prad_buzawa
        if [ $PRAD_BUZ -eq 1 ] ; then
            gpo_out "ez_buz" 1
            EZ_BUZ_STAN=1
        else
            gpo_out "ez_buz" 0
            EZ_BUZ_STAN=0
        fi
    fi
    if [ $EZ_BUZ_STAN -eq 0 ] ; then
        if [ $BUZ_STAN -eq 1 ] ; then
            if [ $wil -gt $H_MAX ] ; then
                buzawa 0
                if [ $WENT_ALL -eq 0 ] ; then
                    gpo_out "ez_buz" 0
                fi
                BUZ_STAN=0
            fi
        fi
    fi
}
prace_sec=10
function data_refesh(){
    if [ $prace_sec -eq 0 ] ; then
        prog_data
        prace_sec=10
    else
        prace_sec=$(( prace_sec-1 ))
    fi
}
function praca(){
    temperatura
    wilgotnosc
    power
     if [ $WENT_ALL -eq 1 ] && [ $WENT_STAN -eq 0 ] ; then
        wentylator 1
    fi
    data_refesh
}

