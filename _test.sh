#!/bin/bash
#___test.sh___
START_S=0
START_N=0
STOP_S=0
STOP_N=0

function start_test(){
    echo "---->START_TEST"
    START_S=$(date +%s)
    START_N=$(date +%N)    
}

function stop_test(){
    STOP_S=$(date +%s)
    STOP_N=$(date +%N)
    SS=$(( START_S-1 ))
    START_S=$(( START_S-SS ))
    STOP_S=$(( STOP_S-SS ))
    START_N=$(( START_N/1000000 ))
    STOP_N=$(( STOP_N/1000000 ))
    START=$(echo "$START_S.$START_N")
    STOP=$(echo "$STOP_S.$STOP_N")
    WYN=$(echo "$STOP - $START" | bc )
    echo "----->STOP_TEST--> ${WYN}s"
}
