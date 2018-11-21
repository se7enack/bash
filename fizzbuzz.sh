#!/bin/bash

fb=1

while [ $fb -le 100 ]
do
  if [[ 0 -eq "($fb%3) + ($fb%5)" ]] 
  then
    echo "fizzbuzz"
  elif [[ 0 -eq "($fb%3)" ]]
  then
    echo "fizz"
  elif [[ 0 -eq "($fb%5)" ]]
  then
    echo "buzz"
   else
    echo "${fb}"
   fi	
  fb=$(( ${fb} + 1 ))
done
