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
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test

TNOW=$(date +"%T") #zminna zawierający aktualny czas
NEW_DAY=-1
PR_START_NUM=-1
PR_NEXT_TIM=""
PR_NEXT_TIM_SEC=0
PR_NEXT_TIM_CNT=-1
PR_NEXT_TIM_ELSP=""
PR_NEXT_PROG_ID=-1
PR_ID=-1
PR_NAZ=""

PR_ITEM_NUM=0
PR_ITEM_LP=-1
PR_ITEM_ID[0]=0
PR_ITEM_PAR[0]=0
PR_ITEM_DELAY[0]=0
PR_ITEM_CNT[0]=0

function end_prog(){
    PR_NEXT_TIM=""
    PR_NEXT_TIM_SEC=-1
    PR_NEXT_TIM_CNT=-1
    PR_NEXT_TIM_ELSP=""
    PR_NEXT_PROG_ID=-1
    PR_ID=-1
    PR_NAZ=""
    # zmienne urzadzen
    PR_ITEM_LP=-1
    PR_ITEM_NUM=0
    PR_ITEM_ID[0]=0
    PR_ITEM_PAR[0]=0
    PR_ITEM_DELAY[0]=0
    PR_ITEM_CNT[0]=0

    if [ $PR_START_NUM -gt 0 ] ; then # sprawdz czy jest kolejny start
        get_next_start
    fi
}

function get_prog_item(){
    local tmp=$(echo "SELECT itemid FROM prog_item WHERE progid=$PR_ID ORDER BY lp" | mysql -D$DB -u $USER -p$PASS -N)
    PR_ITEM_ID=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT parale FROM prog_item WHERE progid=$PR_ID ORDER BY lp" | mysql -D$DB -u $USER -p$PASS -N)
    PR_ITEM_PAR=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT delay_s FROM prog_item WHERE progid=$PR_ID ORDER BY lp" | mysql -D$DB -u $USER -p$PASS -N)
    PR_ITEM_DELAY=( $( for i in $tmp ;do echo $i ;done ) )
    # pobieranie wlasnosci item
    for (( i=0 ; i<PR_ITEM_NUM ; i++ )) ; do
        echo "pobierz inf dla gpio o id=${PR_ITEM_ID[$i]}"
    done
    # zerowanie kolejnosci elementow programu
    PR_ITEM_LP=0
}

function begin_prog(){
    if [ $PR_ID -gt 0 ] ; then
        local tmp=$(echo "SELECT COUNT(1) FROM prog_item WHERE progid=$PR_ID" | mysql -D$DB -u $USER -p$PASS -N)
        PR_ITEM_NUM=${tmp[0]}
        if [ $PR_ITEM_NUM -gt 0 ] ; then
            tmp=$(echo "SELECT nazwa FROM prog WHERE id=$PR_ID" | mysql -D$DB -u $USER -p$PASS -N)
            PR_NAZ=${tmp[0]}
            get_prog_item
        else
            log_sys "er"  "wywolanie pustego programu"
            end_prog
        fi
    else
        log_sys "KONIEC programu [ $PR_NAZ ]"
        end_prog
    fi
}

function sec_to_str(){
    local T=$1
    local H=$(( T/3600 ))
    local X=$(( H*3600 )) ; T=$(( T-X ))
    local M=$(( T/60 )) ; X=$(( M*60 )) ; T=$(( T-X ))
    local S=$(( T%60 ))

    if [ $H -lt 10 ] ; then local tim_str=$(echo "0$H:") ; else local tim_str=$(echo "$H:") ; fi
    if [ $M -lt 10 ] ; then tim_str=$(echo "${tim_str}0$M:") ; else tim_str=$(echo "${tim_str}$M:") ; fi
    if [ $S -lt 10 ] ; then tim_str=$(echo "${tim_str}0$S") ; else tim_str=$(echo "${tim_str}$S") ; fi
    echo "$tim_str"
}

function is_time_now(){
    local TIX=`date --date="$1" +%s`
    local TN=$(date +"%T")
    local TNW=`date --date="$TN" +%s`
    local TE=$(( TIX-TNW ))
    PR_NEXT_TIM_SEC=$TE
    PR_NEXT_TIM_ELSP=$( sec_to_str $TE )
    echo "$TE"
}

function get_next_start(){
    local TNOW=$(date +"%T")
    local tmp=$(echo "SELECT COUNT(1) FROM start_time WHERE tim>'$TNOW' ORDER BY tim" | mysql -D$DB -u $USER -p$PASS -N)
    PR_START_NUM=${tmp[0]}
    echo "ilosc startow $PR_START_NUM"
    if [ $PR_START_NUM -gt 0 ] ; then
        tmp=$(echo "SELECT tim FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
        PR_NEXT_TIM=${tmp[0]}
        tmp=$(echo "SELECT progid FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
        PR_NEXT_PROG_ID=${tmp[0]}
        PR_NEXT_TIM_SEC=$( is_time_now "$PR_NEXT_TIM" )
        PR_NEXT_TIM_CNT=$(( PR_NEXT_TIM_SEC/2 ))
    else
        PR_NEXT_TIM=""
        R_NEXT_PROG_ID=-1
    fi
    #tsn=`date --date="$TNOW" +%s`
    #tss=`date --date="$PR_NEXT_START_TIM" +%s`
    #tse=$(( tss-tsn ))

    #xt=$( sec_to_str $tse )
    #echo "pozostały czas do startu to: $xt"
}

function wait_for_prog_start(){
    if [ $PR_START_NUM -gt 0 ] ; then # są planowane starty
        if [ $PR_ID -gt 0 ] ; then # program aktywny
            echo "program run"
        else # oczekiwanie na program
            echo "wait for program -> sec: $PR_NEXT_TIM_SEC cnt: $PR_NEXT_TIM_CNT"
            if [ $PR_NEXT_TIM_SEC -gt 10 ] ; then # ilosc sekund do startu >10
                if [ $PR_NEXT_TIM_CNT -eq 0 ] ; then # akutalizacja ilosci sekund do startu
                    PR_NEXT_TIM_SEC=$( is_time_now "$PR_NEXT_TIM" )
                    PR_NEXT_TIM_CNT=$(( PR_NEXT_TIM_SEC/2 ))
                else # odliczanie
                    PR_NEXT_TIM_SEC=$(( PR_NEXT_TIM_SEC-1 ))
                    PR_NEXT_TIM_CNT=$(( PR_NEXT_TIM_CNT-1 ))
                fi
            else # ilosc sekund do startu <10
                PR_NEXT_TIM_SEC$( is_time_now "$PR_NEXT_TIM" )
                if [ $PR_NEXT_TIM_SEC -lt 1 ] ; then
                    PR_ID=$PR_NEXT_PROG_ID
                    echo "start programu o id=$PR_ID"
                    #wywolanie planowanego programu
                    begin_prog
                fi
            fi
        fi # oczekiwanie na program
    else # brak startow biezacego dnia
        if [ $NEW_DAY -ne $(date +'%-j') ] ; then # oczekiwanie na nastepny dzien
            echo "nowy dzien"
            if [ $GP_NUM -eq -1 ] ; then
                gpio_init
            fi
            get_next_start
            NEW_DAY=$(date +"%-j")
        fi # ilosc startow
    fi # planowane starty
}

function prog_event(){
    if [ $PR_ITEM_LP -eq -1 ] ; then # program nie aktywny
        wait_for_prog_start
    else # program aktywny
        echo "praca programu"
        end_prog
    fi
}
