#!/bin/bash
#___h_prog_gpio.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja" 
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja" 
# log_gp GPIO STAN "poprawna informacja" 
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test

GP_NUM=0
GP_ID[0]=0
GP_NAZ[0]=""
GP_TYPID[0]=0
GP_TYPNAZ[0]=""
GP_GPIO[0]=0
GP_DIR[0]=0
GP_STAN[0]=0
GP_STAN_ACT[0]=0
