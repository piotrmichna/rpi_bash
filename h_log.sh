#!/bin/bash
#___h_log.sh___

USER="pituEl"
PASS="hi24biscus"
DB="homster"
DBH="homhist"

#---zmienne globalen daty i czasu
CUR_DAT=$(date +"%F")
CUR_TIM=$(date +"%T")

function log_sys(){ 
# log_sys "er" "blędna informacja" 
# log_sys "poprawna informacja"
CUR_DAT=$(date +"%F")
CUR_TIM=$(date +"%T")
    if [ $1 = "er" ] ; then
        local ER=1
        local OPI="$2"
    else
        local ER=0
        local OPI="$1"
    fi
    mysql -u $USER -p$PASS -D$DBH -e"INSERT INTO syst (id, dat, tim, opis, er) VALUES (NULL, '${CUR_DAT}', '${CUR_TIM}', '$OPI', $ER);"
}

function log_gp(){
  CUR_DAT=$(date +"%F")
  CUR_TIM=$(date +"%T")
  mysql -u $USER -p$PASS -D$DBH -e"INSERT INTO gpio (id, dat, tim, gpio, stan, opis) VALUES (NULL, '${CUR_DAT}', '${CUR_TIM}', ${1}, ${2}, '${3}');"
}
