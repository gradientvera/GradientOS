#!/bin/sh

# Taken from https://gist.github.com/t-animal/dfc962d92d898fc55d15b97252f34ff8
# Big thanks to t-animal for coding this!
# Modified slightly to use strace from $PATH (literally a one-character change but oh well)

# Installation:
# Requires `strace`, best installed as statically built binary using soar https://soar.qaidvoid.dev/
# Encode ouch-sounds with `ffmpeg -i <infile> -b:a 80k -ar 16000  -f ogg <outfile> `
# Add ouch-sounds to ./ogg
#
# Run by adding this to /data/_root_postboot.sh
#
# if [[ -x /data/oucher/oucher.sh ]]; then
# 	nohup /data/oucher/oucher.sh > /dev/null 2>&1 &
# fi

set -e

cd $(dirname $0)

PID=`lsof | grep /dev/ttyS4 | cut -f1`
while [[ "$PID" == "" ]]; do
	sleep 5
	PID=`lsof | grep /dev/ttyS4 | cut -f1`
done

while true; do
	# For protocol see https://github.com/alufers/dreame_mcu_protocol/tree/master
	# Relevant for us:
	# < is start message
	# \x07 is message length (7 bytes for Triggers)
	# \x00 is message type (x00 is the "Triggers" type)
	# \x10 \x20 and \x30 represent a bitmap where \b00110000 the 1 indicate left, right or both bumpers bumped

	NEXT_FILE=ogg/$(ls ogg | shuf | head -n1)

	strace -x -p $PID -P /dev/ttyS4 2>&1 \
		| grep read \
		| grep -E '\\x3c\\x07\\x00\\x[123]0' -m 1 \
		> /dev/null
	ogg123 $NEXT_FILE
	sleep 30
done
