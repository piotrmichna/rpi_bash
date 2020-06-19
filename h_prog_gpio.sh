#!/bin/bash
#___h_prog_gpio.sh___

source h_log.sh #funkcje zapisu informacj zdazen do bazy danych
# log_sys "er" "blędna informacja"
# log_sys "poprawna informacja"
# log_gp "er" GPIO STAN "blędna informacja"
# log_gp GPIO STAN "poprawna informacja"

GP_NUM=-1
GP_ID[0]=0
GP_NAZ[0]=""
GP_GPIO[0]=0
GP_DIR[0]=0
GP_STAN[0]=0
GP_STAN_ACT[0]=0
GP_DELAY[0]=0
GP_CNT[0]=0

function sensor(){
    # STAN = sensor "NAZWA"
    if [ -z ${1+x} ] ; then
        log_sys "er" "sensor bez parametru"
        echo "-1"
    else
        local GID=0

        for (( i=0 ; i<GP_NUM ; i++ )) ; do
            if [ ${GP_NAZ[$i]} = $1 ] ; then
                GID=$i
                break;
            fi
        done
        local ret=$( gpio read ${GP_GPIO[$GID]} )
        if [ $ret -ne ${GP_STAN[$GID]} ] ; then
            GP_STAN[$GID]=$ret
            if [ ${GP_STAN[$GID]} -eq ${GP_STAN_ACT[$GID]} ] ; then
                log_gp "${GP_GPIO[$GID]}" "$ret" "stan poprawny"
            else
                echo
                log_gp "${GP_GPIO[$GID]}" "$ret" "stan negatywny"
            fi
            mysql -D$DB -u $USER -p$PASS -N -e"UPDATE item SET stan=${GP_STAN[$GID]} WHERE id=${GP_ID[$GID]};"
        fi
         if [ ${GP_STAN[$GID]} -eq ${GP_STAN_ACT[$GID]} ] ; then
            echo "1"
        else
            echo "0"
        fi
    fi
}

function gpo_out(){
    # gpo_out "naz" STAN[ 1=on 0=off ]
    if [ -z ${1+x} ] && [ -z ${2+x} ] ; then
        log_sys "er" "fun. gpo_out bez podania parametrów"
    else
        local GID=0
        local STAN=$2
        for (( i=0 ; i<GP_NUM ; i++ )) ; do
            if [ ${GP_NAZ[$i]} = $1 ] ; then
                GID=$i
                break;
            fi
        done
        # dostosowanie stanow wlaczenia do polaryzacji
        if [ ${GP_STAN_ACT[$GID]} -ne 1 ] ; then
            if [ $STAN -eq 1 ] ; then
                STAN=0
            else
                STAN=1
            fi
        fi
        if [ ${GP_DIR[$GID]} -eq 1 ] ; then
            if [ $STAN -ne ${GP_STAN[$GID]} ] ; then # zmiana stanu wyjscia jest mozliwa
                gpio write ${GP_GPIO[$GID]} $STAN
                GP_STAN[$GID]=$STAN
                mysql -D$DB -u $USER -p$PASS -N -e"UPDATE item SET stan=$STAN WHERE id=${GP_ID[$GID]};"
                if [ $2 -eq 1 ] ; then # stan ON
                    log_gp "${GP_GPIO[$GID]}" "$STAN" "${GP_NAZ[$GID]} - on"
                else # stan OFF
                    log_gp "${GP_GPIO[$GID]}" "$STAN" "${GP_NAZ[$GID]} - off"
                fi #stan
            else
                # gpio nie jest wyjsciem
                log_gp "er" "${GP_GPIO[$GID]}" "$STAN" "${GP_NAZ[$GID]} - ponowny ustawienie stanu"
            fi
        else
            log_gp "er" "${GP_GPIO[$GID]}" "$STAN" "${GP_NAZ[$GID]} - nie jest wyscie"
        fi
    fi
}

function gpio_get_data(){
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

    tmp=$(echo "SELECT delay_s FROM item WHERE en>0 ORDER BY id" | mysql -D$DB -u $USER -p$PASS -N)
    GP_DELAY=( $( for i in $tmp ;do echo $i ;done ) )

    #----pobieranie nazw gpio----------
    for (( i=0 ; i<GP_NUM ; i++ )) ; do
        tmp=$(echo "SELECT nazwa FROM item WHERE id=${GP_ID[$i]}" | mysql -D$DB -u $USER -p$PASS -N)
        GP_NAZ[$i]=${tmp[0]}
    done
}

function gpio_list(){
  for (( i=0 ; i<GP_NUM ; i++ )) ; do
    echo "id=${GP_ID[$i]} nazwa=${GP_NAZ[$i]} typid=${GP_TYPID[$i]} gpio=${GP_GPIO[$i]} dir=${GP_DIR[$i]} stan=${GP_STAN[$i]} act(${GP_STAN_ACT[$i]}"
  done
}

function gpio_init(){
    log_sys "GPIO - inicjacja"
    gpio_get_data #pobranie parametru gpio z bazy danych
    for (( i=0 ; i<GP_NUM ; i++ )) ; do
    if [ ${GP_DIR[$i]} -eq 1 ] ; then # wyjści sterujące
      if [ ${GP_STAN_ACT[$i]} -eq 1 ] ; then
        gpio write ${GP_GPIO[$i]} 0 #pulup GND
        GP_STAN[$i]=0
      else
        gpio write ${GP_GPIO[$i]} 1 #pulup Vcc
        GP_STAN[$i]=1
      fi
      gpio mode ${GP_GPIO[$i]} out #kierunek wyjściowy
    else  # wejście pomiaru

      if [ ${GP_STAN_ACT[$i]} -eq 1 ] ; then
        gpio mode ${GP_GPIO[$i]} up #pulup GND
        GP_STAN[$i]=1
      else
        gpio mode ${GP_GPIO[$i]} down #pulup Vcc
        GP_STAN[$i]=0
      fi
      gpio mode ${GP_GPIO[$i]} in #kierunek wejściowy
    fi
  done
}

