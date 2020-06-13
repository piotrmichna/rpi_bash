#!/bin/bash
#___main.sh___

source /home/pi/homster4/h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
source /home/pi/homster4/_test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test
source /home/pi/homster4/h_prog.sh
source /home/pi/homster4/h_sys.sh


function main(){
    log_sys "START SYSTEMU"

    while [ 1 ] ; do
        #start_test
        prog_event
        #stop_test
        if [ $PR_ID -lt 0 ] ; then
            sys_event
        fi
        sleep 1
        if [ $SYS_RELOAD -eq 1 ] ; then
            echo "przeładowanie systemu"
            SYS_RELOAD=0
        fi
    done
}

main