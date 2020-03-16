#!/bin/bash

DELAYS="1 30 80 130 180 230"
shuffle="1"

echo "Normal"
for DELAY in $DELAYS
do
    echo "- Delay is $DELAY"
done

DELAYS_SHUF=$(shuf -e $DELAYS)

echo "Random"
for DELAY in $DELAYS_SHUF
do
    echo "- Delay is $DELAY"
done


if [ "$shuffle" -eq 1 ]
then
echo $shuffle
else
echo no
fi
