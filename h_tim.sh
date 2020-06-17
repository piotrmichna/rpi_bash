#!/bin/bash
#_____h_time.sh

TIM_A=$(date +"%-s")
echo "    TIM_A[s]= $TIM_A"
temp=$(date -d @$TIM_A "+%F %T")
echo "TIM_A[%F %T]= $temp"

sleep 12

TIM_B=$(date +"%-s")
echo "    TIM_B[s]= $TIM_B"
temp=$(date -d @$TIM_B "+%F %T")
echo "TIM_B[%F %T]= $temp"
echo "________"

TIM_MID=$(( TIM_B-TIM_A ))
TIM_MID=$(( TIM_MID/2 ))
TIM_MID=$(( TIM_A+TIM_MID ))

echo "    TIM_A[s]= $TIM_A"
echo "  TIM_MID[s]= $TIM_MID"
echo "    TIM_B[s]= $TIM_B"
echo "_"
temp=$(date -d @$TIM_A "+%F %T")
echo "  TIM_A[%F %T]= $temp"
temp=$(date -d @$TIM_MID "+%F %T")
echo "TIM_MID[%F %T]= $temp"
temp=$(date -d @$TIM_B "+%F %T")
echo "  TIM_B[%F %T]= $temp"
