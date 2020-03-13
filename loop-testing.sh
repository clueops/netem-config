
DELAYS="1ms 30ms 80ms 130ms 180ms 230ms"

for DELAY in $DELAYS
do
    echo ""
    echo "- Delay is $DELAY"
done

echo $($DELAYS | shuf | DELAY_SHUF)