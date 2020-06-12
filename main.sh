#!/bin/bash
#___main.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test
source h_prog.sh


function main(){
    log_sys "START SYSTEMU"

    while [ 1 ] ; do
        prog_event
        sleep 1
    done
}

main
