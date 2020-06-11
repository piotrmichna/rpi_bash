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
source h_gpio_init.sh #funkcje zwiazane z obsługą gpio
#gpio_init
#gpio_list
#gpio_get "ID sensroa z tabeli item"
#gpio_set "ID wyjscia z tabeli item" "stan 1 lub 0"
source h_prog.sh

function init(){
    gpio_init
    log_sys "inicjalizacja gpio"
}

function main(){
    log_sys "START SYSTEMU"
    init
    gpio_list
    n=0
    while [ 1 ] ; do
        local SEC=$(date '+%-S')
        echo $SEC
        if [ $(( n%10 )) -eq 0 ] ; then
            get_next_start
            if [ $PR_START_NUM -gt 0 ] ; then
                local TNOW=$(date +"%T")
                echo "jest : $TNOW"
                echo "nastepny z[$PR_START_NUM] startow jest o: $PR_NEXT_START_TIM"
                ddd=$(is_time_now $PR_NEXT_START_TIM )
                aaa=$(sec_to_str $ddd)
                echo "i nastapi za: $ddd -> $aaa"
            fi
        fi
        n=$(( n+1 ))        
        sleep 1
    done
}
#main
while [ 1 ] ; do
    prog_event
    sleep 1
done
