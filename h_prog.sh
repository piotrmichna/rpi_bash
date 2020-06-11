#!/bin/bash
#___h_prog.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja" 
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja" 
# log_gp GPIO STAN "poprawna informacja" 
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
PR_ITEM_NUM=0
PR_LP=-1
PR_NAZ=""

function get_next_prog(){
    if [ $PR_ID -gt 0 ] ; then
        local tmp=$(echo "SELECT COUNT(1) FROM prog_item WHERE progid=$PR_ID" | mysql -D$DB -u $USER -p$PASS -N)
        PR_ITEM_NUM=${tmp[0]}
        if [ $PR_ITEM_NUM -gt 0 ] ; then        
            tmp=$(echo "SELECT nazwa FROM prog WHERE id=$PR_ID" | mysql -D$DB -u $USER -p$PASS -N)
            PR_NAZ=${tmp[0]}
        else
            log_sys "er"  "wywolanie pustego programu"
        fi
        
    else
        PR_NEXT_TIM=""
        PR_NEXT_TIM_SEC=-1
        PR_NEXT_TIM_ELSP=""
        PR_NEXT_PROG_ID=-1
        PR_ID=-1
        PR_LP=-1
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
    PR_NEXT_TIM_ELSP=$(sec_to_str $TE)
    echo "$TE"   
}

function get_next_start(){
    local TNOW=$(date +"%T")
    local tmp=$(echo "SELECT COUNT(1) FROM start_time WHERE tim>'$TNOW' ORDER BY tim" | mysql -D$DB -u $USER -p$PASS -N)
    PR_START_NUM=${tmp[0]}   
    tmp=$(echo "SELECT tim FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
    PR_NEXT_TIM=${tmp[0]}   
     tmp=$(echo "SELECT id FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
    PR_NEXT_PROG_ID=${tmp[0]}   
    #tsn=`date --date="$TNOW" +%s`
    #tss=`date --date="$PR_NEXT_START_TIM" +%s`
    #tse=$(( tss-tsn ))
    
    #xt=$( sec_to_str $tse )
    #echo "pozostały czas do startu to: $xt"
}
