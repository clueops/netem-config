DELAYS="1ms 30ms 80ms 130ms 180ms 230ms"

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