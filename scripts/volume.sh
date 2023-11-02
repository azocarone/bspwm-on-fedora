#!/bin/sh
# pulsevol.sh
# PulseAudio Volume Control Script (Simplified - No sink_index or notifications)
# Usage: pulsevol.sh [up|down|mute]
# pulseaudio-utils

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Usage: `basename $0` [up|down|mute]"
    exit $E_BADARGS
fi

VOLSTEP=30 #30%

getvol() {
    VOL=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
}

getvol

up() {
    NEWVOL=$((VOL + VOL * VOLSTEP / 100))
    if [ $NEWVOL -gt 100 ]; then
        NEWVOL=100
    fi
    pactl set-sink-volume 0 $NEWVOL%
    getvol
}

down() {
    NEWVOL=$((VOL - VOL * VOLSTEP / 100))
    if [ $NEWVOL -lt 0 ]; then
        NEWVOL=0
    fi
    pactl set-sink-volume 0 $NEWVOL%
    getvol
}

mute() {
    pactl set-sink-mute 0 toggle > /dev/null
}

case $1 in
up)
    up
    ;;
down)
    down
    ;;
mute)
    mute
    ;;
*)
    echo "Usage: `basename $0` [up|down|mute]"
    exit 1
    ;;
esac
