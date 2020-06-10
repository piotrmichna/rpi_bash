#!/bin/bash
#___h_init.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "tresc informacji"
# log_gp gpio stan "informacja"
source _test.sh #funkcje testujace czas wykonywania skryptu
# start_test
# stop_test

GP_NUM=0
GP_ID[0]=0
GP_GPIO[0]=0
GP_DIR[0]=0
GP_STAN[0]=0
GP_STAN_ACT[0]=0
