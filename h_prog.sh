#!/bin/bash
#___h_prog.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "tresc informacji"
# log_gp gpio stan "informacja"
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test

TNOW=$(date +"%T") #zminna zawierający aktualny czas
PR_START_NUM=0
PR_NEXT_START_TIM=""
PR_NEXT_PROG_ID=0

function get_next_start(){
    TNOW=$(date +"%T")
    local tmp=$(echo "SELECT COUNT(1) FROM start_time WHERE tim>'$TNOW' ORDER BY tim" | mysql -D$DB -u $USER -p$PASS -N)
    PR_START_NUM=${tmp[0]}   
    tmp=$(echo "SELECT tim FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
    PR_NEXT_START_TIM=${tmp[0]}   
     tmp=$(echo "SELECT id FROM start_time WHERE tim>'$TNOW' ORDER BY tim LIMIT 1" | mysql -D$DB -u $USER -p$PASS -N)
    PR_NEXT_PROG_ID=${tmp[0]}   
    #tsn=`date --date="$TNOW" +%s`
    #tss=`date --date="$PR_NEXT_START_TIM" +%s`
    #tse=$(( tss-tsn ))
}
