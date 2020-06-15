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
    if [ "$1" = "er" ] ; then
        local ER=1
        local OPI="$2"
        echo "${CUR_TIM} - $OPI"
    else
        local ER=0
        local OPI="$1"
    fi
    mysql -u $USER -p$PASS -D$DBH -e"INSERT INTO syst (id, dat, tim, opis, er) VALUES (NULL, '${CUR_DAT}', '${CUR_TIM}', '$OPI', $ER);"
}

function log_gp(){
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"
    if [ "$1" = "er" ] ; then
        local ER=1
        local GPIO=$2
        local STAN=$3
        local OPI="$4"
        echo "${CUR_TIM} g[${GPIO}] s[${STAN}]- $OPI"
    else
        local ER=0
        local GPIO=$1
        local STAN=$2
        local OPI="$3"
    fi
  CUR_DAT=$(date +"%F")
  CUR_TIM=$(date +"%T")
  mysql -u $USER -p$PASS -D$DBH -e"INSERT INTO gpio (id, dat, tim, gpio, stan, opis, er) VALUES (NULL, '${CUR_DAT}', '${CUR_TIM}', $GPIO, $STAN, '$OPI', $ER);"
}
