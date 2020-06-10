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
  CUR_DAT=$(date +"%F")
  CUR_TIM=$(date +"%T")
  mysql -u $USER -p$PASS -D$DBH -e"INSERT INTO syst (id, dat, tim, opis) VALUES (NULL, '${CUR_DAT}', '${CUR_TIM}', '${1}');"
}
