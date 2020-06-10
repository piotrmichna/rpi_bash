#!/bin/bash
#___main.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "tresc informacji"
# log_gp gpio stan "informacja"
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test
source h_gpio_init.sh #funkcje zwiazane z obsługą gpio
#gpio_init
#gpio_list
#gpio_get "ID sensroa z tabeli item"
#gpio_set "ID wyjscia z tabeli item" "stan 1 lub 0"


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
        gpio_gt 13  # sprawdzenie stanu pinu sensora opisanym tablei item pod id=13
        #wyk=$?
        if [ $wyk -lt 2 ] ; then
            echo "stan -> $wyk"
        else
            echo "gpio nie jest sensorem"
        fi
        
        if [ $(( n%20 )) -eq 0 ] ; then
            gpio_set 3 0
        else
            gpio_set 3 1
        fi        
        n=$(( n+1 ))
        sleep 1
    done
}
main
