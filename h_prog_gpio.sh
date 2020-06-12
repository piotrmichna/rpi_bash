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

function gpio_get_data(){
    #echo "gpio_mysql_data"
    #start_test
    local tmp=$(echo "SELECT id FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_ID=( $( for i in $tmp ;do echo $i ;done ) )
    GP_NUM=${#GP_ID[@]}

    tmp=$(echo "SELECT typid FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_TYPID=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT gpio FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_GPIO=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT dir FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_DIR=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT stan FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_STAN=( $( for i in $tmp ;do echo $i ;done ) )

    tmp=$(echo "SELECT stan_act FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_STAN_ACT=( $( for i in $tmp ;do echo $i ;done ) )

    #----pobieranie nazw gpio----------
    for (( i=0 ; i<GP_NUM ; i++ )) ; do
        tmp=$(echo "SELECT nazwa FROM item WHERE id=${GP_ID[$i]}" | mysql -D$DB -u $USER -p$PASS -N)
        GP_NAZ[$i]=${tmp[0]}
    done

    #------pobieranie nazw typow--------
    for (( i=0 ; i<GP_NUM ; i++ )) ; do
        tmp=$(echo "SELECT nazwa FROM item_typ WHERE id=${GP_TYPID[$i]}" | mysql -D$DB -u $USER -p$PASS -N)
        GP_TYPNAZ[$i]=${tmp[0]}
    done
    #stop_test
}

function gpio_list(){
  for (( i=0 ; i<GP_NUM ; i++ )) ; do
    echo "id=${GP_ID[$i]} nazwa=${GP_NAZ[$i]} typid=${GP_TYPID[$i]} gpio=${GP_GPIO[$i]} dir=${GP_DIR[$i]} stan=${GP_STAN[$i]} act(${GP_STAN_ACT[$i]}"
  done
}

function gpio_init(){
    gpio_get_data #pobranie parametru gpio z bazy danych
    #start_test
    for (( i=0 ; i<GP_NUM ; i++ )) ; do
    if [ ${GP_DIR[$i]} -eq 1 ] ; then # wyjści sterujące
      if [ ${GP_STAN_ACT[$i]} -eq 1 ] ; then
        gpio write ${GP_GPIO[$i]} 0 #pulup GND
      else
        gpio write ${GP_GPIO[$i]} 1 #pulup Vcc
      fi
      gpio mode ${GP_GPIO[$i]} out #kierunek wyjściowy
    else  # wejście pomiaru
      if [ ${GP_STAN_ACT[$i]} -eq 1 ] ; then
        gpio mode ${GP_GPIO[$i]} down #pulup GND
      else
        gpio mode ${GP_GPIO[$i]} up #pulup Vcc
      fi
      gpio mode ${GP_GPIO[$i]} in #kierunek wejściowy
    fi
  done
  #stop_test
}

