#!/bin/bash

# Script to drive NetEm and provide changing network conditions on a schedule

: '
 Script usage:
 ./netem-config-run.sh			        	: output to screen only
 ./netem-config-run.sh | tee <logfile.log>	: output to screen and log file <logfile.log>

 Script options:
  -r                : (optional) randomise/shuffle the order of the Delay, Jitter and Loss values from within each of the variable lists. The default behaviour is to loop through these values in the order they appear in the list.
  -t <duration>     : (optional) specify the active time period for each of the specified NetEm network conditions before the script loops to the next set of conditions. The default behaviour is to read the value of $DURATION from the params file.
'

# Load parameters file with required variables
source netem-config-params.sh

# Read any supplied command line options
while [ -n "$1" ]; do
	case "$1" in
	-r)
        RANDOM="yes"
        echo "-r option passed"
        ;;
	-d)
		DURATION="$2"
		echo "-d option passed, with value $DURATION"
		shift
		;;
	*) echo "Option $1 not recognized" ;;
	esac
	shift
done

# Set the network condition variables to use for this run, shuffle the order of values if requested
if [ $RANDOM = "yes" ]
then
    DELAYS_RUN=$(shuf -e $DELAY_PARAMS)
    JITTER_RUN=$(shuf -e $JITTER_PARAMS)
    LOSS_RUN=$(shuf -e $LOSS_PARAMS)
else
    DELAY_RUN=$DELAY_PARAMS
    JITTER_RUN=$JITTER_PARAMS
    LOSS_RUN=$LOSS_PARAMS
fi

# Start NetEm run here
echo "Starting NetEm run..."
echo $(date -u)

# Remove any pre-existing active NetEm config
# sudo tc qdisc del dev $IN_INTERFACE root
# sudo tc qdisc del dev $OUT_INTERFACE root

# Main loops start here - loop by Delay > Jitter > Loss

# Delay loop
for DELAY in $DELAY_RUN
do
    echo ""
    echo "- Delay is ${DELAY}ms"
    IN_DELAY="$((DELAY/2))ms"
    OUT_DELAY="$((DELAY/2))ms"

    # Jitter loop
    for JITTER in $JITTER_RUN
    do
        JITTER="${JITTER}ms"
        echo "  - Jitter is $JITTER"

        # Loss loop
        for LOSS in $LOSS_RUN
        do
            echo "    - Loss is ${LOSS}%"

            # Set new NetEm conditions on Inside interface (for inbound traffic)
            if [ $JITTER = 0 ]
		    then
#			    sudo tc qdisc add dev $IN_INTERFACE root netem delay $IN_DELAY loss $LOSS
		    else
#			    sudo tc qdisc add dev $IN_INTERFACE root netem delay $IN_DELAY $JITTER 25% distribution normal loss $LOSS
		    fi

            # Set new NetEm conditions on Outside interface (for outbound traffic)
#            sudo tc qdisc add dev $OUT_INTERFACE root netem delay $OUT_DELAY

            # Display current NetEm conditions (sanity check)
            echo -n "        * $(date -u)"
            sudo tc qdisc show dev $IN_INTERFACE | awk '{print "  : IN   ->   "$0}'
            echo -n "        * $(date -u)"
            sudo tc qdisc show dev $OUT_INTERFACE | awk '{print "  : OUT   ->   "$0}'
            
            # Leave the new network conditions in place for agreed time duration
            sleep $DURATION
            # Remove the current NetEm config in preparation for next loop (NetEm does not allow changing directly from one condition to another)
#            sudo tc qdisc del dev $IN_INTERFACE root
#            sudo tc qdisc del dev $OUT_INTERFACE root
        done
    
    done

done

# Finish
echo ""
echo $(date -u)
echo "Finished NetEm run!"

