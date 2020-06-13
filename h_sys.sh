#!/bin/bash
#___h_sys.sh___

source h_log.sh
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"

SYS_NUM=0
SYS_ID[0]=0
SYS_COM[0]=""
SYS_VAL[0]=0

function sys_init(){
    local tmp=$(echo "SELECT COUNT(1) FROM cnf WHERE syst=1 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    SYS_NUM=${tmp[0]}
    if [ $SYS_NUM -gt 0 ] ; then
        tmp=$(echo "SELECT id FROM cnf WHERE syst=1 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
        SYS_ID=( $( for i in $tmp ;do echo $i ;done ) )
        tmp=$(echo "SELECT comm FROM cnf WHERE syst=1 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
        SYS_COM=( $( for i in $tmp ;do echo $i ;done ) )
        tmp=$(echo "SELECT valu FROM cnf WHERE syst=1 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
        SYS_VAL=( $( for i in $tmp ;do echo $i ;done ) )
    fi
}
