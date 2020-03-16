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
        random="yes"
        echo "-r option passed"
        ;;
	-d)
		duration="$2"
		echo "-d option passed, with value $duration"
		shift
		;;
	*) echo "Option $1 not recognized" ;;
	esac
	shift
done

# Set the network condition variables to use for this run, shuffle the order of values if requested
if [ $random = "yes" ]
then
    delays_run=$(shuf -e $delay_params)
    jitter_run=$(shuf -e $jitter_params)
    loss_run=$(shuf -e $loss_params)
else
    delay_run=$delay_params
    jitter_run=$jitter_params
    loss_run=$loss_params
fi

# Start NetEm run here
echo "Starting NetEm run..."
echo $(date -u)

# Remove any pre-existing active NetEm config
# sudo tc qdisc del dev $in_interface root
# sudo tc qdisc del dev $out_interface root

# Main loops start here - loop by Delay > Jitter > Loss

# Delay loop
for delay in $delay_run
do
    echo ""
    echo "- Delay is ${delay}ms"
    in_delay="$((delay/2))ms"
    out_delay="$((delay/2))ms"

    # Jitter loop
    for jitter in $jitter_run
    do
        jitter="${jitter}ms"
        echo "  - Jitter is $jitter"

        # Loss loop
        for loss in $loss_run
        do
            echo "    - Loss is ${loss}%"

            # Set new NetEm conditions on Inside interface (for inbound traffic)
            if [ $jitter = 0 ]
		    then
#			    sudo tc qdisc add dev $in_interface root netem delay $in_delay loss $loss
                echo ""
		    else
#			    sudo tc qdisc add dev $in_interface root netem delay $in_delay $jitter 25% distribution normal loss $loss
                echo ""
		    fi

            # Set new NetEm conditions on Outside interface (for outbound traffic)
 #           sudo tc qdisc add dev $out_interface root netem delay $out_delay

            # Display current NetEm conditions (sanity check)
            echo -n "        * $(date -u)"
 #           sudo tc qdisc show dev $in_interface | awk '{print "  : IN   ->   "$0}'
            echo "dev $in_interface root netem delay $in_delay $jitter 25% distribution normal loss $loss"  | awk '{print "  : IN   ->   "$0}'
            echo -n "        * $(date -u)"
#            sudo tc qdisc show dev $out_interface | awk '{print "  : OUT   ->   "$0}'
            echo "dev $out_interface root netem delay $out_delay" | awk '{print "  : OUT   ->   "$0}'
            
            # Leave the new network conditions in place for agreed time duration
            sleep $duration
            # Remove the current NetEm config in preparation for next loop (NetEm does not allow changing directly from one condition to another)
#            sudo tc qdisc del dev $in_interface root
#            sudo tc qdisc del dev $out_interface root
        done
    
    done

done

# Finish
echo ""
echo $(date -u)
echo "Finished NetEm run!"

