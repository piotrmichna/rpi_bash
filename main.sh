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
    
    while [ 1 ] ; do
        local SEC=$(date '+%-S')
        echo $SEC
        gpio_get 12 # sprawdzenie stanu pinu sensora opisanym tablei item pod id=13
        
        if [ $? -lt 2 ] ; then
            echo "stan -> $?"
        else
            echo "gpio nie jest sensorem"
        fi
        sleep 1
    done
}
main
